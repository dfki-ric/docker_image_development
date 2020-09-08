# Docker Development 

These scripts are helping to set up a docker-based development and release workflow.

The goal is to prepare docker _images_ that encapsulate a component's or a project's dependencies so that work is being done in a consistent, reproducible environment, i.e., to prevent that code not only builds or runs on the developer's machine and fails elsewhere.
In order to achieve this, the **devel image** is created to contain all dependencies for the workspace preinstalled.

Devel images are usually based on **base images**, that encapsulate dependencies shared by many projects.
The build process will automatically try to pull required images from a docker registry.
If the image is already available locally, it doesn't need to be pulled again.
In order to check for available base images you can browse the DFKI [internal registry](https://d-reg.hb.dfki.de/repositories) (available via VPN, login required).

Another goal of this approach is to be able to preserve a working version of a component, a project or a demo and possibly ship it to external partners.
In order to achieve this, the **release image** can be created, which contains the devel image plus the additional workspace files and run scripts required to operate the product.

## Preparation

Please install Docker according to the [README_Docker.md](README_Docker.md).


## General Usage

### Run or Attach to the Docker Container

In order to initialize, run or attach to containers you will be using the `./exec.bash` script.
You can use either `base`, `devel` or `release` as argument in order to determine which image shall be instantiated in your container (or leave out the argument and use the default mode specified in `settings.bash`):

    $ ./exec.bash <mode>

Normally the exec.bash script will drop into a /bin/bash shell with the default mode set in the settings.bash if no other arguments are given.
Each subsequent call to `./exec.bash` is running within the same container.

If the requested image is not yet available locally it will be pulled from the docker registry (you need to be logged in at the registry then).


### Run Commands or Start Scripts in the Docker Container

You can directly run commands in the Docker container. Especially for release this is useful as you only need to run one command on the host computer to execute an application inside the container.

Example:

    $ ./exec.bash <command>`

`command` can be any (shell) command found on the client's PATH.
You can here too optionally specify the execmode to specify whether you want to run the command with the base, devel or release image.
You can (and probably should) define start scripts to execute one or many applications from the image's workspace.

You can activate some autocomplete hints on the host machine by sourcing `$ source autocomplete.me` for the `./exec.bash` arguments.
However, if the image was created with a different version of this cloned repository, the start scripts that are actually available in the container might differ.
In this case autocompletion might not work correctly.
A possible workaround is to reset this repo to the date when the release image was created.


### Container Management

When you exit (detach from) the container shell, the container keeps running in the background. You can inspect which containers are running at the time via `docker ps` and stop containers via `docker stop <container_id>`. You can regenerate a new container from an image, you can delete the file `docker_development/<mode>-container_id.txt` and then restart using `./exec.bash`. 




## Release Images

### Run From a Release Image via Docker Registry

Just follow the instructions given above for attaching to a container and running commands within a container.
Make sure you have access to the Docker registry if you don't already have pulled the image (VPN, Login).
Make sure that you use the exec mode `release`.

### Run From an Exported Release Archive

If you want to deploy images somewhere you don't have access to the docker registry, you can export to a .tar.gz file containing the image and the workspace files.

You can load and run from the release locally using the instructions provided with the file.

### Create a Release Image

The exact process for doing that is described at the [release image Readme](image_setup/03_release_image/Readme.md).
You should change the default exec mode to `release` for the repository accompanying the new image.

### Export Release Archive

The exact process for doing that is described at the [save release Readme](image_setup/04_save_release/Readme.md).




## Devel Images

### Run From a Devel Image

Just follow the instructions given above for attaching to a container and running commands within a container.
Make sure you have access to the Docker registry if you don't already have pulled the image (VPN, Login).
Make sure that you use the exec mode `release`.

The devel image is pulled with only the dependencies of the workspace installed.
The devel container is set up to mount several directories within the host's repository clone:

* **/opt/startscripts** corresponds to the host's `docker_development/startscripts`
* **/opt/workspace** corresponds to the host's `docker_development/workspace`
* **/home/devel** corresponds to the host's `docker_development/home`

These are initially empty. That means, in order to run applications from the workspace, it needs to be set up (and usually built) at the first run to fully initialize the container.

In order to do this, instantiate and attach to the container using `./exec.bash devel` (as explained above).
If the image was created properly, instructions are printed how to proceed from there.
Usually this will include running the script `bash /opt/setup_workspace.sh` potentially followed by additional build steps.

To wrap it up, you can edit files in the workspace from your host system, but to compile and run, you need to enter the container as explained above (via `./exec.bash devel`).
In case you are using VSCode also check out the "Remote - Containers" extension.


### Create a Devel Image


To create a devel image, have a look at the [devel image Readme](image_setup/02_devel_image/Readme.md).
You should change the default exec mode to `devel` for the repository accompanying the new image.



## Advanced


### Create Base Images

If you are the one that is initally creating the images for your own registry (or you have none), this is your workflow:

1. Go to the `image_setup/01_base_images` folder.
1. Call the build scripts you need the base images for.
1. If you have a registry, push them.

Also see the [base image Readme](image_setup/01_base_images/Readme.md).


### Updating Images From Registry

You can cd into the `tools` folder and call `update_image.bash` this updates the image of the current default exec mode.
Call `update_image.bash [base|devel|release]` to update other images

### Refreshing the Container

This should not be needed, but is somtimes required for testing.
The easiest way is to delete the accorting `*-container_id.txt` file(s).
The container will be re-created on the next call of `./exec.bash`.

When you update the image by pulling from registry or rebuilding the devel image, the containers are also regenerated.


### Apply Changes to a Release Without Devel Folders

In case you need to change parts of an existing release image, you have two options:

1. extract a release to a devel workspace using the script in the tools folder
   * You need to generate a devel image or have access to it in the registry
   * change the default execmode or use `./exec.bash devel`
   * use the devel mode to do the changes
   * build a new release
2. Edit the code within the container
   * Changes are lost when the container is deleted/refreshed, unless you "docker commit" the changes


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

### VSCode Extensions for Docker and Rock

You can edit code, compile and debug in your container from a host using the remote development package from VScode. Once you have your container created and visual studio with the [remote development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) installed in your host you can access your containers for development with this extension.

Another useful extension for vscode to work with Rock is the [rock extension](https://marketplace.visualstudio.com/items?itemName=rock-robotics.rock). This tool gives you access to the most common autoproj commands directly from the vscode interface.
