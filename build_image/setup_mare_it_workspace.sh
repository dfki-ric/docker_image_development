#!/bin/bash

#this file is added to the entrypoint by a guard ans called from entrypoint
#todo: add before exec or bashrc? -> /opt/setup_env.sh
if [ ! -f /initialized_mare-it-workspace ]; then
    echo "setting up mare-it-workspace"
    cd /opt/workspace
    source /opt/setup_env.sh
    mkdir -p src
    catkin_make
    # the /opt/setup_env.sh is copied later in the entypoint, so we need to
    # write /opt/setup_env.sh here instead of /home/devel/setup_env.sh
    echo "source /opt/workspace/devel/setup.sh" | sudo tee -a /opt/setup_env.sh > /dev/null
fi

