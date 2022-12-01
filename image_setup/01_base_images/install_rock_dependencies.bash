#!/bin/bash

#requirements for rock-core
export DEBIAN_FRONTEND=noninteractive

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
 libqt4-dev \
 libqt4-opengl-dev \
 libqtwebkit-dev \
 libqwt5-qt4-dev \
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
 python-msgpack \
 python-nose \
 python-pexpect \
 qt4-designer \
 qt4-qmake \
 rake \
 ruby \
 ruby-activesupport \
 ruby-dev \
 ruby-thor \
 libsdformat6-dev \
 libtinyxml-dev \
 libyaml-cpp-dev

# delete downloaded and installed .deb files to lower image size
apt-get clean
