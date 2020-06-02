#!/bin/bash

xhost +local:root

. ./docker_commands.bash
. ./settings.bash

EXECMODE=$DEFAULT_EXECMODE

if [ "$1" = "devel" ]; then
    echo "overriding default execmode $DEFAULT_EXECMODE to: devel"
    EXECMODE="devel"
    shift
fi
if [ "$1" = "release" ]; then
    echo "overriding default execmode $DEFAULT_EXECMODE to: release"
    EXECMODE="release"
    shift

fi

if [ "$EXECMODE" = "devel" ]; then
    # DOCKER_REGISTRY and WORKSPACE_DEVEL_IMAGE from settings.bash
    IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE
    HOST_WORKSPACE=$(pwd)
    mkdir -p $HOST_WORKSPACE/workspace
    mkdir -p $HOST_WORKSPACE/home
    ADDITIONAL_DOCKER_MOUNT_ARGS=" \
        -v $HOST_WORKSPACE/startscripts:/opt/startscripts \
        -v $HOST_WORKSPACE/workspace/:/opt/workspace \
        -v $HOST_WORKSPACE/home/:/home/devel \
        "
                
fi
if [ "$EXECMODE" == "release" ]; then
    # DOCKER_REGISTRY and WORKSPACE_DEVEL_IMAGE from settings.bash
    IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
fi

#this flag defines if an interactive container (console inputs) is created ot not
#if env already set, use external set value
INTERACTIVE=${INTERACTIVE:="true"}


#get a md5 for the current folder used as container name suffix
#(several checkouts  of this repo possible withtou interfering)
FOLDER_MD5=$(echo $(pwd) | md5sum | cut -b 1-8)

#use current folder name + devel + path md5 as container name
#(several checkouts  of this repo possible withtout interfering)
CONTAINER_NAME=${CONTAINER_NAME:="${PWD##*/}-$EXECMODE-$FOLDER_MD5"}
CONTAINER_ID_FILENAME=$EXECMODE-container_id.txt

echo
echo -e "\e[32musing $IMAGE_NAME\e[0m"
echo



if [ ! -f $CONTAINER_ID_FILENAME ]; then
    touch $CONTAINER_ID_FILENAME
fi
CONTAINER_IMAGE_ID=$(cat $CONTAINER_ID_FILENAME)
CURRENT_IMAGE_ID=$(docker inspect --format '{{.Id}}' $IMAGE_NAME)

DOCKER_RUN_ARGS=" \
                --name $CONTAINER_NAME \
                -e NUID=$(id -u) -e NGID=$(id -g) \
                -u devel \
                --dns $DNSIP \
                -e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix \
                $ADDITIONAL_DOCKER_RUN_ARGS \
                $ADDITIONAL_DOCKER_MOUNT_ARGS \
                "

init_docker $@

xhost -local:root
