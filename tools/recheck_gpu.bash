#!/bin/bash

VERBOSE=true

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/docker_commands.bash

check_gpu
