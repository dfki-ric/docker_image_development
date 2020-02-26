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

. ./docker_commands.sh

#get a md5 for the current folder used as container name suffix
#(several checkouts  of this repo possible withtou interfering)
FOLDER_MD5=$(echo $(pwd) | md5sum | cut -b 1-8)

#use current folder name + devel + path md5 as container name
#(several checkouts  of this repo possible withtout interfering)
CONTAINER_NAME=${CONTAINER_NAME:="${PWD##*/}-devel-$FOLDER_MD5"}
IMAGE_NAME="d-reg.hb.dfki.de/mare-it/uuv-sim_18.04:devel"
CONTAINER_ID_FILENAME=devel-container_id.txt

if [ ! -f $CONTAINER_ID_FILENAME ]; then
    touch $CONTAINER_ID_FILENAME
fi
CONTAINER_IMAGE_ID=$(cat $CONTAINER_ID_FILENAME)
CURRENT_IMAGE_ID=$(docker inspect --format '{{.Id}}' $IMAGE_NAME)

HOST_WORKSPACE=$(pwd)
mkdir -p $HOST_WORKSPACE/workspace
mkdir -p $HOST_WORKSPACE/home

DOCKER_RUN_ARGS=" \
                --name $CONTAINER_NAME \
                --privileged \
                -v /dev/input/:/dev/input \
                -e NUID=$(id -u) -e NGID=$(id -g) \
                -u devel \
                --dns $DNSIP \
                --dns-search=dfki.uni-bremen.de \
                --expose 7001 --expose 7002 \
                -p 7001:7001 -p 7002:7002 \
                -e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v $HOST_WORKSPACE/startscripts:/opt/startscripts \
                -v $HOST_WORKSPACE/workspace/:/opt/workspace -v $HOST_WORKSPACE/home/:/home/devel \
                "

init_docker $@

xhost -local:root
