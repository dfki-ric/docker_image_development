#!/bin/bash

cd /opt/workspace
source env.sh
export BASE_LOG_LEVEL="ERROR"
rock-bundle-sel ant_crex_launch
rock-launch -b only_nav_with_ios.cnd