#!/bin/bash

#copy scripts VERSION file to put it into the image
cp ../../VERSION ./

. ../../settings.bash
export IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}developmentimage/ros_noetic_20.04

export BASE_IMAGE=nvidia/opengl:1.0-glvnd-devel-ubuntu20.04
export INSTALL_SCRIPT=install_ros_dependencies.bash
export INSTALL_ARGS=noetic

docker pull $BASE_IMAGE
docker build --no-cache -f Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT --build-arg INSTALL_ARGS .



echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME:base"
echo

