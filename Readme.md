# Docker development 

These script are helping to set up a docker-based robot development and release workflow.

If the imges are already build and available in your registry, jump to the Running section

They are based on different docker image setup steps, which can be omitted for other workspaces when a local registry is set up

* build a base image for Rock or ROS (shared for all)
 * if already in your registry, omit this step
 * readme in image_setup/01_base_image
* build a workspace image (shared for project) with a mounted workspace, hoem and startscript folders
 * if already in your registry, omit this step
 * readme in image_setup/02_workspace_image
* build a release image containing the workspace
 * readme in image_setup/03_release_image

## Start your own project

In case you want to setup your own workspace image, please fork this repository into your group using the git web interface.
This way, changes and updates can be tracked and updated more easily in both directions.

* Edit the settings.bash with your project paramaters, the base iamges are most probably in the registry
* Edit the image_setup/02_workspace_image/Dockerfile to install your workspace dependencies
* If you want, fill the setup_workspace script
* build the workspace image
 * docker push the image
* start setting up/building the workspace ```bash ./exec_in_devel.sh /bin/bash```
* build the release image
 * docker push the image

git push the changes to your fork of this repository

Now others can clone this repository and directly call ```bash ./exec_in_release.sh /bin/bash```


# 3D acceleration

The images support 3D acceleration, when you have a nvidia card installed, if you don't the images will still work.

You will need nvidia-docker2, follow the instructions here: 

https://github.com/NVIDIA/nvidia-docker



# Running 

Before you run a container, check and edit the docker paramaters (DOCKER\_RUN\_ARGS) in exec_in_devel.sh and exec_in_release.sh

## Start Container

You can start the workspace in devel or release mode:

* call ```bash ./exec_in_devel.sh /bin/bash``` 
* or   ```bash ./exec_in_release.sh /bin/bash``` 
  * In case a release image is available in your registry, it will be automatically pulled and launched

Now you can run programs as you like

Or you execute a startscript from the startscripts folder (they are in the path) and also available in the release

```bash ./exec_in_devel.sh hello_world.sh```

This can be used to execute specific executables from your workspace


## attach more bashes or start more programs

Each subsequent call to exec\_in\_devel is using the same container

You can attach more bashes to the container using the exec\_in\_ command again

```bash ./exec_in_devel.sh /bin/bash```

or 

```bash ./exec_in_devel.sh hello_world.sh```


# upgrade image

Upgrades are detected automatically, only the workspace and home folders are preserved.
Programs manually installed using apt are lost.



# Docker quick guide

Docker separates between images and containers.

## Images

Images are fixed states from which runtime containers can be started from.

They are generated using so called Dockerfiles

## Containers

A container derives from an image and is created by running an image.
Once a container is "run" (a.k.a. created), it can be started again.
Local changes are preseved in the container until the container is deleted

# setup docker

* Add your user to the docker group

`sudo usermod -aG docker $USER` (https://docs.docker.com/install/linux/linux-postinstall/)

* Log out and log back in so that your group membership is re-evaluated.



