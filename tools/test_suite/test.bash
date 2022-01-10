#!/bin/bash
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

EXEC_MODE="base"
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )


export SILENT=true
result=$(bash $ROOT_DIR/exec.bash $EXEC_MODE whoami)
echo "DEBUG: $(echo $result | wc -m)"
echo "DEBUG: $(echo $result | tr -d '\r' | wc -m)"
echo "DEBUG: $(echo "devel" | wc -m)"
echo "DEBUG: $result"

tmp=$(echo $result | tr -d '\r')
echo "DEBUG: $(echo $tmp | wc -m)"
echo "DEBUG: $(echo $tmp | tr -d '\r' | wc -m)"

#if [ "$(echo $result | tr -d '\n')" == "devel" ]; then
#if [ "devel" == "devel" ]; then
if [ "$(echo $result | tr -d '\r')" == "devel" ]; then
  echo "equal"
else
  echo "not"
fi
