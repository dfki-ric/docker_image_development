#!/bin/bash

cd /opt/workspace

if [ -d .autoproj ]; then
    echo "detected autoproj workspace"
    ruby /opt/list_rock_osdeps.rb > /opt/workspace_os_dependencies.txt
fi

if [ -f .rosinstall ]; then
    echo "detected ros workspace managed autoproj"
    bash /opt/list_ros_osdeps.bash > /opt/workspace_os_dependencies.txt
fi
