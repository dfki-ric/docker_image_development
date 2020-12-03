#!/bin/bash

. ../../settings.bash


export ARCH=${1:-x86_64}
# set architecture depending on passed argument
# available architectures on docker hub: https://github.com/docker-library/official-images#architectures-other-than-amd64
if [ $ARCH == "x86_64" ]; then
    export BASE_IMAGE=nvidia/opengl:1.0-glvnd-devel-ubuntu20.04
    echo "Building for x86_64 processor. Using $BASE_IMAGE as base image."
elif [ $ARCH == "arm64v8" ]; then
    export BASE_IMAGE=arm64v8/ubuntu:focal
    echo "Building for arm64v8 processor. Using $BASE_IMAGE as base image."
else
    echo -e "[ERROR] The processor architecture you selected ($ARCH) is not supported.\n        Currently only x86_64 and arm64v8 are supported." && exit 1
fi

export IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}developmentimage/$ARCH/ros_noetic_20.04
export INSTALL_SCRIPT=install_ros_dependencies.bash
export INSTALL_ARGS=noetic

docker pull $BASE_IMAGE
docker build -f Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT --build-arg INSTALL_ARGS .
#docker build --no-cache -f Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT --build-arg INSTALL_ARGS .



echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME:base"
echo

