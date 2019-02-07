#!/bin/bash

#this file is added to the entrypoint by a guard ans called from entrypoint
#todo: add before exec or bashrc? -> /opt/setup_env.sh
# /opt/workspace/src is existing in a workspace, so we test for that folder
if [ ! -d /opt/workspace/src ]; then
    echo "first start: setting up mare-it-workspace"
    cd /opt/workspace
    mkdir -p src
    cat /opt/setup_env.sh
    source /opt/setup_env.sh
    catkin init && catkin build
    # the /opt/setup_env.sh is copied later in the entypoint, so we need to
    # write /opt/setup_env.sh here instead of /home/devel/setup_env.sh
    echo "source /opt/workspace/devel/setup.bash" | sudo tee -a /opt/setup_env.sh > /dev/null

    echo "cloning repositories"
    cd src
    git config --global credential.helper cache
    git clone https://git.hb.dfki.de/models-environments/offshore_field
    git clone https://git.hb.dfki.de/models-robots/cuttlefish
    cd /opt/workspace

    echo "Initial build"
    catkin build

fi

