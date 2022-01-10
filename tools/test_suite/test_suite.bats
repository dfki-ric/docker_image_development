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

load test_helper

EXEC_MODE="devel"

#for EXEC_MODE in devel release; do

    @test "running exec in $EXEC_MODE mode" {
      result=$(bash $ROOT_DIR/exec.bash $EXEC_MODE whoami)
      echo "DEBUG: $result"
      [ "$(echo $result | tr -d '\r')" == "$EXEC_MODE" ]
    }

#done
