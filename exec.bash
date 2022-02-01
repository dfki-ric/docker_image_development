#!/bin/bash

#allow local connections of root (docker daemon) to the current users x server
if command -v xhost > /dev/null; then
    xhost +local:root > /dev/null
fi

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/docker_commands.bash
source $ROOT_DIR/.docker_scripts/variables.bash
source $ROOT_DIR/.docker_scripts/exec.bash

init_docker $@

# remove permission for local connections of root (docker daemon) to the current users x server
if command -v xhost > /dev/null; then
    xhost -local:root > /dev/null
fi

#set by $ROOT_DIR/.docker_scripts/exec.bash
exit $DOCKER_EXEC_RETURN_VALUE
