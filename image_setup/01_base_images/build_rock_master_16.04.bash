#!/bin/bash

. ../../settings.bash

# manage base image name depending on selected $ARCH in settings.bash
if [ "$ARCH" == "" ] || [ "$ARCH" == "x86_64" ]; then
    export BASE_IMAGE=nvidia/opengl:1.0-glvnd-devel-ubuntu16.04
    echo "Building for x86_64 processor. Using $BASE_IMAGE as base image."
else
    export BASE_IMAGE=$ARCH/ubuntu:xenial
    echo "Building for $ARCH processor. Using $BASE_IMAGE as base image."
fi

export IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}developmentimage/${ARCH:+$ARCH/}rock_master_16.04
export INSTALL_SCRIPT=${ARCH:+$ARCH/}install_rock_dependencies.bash

docker pull $BASE_IMAGE
docker build --no-cache -f Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT .

echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME:base"
echo
