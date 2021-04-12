#!/bin/bash

#requirements for rock-core
export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get install -y software-properties-common
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 63BBCC76C6D55B7DF2D65B2A78CB407D3E3D8F94
add-apt-repository -y ppa:rock-core/qt4

apt-get update && apt-get install -y \
 autoconf \
 automake \
 avahi-daemon \
 castxml \
 freeglut3-dev \
 graphviz \
 graphviz-dev \
 libavahi-client-dev \
 libavahi-client3 \
 libavahi-core-dev \
 libboost-dev \
 libboost-filesystem-dev \
 libboost-graph-dev \
 libboost-iostreams-dev \
 libboost-program-options-dev \
 libboost-regex-dev \
 libboost-system-dev \
 libboost-thread-dev \
 libeigen3-dev \
 libjpeg-dev \
 libomniorb4-dev \
 libopencv-dev \
 libopenscenegraph-dev \
 libpoco-dev \
 libsigc++-2.0-0v5 \
 libsigc++-2.0-dev \
 libsysfs-dev \
 libusb-dev \
 libv4l-dev \
 libxml-xpath-perl \
 libxml2-dev \
 omniidl \
 omniorb-nameserver \
 pkg-config \
 python3-msgpack \
 python3-nose \
 python3-pexpect \
 rake \
 ruby \
 ruby-activesupport \
 ruby-dev \
 ruby-thor \
 libsdformat6-dev \
 libtinyxml-dev \
 libyaml-cpp-dev \
 apt-transport-https \
 libqt4-dev \
 libqt4-opengl-dev \
 libqtwebkit-dev \
 qt4-designer \
 qt4-qmake