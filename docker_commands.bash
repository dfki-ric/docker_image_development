#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $ROOT_DIR/settings.bash

DNSIP=$(nmcli dev show | grep 'IP4.DNS' | grep "\[1\]" | egrep -oe "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}" | head -n 1)

init_docker(){

    #detect if nvidia runtime is available
    RUNTIMES=$(docker info | grep "Runtimes:")
    if [[ $RUNTIMES == *"nvidia"* ]]; then
        echo "has nvidia runtime"
        RUNTIME_ARG="--runtime=nvidia"
    else
        echo "deprecated nvidia-docker2 hardware acceleration not available, testing newer docker --gpu setting"
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
        echo "docker supports --gpu setting, hardware acceleration enabled"
        RUNTIME_ARG="--gpus all"
    else
        echo "hardware acceleration disabled"
    fi

    if [ "$1" = "noninteractive" ]; then
        INTERACTIVE="false"
        #remove first param
        shift
    fi

    # check if a container from previous runs exist
    if [ "$(docker ps -a | grep $CONTAINER_NAME)" ]; then
        #check if the local image is newer that the one the container was created with
        #generate_container saves the current id to a file
        echo "found existing container"
        if [ "$CURRENT_IMAGE_ID" = "$CONTAINER_IMAGE_ID" ]; then
            echo "using existent container"
            if [ "$INTERACTIVE" = "true" ]; then
                start_container $@
            else
                start_container_nonint $@
            fi
        else
            echo "image id is newer that container image id, removing old container:"
            #stop the container in case it is running
            docker stop $CONTAINER_NAME
            docker rm $CONTAINER_NAME
            if [ "$INTERACTIVE" = "true" ]; then
                generate_container $@
            else
                generate_container_nonint $@
            fi
        fi
    else
        echo "inital run, no container exists"
        if [ "$INTERACTIVE" = "true" ]; then
            generate_container $@
        else
            generate_container_nonint $@
        fi
    fi
}


#generate container and start command given ad paramater
generate_container(){
    echo "generating new container : $CONTAINER_NAME"
    echo $CURRENT_IMAGE_ID > $CONTAINER_ID_FILENAME

    #initial run exits no matter what due to entrypoint (user id settings)
    #/bin/bash will be default nonetheless when called later without command
    docker run -ti $RUNTIME_ARG $DOCKER_RUN_ARGS $IMAGE_NAME || exit 1
    # default container exists after initial run

    echo "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME
    echo "running /opt/check_init_workspace.bash in $CONTAINER_NAME"
    docker exec -ti $CONTAINER_NAME /opt/check_init_workspace.bash
    echo "running $@ in $CONTAINER_NAME"
    docker exec -ti $CONTAINER_NAME $@
}

#starts container with the param given in first run
start_container(){
    echo "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME
    echo "running $@ in $CONTAINER_NAME"
    docker exec -ti $CONTAINER_NAME $@
}

generate_container_nonint(){
    echo "generating new non-interactive container with $@"
    echo $CURRENT_IMAGE_ID > $CONTAINER_ID_FILENAME

    docker run -t $RUNTIME_ARG $DOCKER_RUN_ARGS $IMAGE_NAME $@
    
    # default container exists after initial run
    start_container_nonint $@
}

#starts container with the param given in first run
start_container_nonint(){
    echo "docker start non-interactive $CONTAINER_NAME"
    docker start -a $CONTAINER_NAME
}
