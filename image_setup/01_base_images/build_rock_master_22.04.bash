#!/bin/bash
THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $THIS_DIR/build_base_image.bash

build_base_image nvidia/opengl:1.2-glvnd-devel-ubuntu22.04 rock_master_22.04 install_rock_22.04_dependencies.bash
