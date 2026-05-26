#!/bin/bash
THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $THIS_DIR/build_base_image.bash

build_base_image ubuntu:26.04 rock_master_26.04 install_rock_24.04_dependencies.bash
