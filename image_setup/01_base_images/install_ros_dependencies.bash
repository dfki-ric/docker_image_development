#!/bin/bash

#install ROS melodic (second install because needs gnupg)
export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get install -y \
    lsb-release \
    gnupg2 \
    gosu \
    ruby \
    ruby-dev \
    python

sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
apt-get update && apt-get install -y \
    ros-melodic-desktop \
    ros-melodic-viz \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool \
    python-rosdep \
    python-catkin-tools


rosdep init && rosdep update


