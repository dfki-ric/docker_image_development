#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/variables.bash

evaluate_execmode $1

CONTAINER_NAME="${ROOT_DIR##*/}-$EXECMODE-$FOLDER_MD5"

$PRINT_INFO "stopping ${CONTAINER_NAME}"
docker stop ${CONTAINER_NAME}
