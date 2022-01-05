#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/docker_commands.bash #Import for registry override

CD_IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_CD_IMAGE
docker push $CD_IMAGE_NAME
