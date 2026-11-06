#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/file_handling.bash
source $ROOT_DIR/.docker_scripts/variables.bash
source $ROOT_DIR/settings.bash

# stop on error
set -e

evaluate_execmode $1

set_container_name
find_container_compose_project

$PRINT_INFO "stopping ${CONTAINER_NAME}"
if [ -n "$CONTAINER_COMPOSE_PROJECT" ]; then
    # removes the container, additional services of its compose project and the network
    docker compose -p ${CONTAINER_COMPOSE_PROJECT} down
else
    # container was created before exec.bash used docker compose
    docker stop ${CONTAINER_NAME} > /dev/null || true
    docker rm ${CONTAINER_NAME} > /dev/null
fi
$PRINT_INFO "successfully removed ${CONTAINER_NAME}"
write_value_to_config_file $EXECMODE "deleted"
