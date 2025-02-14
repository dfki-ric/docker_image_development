#!/bin/bash
THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $THIS_DIR/build_base_image.bash

build_base_image ubuntu:24.04 ros2_jazzy_24.04 install_ros2_dependencies.bash
