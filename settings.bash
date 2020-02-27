#!/bin/bash

# URL path to your docker registry, leave blank if you don't have one
export DOCKER_REGISTRY=d-reg.hb.dfki.de

# The base image used when building a workspace image (one of the ones build in base_images)
# docker_development/plain_18.04 # plain image with build_essentials installed
# docker_development/rock_master_18.04 # image with rock core dependencies installed
# docker_development/ros_melodic_18.04 # image with basic ros installed
export WORKSPACE_BASE_IMAGE=docker_development/plain_18.04:latest

# The Name of the Workspace image to use
export WORKSPACE_DEVEL_IMAGE=docker_development/plain_18.04:latest
#export WORKSPACE_DEVEL_IMAGE=docker_development/docker_development_test:devel
export WORKSPACE_RELEASE_IMAGE=docker_development/docker_development_test:release


