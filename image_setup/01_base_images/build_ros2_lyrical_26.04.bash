#!/bin/bash
THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $THIS_DIR/build_base_image.bash

export INSTALL_ARGS=lyrical

build_base_image ubuntu:26.04 ros2_lyrical_26.04 install_ros2_dependencies.bash
