# Docker Development 

These scripts are helping to set up a docker-based development and release workflow.

In case the images are already build and available in your registry, jump to the Running section

They are based on different docker image setup steps, which can be omitted for other workspaces when a local registry is set up and ther iamge is already available

* build a base image for Rock or ROS (shared for all)
   * if already in your registry, omit this step
   * readme in _image_setup/01_base_image_
* build a workspace image (shared for project) with a mounted workspace, hoem and startscript folders
   * if already in your registry, omit this step
   * readme in _image_setup/02_workspace_image_
* develop your code
* build a release image containing the workspace
   * readme in _image_setup/03_release_image_
* build archives with image and scritps to deploy to others
   * readme in _image_setup/04_save_release_

# Running 

Before you run a container, check and edit the settings.bash to configure your images

* git clone this repo to your system, rename the repo name locally
   * git clone https://git.hb.dfki.de/MY_PROJECT/docker_development MY_PROJECT

## 3D Acceleration

The images support 3D acceleration, when you have a nvidia card installed.
If you don't have it installed or an nvidia card the images will still work.

Install nvidia-docker2: Follow the instructions [here](https://github.com/NVIDIA/nvidia-docker).


## Start Container

You can start the workspace in devel or release mode:

* call ```./exec_in_devel.sh /bin/bash``` 
* or   ```./exec_in_release.sh /bin/bash``` 
  * In case a release image is available in your registry, it will be automatically pulled and launched

Now you can run programs as you like

Or you execute a startscript from the startscripts folder (they are in the path) and also available in the release

```./exec_in_devel.sh bash```

```./exec_in_devel.sh hello_world```

This can be used to execute specific executables from your workspace


## Attach More Bashes or Start More Programs

Each subsequent call to exec\_in\_devel is using the same container

You can attach more bashes to the container using the exec\_in\_ command again

```./exec_in_devel.sh /bin/bash```

or 

```./exec_in_devel.sh bash```


# Start Your own Project and Images

In case you want to setup your own workspace image, please fork this repository into your group using the git web interface.
This way, changes and updates can be tracked and updated more easily in both directions.

* fork this repository to the new group
* git clone it to your system, rename the repo name locally
   * git clone https://git.hb.dfki.de/MY_PROJECT/docker_development MY_PROJECT
* Edit the settings.bash with your project paramaters, the base iamges are most probably in the registry
* Edit the image_setup/02_workspace_image/Dockerfile to install your workspace dependencies
* If you want, edit/fill the setup_workspace script
* build the workspace image
   * docker push the image ```docker push <image_repository:tag>```
* start setting up/building the workspace ```./exec_in_devel.sh /bin/bash```
* build the release image
   * docker push the image ```docker push <image_repository:tag>```
* git push the changes to your fork of this repository

Now others can clone this repository and directly call ```./exec_in_release.sh /bin/bash```.
Docker will pull the release image automatically.



# Upgrade Image

Upgrades are detected automatically, only the workspace and home folders are preserved.
Programs manually installed using apt are lost.

You can docker pull images manually by executing ```update_workspace_images.bash```

# Docker Quick Guide

Docker separates between images and containers.

## Images

Images are fixed states from which runtime containers can be started from.

They are generated using so called Dockerfiles

## Containers

A container derives from an image and is created by running an image.
Once a container is "run" (a.k.a. created), it can be started again.
Local changes are preseved in the container until the container is deleted

## Docker Setup

* Add your user to the docker group

`sudo usermod -aG docker $USER` (https://docs.docker.com/install/linux/linux-postinstall/)

* Log out and log back in so that your group membership is re-evaluated.



