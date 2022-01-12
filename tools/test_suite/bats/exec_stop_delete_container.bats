#!/bin/bash
#!/usr/bin/env bats

load test_helper

setup() {
  if !( [ "$EXECMODE" == "base" ] || 
        [ "$EXECMODE" == "devel" ] || 
        [ "$EXECMODE" == "release" ] || 
        [ "$EXECMODE" == "storedrelease" ] || 
        [ "$EXECMODE" == "CD" ]
      ); then
    echo "# [ERROR] unknown execution mode: $EXECMODE" >&3
    exit 1
  fi
}

@test "running exec.bash in $EXECMODE mode" {
  run bash $ROOT_DIR/exec.bash $EXECMODE whoami

  if [ "$EXECMODE" == "base" ]; then
    user="devel"
    IMAGE=$WORKSPACE_BASE_IMAGE
  elif [ "$EXECMODE" == "devel" ]; then
    user="devel"
    IMAGE=$WORKSPACE_DEVEL_IMAGE
  elif [ "$EXECMODE" == "release" ]; then
    user="release"
    IMAGE=$WORKSPACE_RELEASE_IMAGE
  elif [ "$EXECMODE" == "storedrelease" ]; then
    user="release"
  elif [ "$EXECMODE" == "CD" ]; then
    user="release"
  else
    echo "# [ERROR] unknown execution mode: $EXECMODE" >&3
    exit 1
  fi

  [ "$status" -eq 0 ]
  [ "$(echo ${lines[-1]} | tr -d '\r')" == "$user" ]
  docker container ls | grep --silent $CONTAINER_NAME
  [ "$?" -eq 0 ]
  docker container ls | grep "$CONTAINER_NAME" | grep --silent "$IMAGE"
  [ "$?" -eq 0 ]
}

@test "running stop.bash in $EXECMODE mode" {
  run bash $ROOT_DIR/stop.bash $EXECMODE
  [ "$status" -eq 0 ]
  [ "${lines[1]}" == "$CONTAINER_NAME" ]
  docker container ls | grep --silent -v "$CONTAINER_NAME"
  [ "$?" -eq 0 ]
  docker container ls -a | grep --silent "$CONTAINER_NAME"
  [ "$?" -eq 0 ]
  docker container ls -a | grep "$CONTAINER_NAME" | grep --silent "$IMAGE"
  [ "$?" -eq 0 ]
}

@test "running delete_container.bash in $EXECMODE mode" {
  run bash $ROOT_DIR/delete_container.bash $EXECMODE
  [ "$status" -eq 0 ]
  docker container ls -a | grep --silent -v $CONTAINER_NAME
  [ "$?" -eq 0 ]
}
