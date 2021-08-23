#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. $ROOT_DIR/settings.bash

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

check_config_file_exists(){
    #init config file, if nonexistent
    if [ ! -f .container_config.txt ]; then
        echo "# do not edit, this file is generated and updated automatically when running exec.bash" >> .container_config.txt
    fi
}

write_value_to_config_file(){
    # to be able to write, the value must already exits in the file
    # find old var line
    OLDLINE=$(cat .container_config.txt | grep $1)
    NEWLINE="$1=$2"
    if [ "$OLDLINE" = "" ]; then 
        # new value, just append
        echo "$NEWLINE" >> .container_config.txt
    else
        #value exists, replace line
        sed -i "s/$OLDLINE/$NEWLINE/g" .container_config.txt
    fi
}

read_value_from_config_file(){
    READVARNAME=$1
    echo $(cat .container_config.txt | grep $READVARNAME | awk -F'=' '{print $2}')
}


init_docker(){
    #detect if nvidia runtime is available
    RUNTIMES=$(docker info | grep "Runtimes:")
    if [[ $RUNTIMES == *"nvidia"* ]]; then
        $PRINT_DEBUG "has nvidia runtime"
        RUNTIME_ARG="--runtime=nvidia"
    else
        $PRINT_DEBUG "nvidia-docker2 hardware acceleration not available, also testing docker --gpu setting..."
        RUNTIME_ARG=""
    fi

    #detect if gpus command is supported and working from docker 19.03
    HAS_GPU_SUPPORT=$(read_value_from_config_file has_gpu_support)
    if [ "$HAS_GPU_SUPPORT" = "" ]; then
        docker run --gpus=all --rm $IMAGE_NAME > /dev/null
        HAS_GPU_SUPPORT=$?
        write_value_to_config_file has_gpu_support $HAS_GPU_SUPPORT
    fi

    if [[ $HAS_GPU_SUPPORT = "0" ]]; then
        $PRINT_DEBUG "docker supports --gpu setting, hardware acceleration enabled"
        RUNTIME_ARG="--gpus all"
    else
        $PRINT_WARNING "hardware acceleration disabled"
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
        $PRINT_DEBUG "found existing container"
        if [ "$CURRENT_IMAGE_ID" = "$CONTAINER_IMAGE_ID" ]; then
            $PRINT_DEBUG "using existing container"
            if [ "$INTERACTIVE" = "true" ]; then
                start_container $@
            else
                start_container_nonint $@
            fi
        else
            $PRINT_INFO "Image id is newer that container image id, removing old container: $CONTAINER_NAME"
            #stop the container in case it is running
            docker stop $CONTAINER_NAME  > /dev/null
            docker rm $CONTAINER_NAME  > /dev/null
            if [ "$INTERACTIVE" = "true" ]; then
                generate_container $@
            else
                generate_container_nonint $@
            fi
        fi
    else
        $PRINT_DEBUG "inital run, no container exists"
        if [ "$INTERACTIVE" = "true" ]; then
            generate_container $@
        else
            generate_container_nonint $@
        fi
    fi
}


#generate container and start command given ad paramater
generate_container(){
    $PRINT_DEBUG "generating new container : $CONTAINER_NAME"
    write_value_to_config_file $EXECMODE $CURRENT_IMAGE_ID

    #initial run exits no matter what due to entrypoint (user id settings)
    #/bin/bash will be default nonetheless when called later without command
    docker run -ti $RUNTIME_ARG $DOCKER_RUN_ARGS -e SCRIPTSVERSION=${SCRIPTSVERSION} -e PRINT_WARNING=${PRINT_WARNING} -e PRINT_INFO=${PRINT_INFO} -e PRINT_DEBUG=${PRINT_DEBUG} $IMAGE_NAME || exit 1
    # default container exists after initial run

    $PRINT_DEBUG "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME  > /dev/null
    $PRINT_DEBUG "running /opt/check_init_workspace.bash in $CONTAINER_NAME"
    docker exec -ti $CONTAINER_NAME /opt/check_init_workspace.bash
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    docker exec -ti $CONTAINER_NAME $@
}

#starts container with the param given in first run
start_container(){
    $PRINT_DEBUG "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME > /dev/null
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    docker exec -ti $CONTAINER_NAME $@
}

generate_container_nonint(){
    $PRINT_DEBUG "generating new non-interactive container : $CONTAINER_NAME"
    write_value_to_config_file $EXECMODE $CURRENT_IMAGE_ID

    # initial run exits no matter what -> due to entrypoint (user id settings)
    # /bin/bash will be default nonetheless when called later without command
    docker run -t $RUNTIME_ARG $DOCKER_RUN_ARGS -e SCRIPTSVERSION=${SCRIPTSVERSION} -e PRINT_WARNING=${PRINT_WARNING} -e PRINT_INFO=${PRINT_INFO} -e PRINT_DEBUG=${PRINT_DEBUG} $IMAGE_NAME || exit 1
    # default container exists after initial run, so we can start it
    $PRINT_DEBUG "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME  > /dev/null
    $PRINT_DEBUG "running /opt/check_init_workspace.bash in $CONTAINER_NAME"
    docker exec -t $CONTAINER_NAME /opt/check_init_workspace.bash
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    docker exec -t $CONTAINER_NAME $@
}

#starts container with the param given in first run
start_container_nonint(){
    $PRINT_DEBUG "docker start non-interactive $CONTAINER_NAME"
    docker start $CONTAINER_NAME
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    docker exec $CONTAINER_NAME $@
}
