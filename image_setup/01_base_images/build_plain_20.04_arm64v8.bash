#!/bin/bash
THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $THIS_DIR/build_base_image.bash

build_base_image ubuntu:20.04 plain_20.04_arm64v8 install_plain_dependencies.bash linux/arm64

