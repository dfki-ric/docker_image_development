#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/variables.bash

xpra attach --sharing=yes tcp:127.0.0.1:$XPRA_PORT
