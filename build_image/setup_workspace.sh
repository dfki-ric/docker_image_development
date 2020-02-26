#!/bin/bash

    
    echo "first start: setting up mare-it-workspace"

    mkdir -p /opt/workspace/src
    cd /opt/workspace/

    #source /opt/setup_env.sh
    source /opt/ros/melodic/setup.bash 
    catkin init && catkin build



    echo 'export PATH=${PATH}:/opt/startscripts' | sudo tee -a /home/devel/.bashrc > /dev/null

    echo "[INFO] Setting up mare-it-workspace with autoproj."
    mkdir /opt/workspace/src
    cd /opt/workspace/src
    wget https://rock-robotics.org/autoproj_bootstrap
    git config --global credential.helper cache
    ruby autoproj_bootstrap git https://git.hb.dfki.de/mare-it/buildconf
    . env.sh
    aup
    cd ..


    echo 
    echo "workspace initialized, please"
    echo "source devel/setup.bash"
    echo "catkin build"
    echo

