#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/variables.bash

evaluate_execmode $1

set_container_name
find_container_compose_project

$PRINT_INFO "stopping ${CONTAINER_NAME}"
if [ -n "$CONTAINER_COMPOSE_PROJECT" ]; then
    # stops the container and additional services of its compose project
    docker compose -p ${CONTAINER_COMPOSE_PROJECT} stop
else
    # container was created before exec.bash used docker compose
    docker stop ${CONTAINER_NAME}
fi
