#!/bin/bash

IMAGE_NAME=d-reg.hb.dfki.de/docker_development/plain_20.04

export BASE_IMAGE=ubuntu:20.04
export INSTALL_SCRIPT=install_plain_dependencies.bash

docker pull $BASE_IMAGE
docker build --no-cache -f Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT .



echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME:base"
echo
