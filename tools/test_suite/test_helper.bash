#!/usr/bin/env bats

############################################# PREPARE #
# check if containers exist and are running => prompt for deletion

# following routine for: base, devel, release, CD
# check if correct image is loaded/deleted/stopped
# check if container is actually stopped?
# stop running containers => check return value
# delete running containers => check return value
# check if container is actually deleted?
# run command in exec => check return value
# delete container => check return value

# create, run and remove stored release => check return values

bats --version > /dev/null 2>&1
if [ "$?" != "0" ]; then
    echo "[ERROR] bats is not installed."
    echo "        please execute: sudo apt install bats -y"
    exit
fi

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
EXEC_MODE="base"
export SILENT=true
