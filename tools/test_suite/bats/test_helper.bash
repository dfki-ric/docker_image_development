#!/bin/bash

bats --version > /dev/null 2>&1
if [ "$?" != "0" ]; then
    echo "[ERROR] bats is not installed."
    echo "        please execute: sudo apt install bats -y"
    exit
fi

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../../.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/variables.bash
CONTAINER_NAME=${CONTAINER_NAME:="${ROOT_DIR##*/}-$EXECMODE-$FOLDER_MD5"}
export SILENT=true
