#!/bin/bash

echo $1

if [ "$1" == "run" ]; then
    /cloud_slam_server
    # exit with error if app fails
    exit 1
fi

exec "$@"
