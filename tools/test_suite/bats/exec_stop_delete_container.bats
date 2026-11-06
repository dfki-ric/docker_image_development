#!/bin/bash
#!/usr/bin/env bats

load test_helper

# runs before each test (each test runs in its own subshell)
setup() {
  if [ "$EXECMODE" == "base" ]; then
    IMAGE=$WORKSPACE_BASE_IMAGE
  elif [ "$EXECMODE" == "devel" ]; then
    IMAGE=$WORKSPACE_DEVEL_IMAGE
  elif [ "$EXECMODE" == "release" ]; then
    IMAGE=$WORKSPACE_RELEASE_IMAGE
  else
    echo "# [ERROR] unknown execution mode: $EXECMODE" >&3
    exit 1
  fi
}

# (negations via "[ ]" only, "! command" does not fail a bats test)

# prints the container id, empty if the container does not exist
container_id() {
  docker ps -aq --filter "name=^/${CONTAINER_NAME}\$"
}

# prints true or false
container_running() {
  docker inspect --format '{{.State.Running}}' $CONTAINER_NAME
}

container_uses_image() {
  docker inspect --format '{{.Config.Image}}' $CONTAINER_NAME | grep --silent "$IMAGE"
}

@test "running exec.bash in $EXECMODE mode" {
  run bash $ROOT_DIR/exec.bash $EXECMODE whoami
  [ "$status" -eq 0 ]
  [ "$(echo ${lines[-1]} | tr -d '\r')" == "dockeruser" ]
  [ "$(container_running)" == "true" ]
  container_uses_image
  # the container is created via docker compose
  [ -n "$(docker inspect --format '{{ index .Config.Labels "com.docker.compose.project" }}' $CONTAINER_NAME)" ]
}

@test "running stop.bash in $EXECMODE mode" {
  run bash $ROOT_DIR/stop.bash $EXECMODE
  [ "$status" -eq 0 ]
  [ -n "$(container_id)" ]
  [ "$(container_running)" == "false" ]
  container_uses_image
}

@test "running delete_container.bash in $EXECMODE mode" {
  run bash $ROOT_DIR/delete_container.bash $EXECMODE
  [ "$status" -eq 0 ]
  [ -z "$(container_id)" ]
}
