#!/bin/bash

# In this file you can add a script that intitializes your workspace

# stop on errors
set -e

BUILDCONF=
BRANCH=

if [ ! $1 = "" ]; then
   echo "overriding git credential helper to $1"
   CREDENTIAL_HELPER_MODE=$1
fi

# for Continuous Deployment builds the mode needs to be overridden to be non-interactive
# if set outside this script, use that value, if unset use cache
CREDENTIAL_HELPER_MODE=${CREDENTIAL_HELPER_MODE:="cache"}

# In this file you can add a script that intitializes your workspace

# ROCK BUILDCONF EXAMPLE (non-interactive)
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
#    git config --global credential.helper ${CREDENTIAL_HELPER_MODE}
#
#    # setup ws using autoproj
#    wget rock-robotics.org/autoproj_bootstrap
#    ruby autoproj_bootstrap git $BUILDCONF branch=$BRANCH --seed-config=/opt/config_seed.yml --no-color --no-interactive
#    source env.sh
#    aup --no-color --no-interactive
#    amake
#
#    echo -e "\e[32m[INFO] workspace successfully initialized.\e[0m"
#else 
#    echo -e "\e[31m[ERROR] workspace already initialized.\e[0m"
#    exit 1
#fi

# ROS autoproj BUILDCONF EXAMPLE
#
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
#    ruby autoproj_bootstrap git $BUILDCONF branch=$BRANCH
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


# ROS2 autoproj BUILDCONF EXAMPLE
#
# if [ ! -d /opt/workspace/src ]; then
#    echo "first start: setting up workspace"
#    mkdir -p /opt/workspace/src
#    cd /opt/workspace/
#    #source /opt/setup_env.sh
#    source /opt/ros/humble/setup.bash
#    #init ws
#    colcon build
#    source ./install/setup.bash

#    echo "[INFO] Setting up workspace with autoproj."
#    cd /opt/workspace/src
#    gti clone 
#    wget https://rock-robotics.org/autoproj_bootstrap
#    git config --global user.name "Image Builder"
#    git config --global user.email "image@builder.me"
#    git config --global credential.helper cache
#    ruby autoproj_bootstrap git $BUILDCONF branch=$BRANCH
#    . env.sh
#    aup
#    cd /opt/workspace
#    echo
#    echo "workspace initialized, please"
#    echo "'source ./src/env.sh' and run 'colcon build'"
#    echo
# else
#    echo "[ERROR] Workspace is already initialized (/opt/workspace/src already exists)."
# fi
