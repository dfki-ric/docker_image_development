#!/bin/bash

# set a project name, no empty spaces or special characters allowed
export PROJECT_NAME=docker_image_development

# path to your docker registry, leave blank if you don't have one
# e.g. my.registry.com, ghcr.io/dfki-ric, docker.pkg.github.com
export DOCKER_REGISTRY=

# in case you are not using a single registry, you can push images in different ones
# e.g. store base images on hub.docker.com and others in a local registry
export BASE_REGISTRY=
export DEVEL_REGISTRY=$DOCKER_REGISTRY
export RELEASE_REGISTRY=$DOCKER_REGISTRY

# should exec and build scripts auto-pull updated images from the registry?
export DOCKER_REGISTRY_AUTOPULL=false

### The default release mode to use if no mode paramater is given to ./exec.bash or ./stop.bash
### The checked in version should reflect the image status and be the highest availale image (base - devel - release)
export DEFAULT_EXECMODE="base" # Use this only for setting up the initial devel image (modify setup_workspace.bash)
# export DEFAULT_EXECMODE="devel" # This is used while deveoping code and preparing a relase
# export DEFAULT_EXECMODE="release" # use the release as default

### The base image used when building a workspace image (one of the ones build in base_images)
# export WORKSPACE_BASE_IMAGE=developmentimage/rock_master_18.04:base # image with rock core dependencies installed
# export WORKSPACE_BASE_IMAGE=developmentimage/rock_master_20.04:base # image with rock core dependencies installed
# export WORKSPACE_BASE_IMAGE=developmentimage/ros_melodic_18.04:base # image with basic ros melodic installed
# export WORKSPACE_BASE_IMAGE=developmentimage/ros_noetic_20.04:base # image with basic ros noetic installed
# export WORKSPACE_BASE_IMAGE=developmentimage/plain_18.04:base # plain image with build_essentials installed
export WORKSPACE_BASE_IMAGE=developmentimage/plain_20.04:base # plain image with build_essentials installed


# The Name of the Workspace image to use
# you should add a workspace name folder and a image name
# e.g MY_PROJECT/docker_image_development:devel
# under normal circumstances you should not need to change these
export WORKSPACE_DEVEL_IMAGE=developmentimage/${PROJECT_NAME}:devel
export WORKSPACE_RELEASE_IMAGE=developmentimage/${PROJECT_NAME}:release

# In case your docker container needs special run paramaters
# like open ports, additional mounts etc.
# When you change this, you need to recreate the container
# best way to do this, is to delete the {devel,release}-container_id.txt file
# often used params:
# --dns-search=mydomain
# --net=host
# --privileged
# -v /dev/input/:/dev/input
# -v $HOME/.Xauthority:/home/devel/.Xauthority #mount the .Xauthority file, if the GUI shall be forwarded through ssh Xforwarding
export ADDITIONAL_DOCKER_RUN_ARGS=""

# Make the exec script to talk more for debugging/docker setup purposes.
# This may also be stated in the command line: $> VERBOSE=true ./exec.bash 
# export VERBOSE=true

# Make the output as quiet as possible (does not apply to programs started in the container)
# export SILENT=false

# mount ccache volume, if enabled, a volume name based on the base image name is generated
# and mounted to /ccache, this way multiple workspaces in docker_image_development
# can share a single ccache, CCACHE_DIR is automatically set in the env, just install
# and enable ccache for your builds
# export MOUNT_CCACHE_VOLUME=true
