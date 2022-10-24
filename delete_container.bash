#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/file_handling.bash
source $ROOT_DIR/.docker_scripts/variables.bash
source $ROOT_DIR/settings.bash

# stop on error
set -e

evaluate_execmode $1

CONTAINER_NAME=${CONTAINER_NAME:="${ROOT_DIR##*/}-$EXECMODE-$FOLDER_MD5"}

$PRINT_INFO "stopping ${CONTAINER_NAME}"
docker stop ${CONTAINER_NAME} > /dev/null || true
docker rm ${CONTAINER_NAME} > /dev/null
$PRINT_INFO "successfully removed ${CONTAINER_NAME}"
write_value_to_config_file $EXECMODE "deleted"
