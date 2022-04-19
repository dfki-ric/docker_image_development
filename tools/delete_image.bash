#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/variables.bash

evaluate_execmode $1
set_image_name $EXECMODE

bash $ROOT_DIR/delete_container.bash $EXECMODE
docker rmi $IMAGE_NAME
