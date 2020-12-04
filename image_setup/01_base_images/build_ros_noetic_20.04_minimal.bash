#!/bin/bash

. ../../settings.bash

# manage base image name depending on selected $ARCH in settings.bash
if [ $ARCH == "x86_64" ]; then
    export BASE_IMAGE=nvidia/opengl:1.0-glvnd-devel-ubuntu20.04
    echo "Building for x86_64 processor. Using $BASE_IMAGE as base image."
elif [ $ARCH == "arm64v8" ]; then
    export BASE_IMAGE=arm64v8/ubuntu:focal
    echo "Building for arm64v8 processor. Using $BASE_IMAGE as base image."
else
    echo -e "[ERROR] The processor architecture you selected ($ARCH) is not supported." && exit 1
fi

export IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}developmentimage/ros_noetic_20.04_minimal
export INSTALL_SCRIPT=install_ros_minimal_dependencies.bash
[ "$ARCH" != "x86_64" ] && export IMAGE_NAME=$(dirname $IMAGE_NAME)/$ARCH/$(basename $IMAGE_NAME)
[ "$ARCH" != "x86_64" ] && export INSTALL_SCRIPT=$ARCH/$INSTALL_SCRIPT
export INSTALL_ARGS=noetic

docker pull $BASE_IMAGE
docker build --no-cache -f Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT --build-arg INSTALL_ARGS .


echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME:base"
echo
