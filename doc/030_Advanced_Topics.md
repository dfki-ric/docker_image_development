
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

Normally it is not required to keep the forked repo in sync with the upstream changes.
Everything should be fine, as long as the forked repo version corresponds to the version that was used to create the devel image that is used.

A common case for when a sync actually is (or may be) required, is the creation of a new devel image.
The scripts' version should match that with which the upstream-provided base image was created.
Recent versions of the scripts implement a version check that compares the versions of scripts and base image for this purpose.
A warning is printed if the versions no longer match.

In this case you should merge the upstream changes with your setup.

In case you want to build a new devel image based on a new version of the base image you might need to activate the setting `DOCKER_REGISTRY_AUTOPULL` to make sure a new version is actually pulled from the registry (if available). Another option is to use `tools/update_image.bash base` to update the base image before you create a devel image, or to delete local the base image using `docker rmi`.

On the other hand, if `DOCKER_REGISTRY_AUTOPULL` is false, you may re-use the base image used for the initial build of the devel image (if you still have it available). Also, you may build your own local base images using the script versions in your fork.



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

