#!/bin/bash

# In this file you can add a script that intitializes your workspace

# stop on errors
set -e



# In this file you can add a script that intitializes your workspace

# ROCK BUILDCONF EXAMPLE
#
#if [ ! -f /opt/workspace/env.sh ]; then
#    echo -e "\e[32m[INFO] First start: setting up the workspace.\e[0m"
#
#    # go to workspace dir
#    cd /opt/workspace/
#
#    # set git config
#    git config --global user.name "Image Builder"
#    git config --global user.email "image@builder.me"
#    git config --global credential.helper cache
#
#    # setup ws using autoproj
#    wget rock-robotics.org/autoproj_bootstrap
#    ruby autoproj_bootstrap git <BUILDCONF_URL> branch=master
#    source env.sh
#    aup
#    amake
#
#    echo -e "\e[32m[INFO] workspace successfully initialized.\e[0m"
#else 
#    echo -e "\e[31m[ERROR] workspace already initialized.\e[0m"
#    exit 1
#fi

# ROS BUILDCONF EXAMPLE
#
## add /opt/startscritps to path, you need to do it here, because /home/devel is a mounted folder
#echo 'export PATH=${PATH}:/opt/startscripts' | sudo tee -a /home/devel/.bashrc > /dev/null
#if [ ! -d /opt/workspace/src ]; then
#    echo "first start: setting up workspace"
#    mkdir -p /opt/workspace/src
#    cd /opt/workspace/
#    #source /opt/setup_env.sh
#    source /opt/ros/melodic/setup.bash
#    catkin init && catkin build
#
#    echo "[INFO] Setting up workspace with autoproj."
#    cd /opt/workspace/src
#    wget https://rock-robotics.org/autoproj_bootstrap
#    git config --global user.name "Image Builder"
#    git config --global user.email "image@builder.me"
#    git config --global credential.helper cache
#    ruby autoproj_bootstrap git <BUILDCONF_URL> branch=master
#    . env.sh
#    aup
#    cd /opt/workspace
#    echo
#    echo "workspace initialized, please"
#    echo "source devel/setup.bash"
#    echo "catkin build"
#    echo
#else
#    echo "[ERROR] Workspace is already initialized (/opt/workspace/src already exists)."
#fi
