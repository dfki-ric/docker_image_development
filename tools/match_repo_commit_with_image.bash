#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/.docker_scripts/variables.bash

evaluate_execmode $1
set_image_name $2

COMMIT_ID=$(docker inspect --format {{.ContainerConfig.Labels.dockerfile_repo_commit}} ${IMAGE_NAME})
echo "checking out ${COMMIT_ID}"

git checkout ${COMMIT_ID}

