#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/.docker_scripts/variables.bash

command -v xpra > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
    echo -e "Please install xpra:\n    sudo apt install xpra" && exit 13
fi
xpra attach --sharing=yes tcp:127.0.0.1:$XPRA_PORT
