#!/bin/bash

#install ROS melodic (second install because needs gnupg)
export DEBIAN_FRONTEND=noninteractive

DISTRO=${1:-melodic}
[ $DISTRO == "noetic" ] && export vPYTHON=3

apt-get update && apt-get install -y \
    lsb-release \
    gnupg2 \
    gosu \
    ruby \
    ruby-dev \
    python$vPYTHON

sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
apt-get update && apt-get install -y \
    ros-$DISTRO-desktop \
    python$vPYTHON-catkin-tools \
    python$vPYTHON-osrf-pycommon \
    python$vPYTHON-rosdep \
    python$vPYTHON-rosinstall \
    python$vPYTHON-rosinstall-generator \
    python$vPYTHON-wstool


#rosdep init && rosdep update

# delete downloaded and installed .deb files to lower image size
apt-get clean
