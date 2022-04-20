#!/bin/bash

set -e

# manage pwd if executed from main directory || tools
if [ -d tools ];then
    HOST_WORKSPACE=$(pwd)
elif [ -f $0 ]; then
    HOST_WORKSPACE=$(cd .. && pwd)
fi
if [ -d $HOST_WORKSPACE/workspace ]; then
    echo -e "\e[33m[ERROR] workspace directory already exists in $HOST_WORKSPACE.\e[0m"
    exit 1
fi
if [ -d $HOST_WORKSPACE/home ]; then
    echo -e "\e[33m[ERROR] home directory already exists in $HOST_WORKSPACE.\e[0m"
    exit 1
fi
if [ -d $HOST_WORKSPACE/startscripts ]; then
    echo -e "\e[33m[ERROR] startscripts directory already exists in $HOST_WORKSPACE.\e[0m"
    exit 1
fi

. $HOST_WORKSPACE/settings.bash
IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE

# find requested image locally or try pulling from registry
if [ "$(docker image inspect $IMAGE_NAME 2> /dev/null)" == "[]" ]; then
    echo -e "Could not find the requested release image:\n    \e[4m$IMAGE_NAME\e[0m"
    echo -e "Trying to pull image from registry: $DOCKER_REGISTRY"
#    docker login $DOCKER_REGISTRY || (echo -e "\n[HINT] Ensure VPN connection in order to contact registry!"; exit 1)
    docker pull $IMAGE_NAME
    if [ "$?" -ne "0" ]; then
        echo -e "\e[33mPulling docker image from registry failed!\e[0m"
        exit 1
    else
        echo -e "Successfully pulled image from registry."
    fi
else
    echo -e "Found release image:\n    \e[4m$IMAGE_NAME\e[0m"
fi

# find container || init container
if [ "$(docker container ls -a | grep $IMAGE_NAME | wc -l)" -eq "1" ]; then
    THIS_ID=$(docker container ls -a | grep $IMAGE_NAME | awk '{print $1}')
    echo -e "Found existing child container with ID: \e[4m$THIS_ID\e[0m"
elif [ "$(docker container ls -a | grep $IMAGE_NAME | wc -l)" -eq "0" ]; then
    echo -e "Could not find child container that is based on:\n    \e[4m$IMAGE_NAME\e[0m"
    echo -e "Trying to initialize container."
    NEW_ID=$(docker run -tid $RUNTIME_ARG $DOCKER_RUN_ARGS $IMAGE_NAME)
    THIS_ID=$NEW_ID
    if [ "$?" -ne "0" ]; then
        echo -e "\e[33mCreating container from image failed!\e[0m"
        exit 1
    else
        echo -e "Successfully created container with ID:\n    \e[4m$NEW_ID\e[0m"
    fi
else
    echo -e "\e[33m[ERROR] Found multiple containers that are based on:\n    \e[0;4m$IMAGE_NAME\e[0m"
    exit 1
fi

# Copying directories
echo -e "Copying workspace directory."
docker cp $THIS_ID:/opt/workspace $HOST_WORKSPACE/workspace
echo -e "Copying home directory."
docker cp $THIS_ID:/home/dockeruser $HOST_WORKSPACE/home
echo -e "Copying startscripts directory."
docker cp $THIS_ID:/opt/startscripts $HOST_WORKSPACE/startscripts

# remove container if it was created as part of this script
if [ ! -z $NEW_ID ]; then
    echo -e "Remove created container with ID:\n    \e[4m$NEW_ID\e[0m"
    docker container rm $NEW_ID 2>&1 > /dev/null
fi

echo
echo "To work with the extracted files, change the DEFAULT_EXECMODE to devel in settings.bash"
echo
echo "If you don't need the release image anymore, you may delete it:"
echo "docker rmi $IMAGE_NAME"
echo


