#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/docker_commands.bash

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
if [ "$1" = "CD" ]; then
    EXECMODE="CD"
    shift
fi
if [ "$EXECMODE" = "base" ]; then
    IMAGE=${BASE_REGISTRY:+${BASE_REGISTRY}/}$WORKSPACE_BASE_IMAGE
fi
if [ "$EXECMODE" = "devel" ]; then
    IMAGE=${DEVEL_REGISTRY:+${DEVEL_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE
fi
if [ "$EXECMODE" = "release" ]; then
    IMAGE=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
fi
if [ "$EXECMODE" = "CD" ]; then
    IMAGE=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_CD_IMAGE
fi

echo "pulling image ${IMAGE}"
docker pull $IMAGE
