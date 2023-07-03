#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/docker_commands.bash
source $ROOT_DIR/.docker_scripts/exec.bash

#allow local connections of root (docker daemon) to the current users x server
if [ "$DOCKER_XSERVER_TYPE" = "mount" ] && command -v xhost > /dev/null; then
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        # this is an ssh shell
        xterm -e "xhost +local:root"
    else
        xhost +local:root > /dev/null
    fi
fi



init_docker $@

# remove permission for local connections of root (docker daemon) to the current users x server
if [ "$DOCKER_XSERVER_TYPE" = "mount" ] && command -v xhost > /dev/null; then
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        # this is an ssh shell
        xterm -e "xhost -local:root"
    else
        xhost -local:root > /dev/null
    fi
fi

# set by $ROOT_DIR/.docker_scripts/exec.bash
exit $DOCKER_EXEC_RETURN_VALUE