#!/bin/bash

echo $1


if [ "$1" == "run" ]; then
    #"run" isn the default cmd in the Dockerfile" so thsi is run when the container is run without paramater
    echo "replace this echo command in the entrypoint.bash to run your application"
    # exit with error if app fails
    exit 1
fi

exec "$@"
