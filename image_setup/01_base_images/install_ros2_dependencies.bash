#!/bin/bash

#install ROS2
export DEBIAN_FRONTEND=noninteractive
export vPYTHON=3
export DISTRO=${1:-foxy}

apt update && apt install -y \
    lsb-release \
    gnupg2 \
    curl \
    python$vPYTHON \
    locales \
    software-properties-common

locale-gen en_US en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

add-apt-repository universe

curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

apt update && apt upgrade -y &&  apt install -y \
    ros-$DISTRO-desktop \
    python$vPYTHON-colcon-common-extensions \
    python$vPYTHON-rosdep \
    python$vPYTHON-rosinstall \
    python$vPYTHON-wstool

#rosdep init && rosdep update

# delete downloaded and installed .deb files to lower image size
apt-get clean
