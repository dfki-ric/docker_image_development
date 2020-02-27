#!/bin/bash

xhost +local:root

#if [ $# -lt 2  ] ;then
#     echo "Incorrect usage. Use: docker-run.sh <param1> <param2>"
#     echo "<param1>: Give the global path to the folder that will be the workspace on the local host machine"
#     exit 1
#fi

#this flag defines if an interactive container (console inputs) is created ot not
#if env already set, use external set value
INTERACTIVE=${INTERACTIVE:="true"}

. ./docker_commands.bash
. ./settings.bash

#get a md5 for the current folder used as container name suffix
#(several checkouts  of this repo possible withtou interfering)
FOLDER_MD5=$(echo $(pwd) | md5sum | cut -b 1-8)

#use current folder name + devel + path md5 as container name
#(several checkouts  of this repo possible withtout interfering)
CONTAINER_NAME=${CONTAINER_NAME:="${PWD##*/}-release-$FOLDER_MD5"}

# DOCKER_REGISTRY and WORKSPACE_DEVEL_IMAGE from settings.bash
IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
echo
echo -e "\e[32musing $IMAGE_NAME\e[0m"
echo

CONTAINER_ID_FILENAME=release-container_id.txt

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
                --dns-search=dfki.uni-bremen.de \
                -e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix \
                "

init_docker $@

xhost -local:root
