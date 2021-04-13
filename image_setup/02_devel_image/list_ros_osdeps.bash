#!/bin/bash

rosdep install --from-paths src --ignore-src --simulate --reinstall -r -y | awk '{print $6 " "}'
