#!/bin/bash

. ../../settings.bash
export IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}developmentimage/rock_master_16.04

export BASE_IMAGE=nvidia/opengl:1.0-glvnd-devel-ubuntu16.04
export INSTALL_SCRIPT=install_rock_dependencies.bash

docker pull $BASE_IMAGE
docker build --no-cache -f Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT .



echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME:base"
echo
