#!/bin/bash

#get a md5 for the curretn folder used as container name suffix
#(several checkouts  of this repo possible withtou interfering)
FOLDER_MD5=$(echo $(pwd) | md5sum | cut -b 1-8)

#use current folder name + release + path md5 as container name
#(several checkouts  of this repo possible withtout interfering)
CONTAINER_NAME="${PWD##*/}-release-$FOLDER_MD5"

echo "stopping ${CONTAINER_NAME}"
docker stop ${CONTAINER_NAME}