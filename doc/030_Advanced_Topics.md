
### Updating Images From Registry

You can cd into the `tools` folder and call `update_image.bash` this updates the image of the current default exec mode.
Call `update_image.bash [base|devel|release]` to update other images.

If you want to automate the update you can set the auto update mode in the settings.bash

### Refreshing the Container

This should not be needed, but is sometimes required for testing.
The easiest way is to run the provided `delete_container.bash` script.
This deletes the container of the current default exec mode.
Call `delete_container.bash [base|devel|release]` to delete other containers.

The container will be re-created on the next call of `./exec.bash`.

When you update the image by pulling from registry or rebuilding the devel image, the containers are also regenerated.

### Keeping the Fork in Sync with Upstream Changes

Normally it is not required to keep the forked docker_image_development repo in sync with the upstream changes.
Everything should be fine, as long as the forked repo version corresponds to the version that was used to create the devel image that is used.

A common case for when a sync actually is (or may be) required, is the creation of a new devel image.
The scripts version should match that with which the upstream-provided base image was created.

There is a version check on container creation that compares the versions of scripts and base image for this purpose.
A warning/error is printed if the versions no longer match.

In this case you should follow the messages inscructions and either update the scripts or the image.

#### Update the Scripts

* Try a `git pull` on the scripts possibly a collaborator already did the script update

If that does not help, do the script update yourself:

* `git remote add docker_image_develomment https://github.com/dfki-ric/docker_image_development` (if not present from older upgrade)
* `git pull docker_image_develomment master
* resolve the conflicts (if any, but keep your local settings)
* `git push` the updated scripts to your fork

Now you can push the upgrade to your fork of docker_image_develomment and build/push the new devel image

Optionally you can build your own base image based on the current version of the scripts: navigate to image_setup/01_base_images/ and run the build script of your base image.
This creates a fresh the base image in your state of the scripts. BUT when creating the devel image answer "no" when asked if a newer image should be pulled.

#### Update the Image

First, try if a collaborator already did the devel image upgrade, the chances are high that the person that merged the script update also pushed new images to the registry:

* `./tools/update_image.bash`

If that is unsuccessful:

* `./exec.bash write_osdeps` (in case you use a supported software stack to auto-fill apt depenencies)
* `cd image_setup/02_devel_image/`
* `bash bild.bash`
* `push the new image`

Also check if you need a new release image.

TIP: If you want to run an old image, the git commit_id of the versien the image was created with, is stored as label in the image, you can run `./tools/match_repo_commit_with_image.bash` to create a detached HEAD with the matching scripts version.


### Apply Changes to a Release Without Devel Folders

In case you need to change parts of an existing release image, you have two options:

1. extract a devel workspace from a release image using the `extract_*.bash` script in the tools folder
   * You need to generate a devel image or have access to it in the registry
   * change the default execmode or use `./exec.bash devel`
   * use the devel mode to do the changes
   * build a new release
2. Edit the code within the container
   * Changes are lost when the container is deleted/refreshed, unless you "docker commit" the changes

### VSCode Extensions for Docker and Rock

You can edit code, compile and debug in your container from a host using the remote development package from VScode. Once you have your container created and visual studio with the [remote development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) installed on your host you can access your containers for development with this extension.

Another useful extension for vscode to work with Rock is the [rock extension](https://marketplace.visualstudio.com/items?itemName=rock-robotics.rock). This tool gives you access to the most common autoproj commands directly from the vscode interface.

### Using iceccd in the container

Note: This has not been thoroughly tested. But feel free to try and provide feedback.

#### Step 1 (option a)

Iceccd in the container has problems to find the iceccd server. To solve this, you have to modify the config file  `/etc/icecc/icecc.conf` to set `ICECC_SCHEDULER_HOST`to the address of the scheduler. 

#### Step 1 (option b)

When starting your container, use the flag  `--net=host` so that host and container share the same network interfaces.

#### Step 2

Stop the iceccd daemon on your host with

```
sudo service iceccd stop
```

and restart it in the container

```
sudo service iceccd restart
```

It should be possible to have more complex setups for the iceccd in containers/hosts. So that not necessarily the host has to stop using icecc or multiple container can make use of it.

### Cross Development with docker images

To develop for arm-based systems on x86, you can enable your host machine execute non-native binary formats using [QEMU](https://www.qemu.org) and [binfmt_misc](https://www.kernel.org/doc/html/latest/admin-guide/binfmt-misc.html).

When this is set up, docker is able to run images for the architectures supported by QEMU on your host machine (using CPU emulation).

There is a docker image that can do the settings for you: [see here](https://github.com/multiarch/qemu-user-static)

Quick enable:

    sudo apt-get install qemu binfmt-support qemu-user-static
    sudo docker run --rm --privileged multiarch/qemu-user-static --reset -p yes --credential yes

Test it using e.g.

    docker run --rm -ti arm64v8/ubuntu uname -m
    
Currently you need to build your own base images to use this feature
    
