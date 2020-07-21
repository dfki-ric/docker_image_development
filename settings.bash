#!/bin/bash

#set a project name
export PROJECT_NAME=docker_development

# URL path to your docker registry, leave blank if you don't have one
export DOCKER_REGISTRY=d-reg.hb.dfki.de

# The default release mode to use if no mode paramater is given to ./exec or ./stop
# The checked in version should reflect the image status and be the highest availale image (base - devel - release)
export DEFAULT_EXECMODE="base" # Use this only for setting up the initial devel image (modify setup_workspace.bash)
#export DEFAULT_EXECMODE="devel" # This is used while deveoping code and preparing a relase
#export DEFAULT_EXECMODE="release" # use the release as default

# The base image used when building a workspace image (one of the ones build in base_images)

# export WORKSPACE_BASE_IMAGE=docker_development/rock_master_18.04:latest # image with rock core dependencies installed
# export WORKSPACE_BASE_IMAGE=docker_development/ros_melodic_18.04:latest # image with basic ros installed
export WORKSPACE_BASE_IMAGE=docker_development/plain_18.04:latest # plain image with build_essentials installed


# The Name of the Workspace image to use
# you should add a workspace name folder and a image name
# e.g MY_PROJECT/docker_development:devel
export WORKSPACE_DEVEL_IMAGE=${PROJECT_NAME}/docker_development:devel
export WORKSPACE_RELEASE_IMAGE=${PROJECT_NAME}/docker_development:release

# In case your docker container needs special run paramaters
# like open ports, additinal mounts etc.
# When you change this, you need to recreate the container
# best way ist to delete the devel-container_id.txt and release-container_id
export ADDITIONAL_DOCKER_RUN_ARGS=" \
        --dns-search=dfki.uni-bremen.de \
        "

