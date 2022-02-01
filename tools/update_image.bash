#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/.docker_scripts/variables.bash

evaluate_execmode $1
set_image_name $EXECMODE

$PRINT_INFO "pulling image ${IMAGE_NAME}"
docker pull $IMAGE_NAME
