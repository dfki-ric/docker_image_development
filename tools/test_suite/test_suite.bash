#!/bin/bash

set -e

####################################################################### PREPARATION ###
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
TEST_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/variables.bash

check_container_existance(){
    CONTAINER_NAME="${ROOT_DIR##*/}-$EXECMODE-$FOLDER_MD5"
    docker container ls -a | grep --silent $CONTAINER_NAME && return=$? || return=$?
    if [ "$return" -eq 0 ]; then
        echo "[WARN] The container $CONTAINER_NAME exists and might still be running."
        echo "       In order to run the test suite, the container needs to be stopped and deleted."
        echo
        read -p "    => stop and delete $CONTAINER_NAME? (Y/N): " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            echo
            bash $ROOT_DIR/delete_container.bash $EXECMODE
            echo
        else
            exit 1
        fi
    fi
}

######################################################################## TEST SUITE ###
export EXECMODE="base"
check_container_existance $EXECMODE
bats $TEST_DIR/bats/exec_stop_delete_container.bats
echo

export EXECMODE="devel"
check_container_existance $EXECMODE
bats $TEST_DIR/bats/exec_stop_delete_container.bats
echo

export EXECMODE="release"
check_container_existance $EXECMODE
bats $TEST_DIR/bats/exec_stop_delete_container.bats
echo

#bats $TEST_DIR/bats/check_version_warning.bats
