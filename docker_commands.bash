#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/settings.bash

# In case you are using CD server uses other registries, they can be overridden via env variables
if [ ! "$OVERRIDE_BASE_REGISTRY" = "" ]; then
    export BASE_REGISTRY=$OVERRIDE_BASE_REGISTRY
fi

if [ ! "$OVERRIDE_DEVEL_REGISTRY" = "" ]; then
    export DEVEL_REGISTRY=$OVERRIDE_DEVEL_REGISTRY
fi

if [ ! "$OVERRIDE_RELEASE_REGISTRY" = "" ]; then
    export RELEASE_REGISTRY=$OVERRIDE_RELEASE_REGISTRY
fi


SCRIPTSVERSION=$(cat VERSION | head -n1 | awk -F' ' '{print $1}')

PRINT_WARNING=echo
PRINT_INFO=echo
PRINT_DEBUG=:

if [ "$VERBOSE" = true ] && [ "$SILENT" = true ]; then
    echo "Error: cannot be VERBOSE and SILENT at the same time"
    echo "Edit the settings.bash accordingly or if not set there use unset VERBOSE or unset SILENT in your console"
    exit 1
fi

if [ "$VERBOSE" = true ]; then
    PRINT_WARNING=echo
    PRINT_INFO=echo
    PRINT_DEBUG=echo
fi

if [ "$SILENT" = true ]; then
    PRINT_WARNING=:
    PRINT_INFO=:
    PRINT_DEBUG=:
fi


init_docker(){

    #detect if nvidia runtime is available
    RUNTIMES=$(docker info | grep "Runtimes:")
    if [[ $RUNTIMES == *"nvidia"* ]]; then
        $PRINT_DEBUG "has nvidia runtime"
        RUNTIME_ARG="--runtime=nvidia"
    else
        $PRINT_DEBUG "deprecated nvidia-docker2 hardware acceleration not available, testing newer docker --gpu setting"
        RUNTIME_ARG=""
    fi

    #detect if gpus command is supported and working from docker 19.03
    GPUS_SETTINGS_FILE="$ROOT_DIR/has_gpu_support.txt"
    if [ ! -f $GPUS_SETTINGS_FILE ]; then
        touch $GPUS_SETTINGS_FILE
        docker run --gpus=all --rm $IMAGE_NAME > /dev/null
        GPU_SUPPORTED=$?
        echo "this file contains the gegerated result of testing the docker --gpu setting, 0=enabled, 1=disabled" > $GPUS_SETTINGS_FILE
        echo $GPU_SUPPORTED >> $GPUS_SETTINGS_FILE        
    fi
    HAS_GPU_SUPPORT=$(tail -n1 $GPUS_SETTINGS_FILE)

    if [[ $HAS_GPU_SUPPORT = "0" ]]; then
        $PRINT_DEBUG "docker supports --gpu setting, hardware acceleration enabled"
        RUNTIME_ARG="--gpus all"
    else
        $PRINT_WARNING "hardware acceleration disabled"
    fi

    if [ "$INTERACTIVE" = "true" ]; then
        DOCKER_FLAGS="-ti"
    else
        DOCKER_FLAGS="-t"
    fi

    # check if a container from previous runs exist
    if [ "$(docker ps -a | grep $CONTAINER_NAME)" ]; then
        #check if the local image is newer that the one the container was created with
        #generate_container saves the current id to a file
        $PRINT_DEBUG "found existing container"
        if [ "$CURRENT_IMAGE_ID" = "$CONTAINER_IMAGE_ID" ]; then
            $PRINT_DEBUG "using existing container"
            start_container $@
        else
            $PRINT_INFO "Image id is newer that container image id, removing old container: $CONTAINER_NAME"
            #stop the container in case it is running
            docker stop $CONTAINER_NAME  > /dev/null
            docker rm $CONTAINER_NAME  > /dev/null
            generate_container $@
        fi
    else
        $PRINT_DEBUG "inital run, no container exists"
        generate_container $@
    fi
}

DOCKER_EXEC_RETURN_VALUE=1;

#generate container and start command given ad paramater
generate_container(){
    $PRINT_DEBUG "generating new container : $CONTAINER_NAME"
    echo $CURRENT_IMAGE_ID > $CONTAINER_ID_FILENAME

    #initial run exits no matter what due to entrypoint (user id settings)
    #/bin/bash will be default nonetheless when called later without command
    docker run $DOCKER_FLAGS $RUNTIME_ARG $DOCKER_RUN_ARGS -e SCRIPTSVERSION=${SCRIPTSVERSION} -e PRINT_WARNING=${PRINT_WARNING} -e PRINT_INFO=${PRINT_INFO} -e PRINT_DEBUG=${PRINT_DEBUG} $IMAGE_NAME || exit 1
    # default container exists after initial run

    $PRINT_DEBUG "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME  > /dev/null
    $PRINT_DEBUG "running /opt/check_init_workspace.bash in $CONTAINER_NAME"
    docker exec $DOCKER_FLAGS $CONTAINER_NAME /opt/check_init_workspace.bash
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    docker exec $DOCKER_FLAGS $CONTAINER_NAME $@
    DOCKER_EXEC_RETURN_VALUE=$?
}

#starts container with the param given in first run
start_container(){
    $PRINT_DEBUG "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME > /dev/null
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    docker exec $DOCKER_FLAGS $CONTAINER_NAME $@
    DOCKER_EXEC_RETURN_VALUE=$?
}
