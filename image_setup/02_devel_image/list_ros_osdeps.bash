#!/bin/bash

source ~/.bashrc

if [ -z $ROS_DISTRO ]; then
    echo -e "\n[ERROR] Please export ROS_DISTRO in your containers ~/.bashrc file\n"
    exit 13
fi

rosdep install --from-paths /opt/workspace/src --ignore-src --simulate --reinstall -r -y | awk '{print $6 " "}'
