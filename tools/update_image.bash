#!/bin/bash

. ../settings.bash


IMAGE=""
EXECMODE=$DEFAULT_EXECMODE

if [ "$1" = "base" ]; then
    EXECMODE="base"
    shift
fi
if [ "$1" = "devel" ]; then
    EXECMODE="devel"
    shift
fi
if [ "$1" = "release" ]; then
    EXECMODE="release"
    shift
fi
if [ "$EXECMODE" = "base" ]; then
    IMAGE=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_BASE_IMAGE
fi
if [ "$EXECMODE" = "devel" ]; then
    IMAGE=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE
fi
if [ "$EXECMODE" = "release" ]; then
    IMAGE=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
fi



echo "pulling image ${IMAGE}"
docker pull $IMAGE
