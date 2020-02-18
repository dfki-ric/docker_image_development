#!/bin/bash

. /opt/workspace/install/setup.bash

rosrun dynamic_reconfigure dynparam load /ControlStationUplink $(find . -name ROSNodeControlledRobotCuttlefish.yaml) &

roslaunch ros_node_controlled_robot controlled_robot.launch && fg

