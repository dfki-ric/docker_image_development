#!/bin/bash

#requirements for rock-core
export DEBIAN_FRONTEND=noninteractive

apt-get update && apt-get install -y \
 apt-transport-https \
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
 libsdformat6-dev \
 libsigc++-2.0-0v5 \
 libsigc++-2.0-dev \
 libsysfs-dev \
 libtinyxml-dev \
 libusb-dev \
 libv4l-dev \
 libxml-xpath-perl \
 libxml2-dev \
 libyaml-cpp-dev \
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

# delete downloaded and installed .deb files to lower image size
apt-get clean
