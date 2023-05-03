#!/bin/bash

echo $1

if [ "$1" == "run" ]; then
    /cloud_slam_server --port $LISTEN_PORT --redis_ip $REDIS_IP --redis_port $REDIS_PORT --neo4j_ip $NEO4J_IP --neo4j_port $NEO4J_PORT
    # exit with error if app fails
    exit 1
fi

exec "$@"
