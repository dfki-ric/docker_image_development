#!/bin/bash

set -e

# manage pwd if executed from main directory || tools
if [ -d tools ];then
    HOST_WORKSPACE=$(pwd)
elif [ -f $0 ]; then
    HOST_WORKSPACE=$(cd .. && pwd)
fi
if [ -d $HOST_WORKSPACE/workspace ]; then
    echo -e "\e[31mworkspace directory already exists in $HOST_WORKSPACE.\e[0m"
    exit 1
fi
if [ -d $HOST_WORKSPACE/home ]; then
    echo -e "\e[31mhome directory already exists in $HOST_WORKSPACE.\e[0m"
    exit 1
fi

. $HOST_WORKSPACE/settings.bash
IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE

# find requested image
if [[ "$(docker image inspect $IMAGE_NAME 2> /dev/null)" == "" ]]; then
    echo -e "Could not find the requested release image:\n    \e[4m$IMAGE_NAME\e[0m"
    exit 1
else
    echo -e "Found release image:\n    \e[4m$IMAGE_NAME\e[0m"
fi

# find container && copy directories
if [ "$(docker container ls -a | grep $IMAGE_NAME | wc -l)" -ne "0" ]; then
    THIS_ID=$(docker container ls -a | grep $IMAGE_NAME | awk '{print $1}')
    echo -e "Found existing child container with ID: \e[4m$THIS_ID\e[0m"
    echo -e "Copying workspace directory."
    docker cp $THIS_ID:/opt/workspace $HOST_WORKSPACE/
    echo -e "Copying home directory."
    docker cp $THIS_ID:/home $HOST_WORKSPACE/
else
    echo -e "Could not find child container that is based on:\n    \e[4m$IMAGE_NAME\e[0m"
    exit 1
fi


