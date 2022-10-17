#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/variables.bash
source $ROOT_DIR/.docker_scripts/file_handling.bash

#storage variable for the return value of the docker exec command
DOCKER_EXEC_RETURN_VALUE=1

check_run_args_changed(){
    CURRENT_RUN_ARGS=$(echo $DOCKER_RUN_ARGS $DOCKER_XSERVER_ARGS | md5sum | cut -b 1-32)
    OLD_RUN_ARGS=$(read_value_from_config_file RUN_ARGS_${EXECMODE})
    if [ "$OLD_RUN_ARGS" != "$CURRENT_RUN_ARGS" ]; then
        write_value_to_config_file "RUN_ARGS_${EXECMODE}" "$CURRENT_RUN_ARGS"
        RUN_ARGS_CHANGED=true
    else
        RUN_ARGS_CHANGED=false
    fi
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
        check_run_args_changed
        if [ "$RUN_ARGS_CHANGED" = "false" ] && [ "$CURRENT_IMAGE_ID" = "$CONTAINER_IMAGE_ID" ]; then
            $PRINT_DEBUG "using existing container"
            start_container $@
        else
            $PRINT_INFO "Image or run arguments changed, renewing container: $CONTAINER_NAME"
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

# check if iceccd is running on the host, start in container if not running
check_iceccd(){
    if [ "${USE_ICECC}" == "true" ] && [ "$EXECMODE" = "devel" ]; then
        ICECCD_PID=$(pidof iceccd)
        if [ "${ICECCD_PID}" == "" ]; then
            # no iceccd running on system
            docker exec $CONTAINER_NAME sudo service iceccd start
            write_value_to_config_file "CONTAINER_ICECCD_PID" $(pidof iceccd)
        else
            # iceccd already running on system
            CONTAINER_ICECCD_PID=$(read_value_from_config_file CONTAINER_ICECCD_PID)
            if [ "${CONTAINER_ICECCD_PID}" != "${ICECCD_PID}" ]; then
                echo -e "\nThere is already and iceccd instance running on this system, icecc is disabled in this container\n"
            fi
        fi
    fi
}

check_xpra(){
    if [ "$DOCKER_XSERVER_TYPE" = "xpra" ]; then
        $PRINT_INFO "using xpra server: xpra start :$XPRA_PORT --sharing=yes --bind-tcp=0.0.0.0:$XPRA_PORT"
        $PRINT_INFO -e "\nRemember to start the xpra client on your PC:\n    bash xpra_attach.bash"
        docker exec $CONTAINER_NAME /bin/bash -c 'xpra start $DISPLAY --sharing=yes --bind-tcp=0.0.0.0:$XPRA_PORT 2> /dev/null && echo'
    fi
}

set_xserver_args(){
    DOCKER_XSERVER_ARGS=""
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
      IS_SSH_TERMINAL=true
    fi
    
    if [ -z "$DOCKER_XSERVER_TYPE" ]; then
        $PRINT_INFO "DOCKER_XSERVER_TYPE is undefined. Using auto as default."
        DOCKER_XSERVER_TYPE="auto"
    fi
    
    if [ "$DOCKER_XSERVER_TYPE" = "auto" ]; then
        if [ -n "$IS_SSH_TERMINAL" ]; then
            $PRINT_INFO "exec.bash was executed in ssh terminal, using xpra for X Apps"
            DOCKER_XSERVER_TYPE=xpra
        else
            $PRINT_INFO "exec.bash was executed in local terminal, using mount for X Apps"
            DOCKER_XSERVER_TYPE=mount
        fi
    fi
    
    if [ "$DOCKER_XSERVER_TYPE" = "mount" ]; then
        DOCKER_XSERVER_ARGS="-e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix"
    fi
    
    if [ "$DOCKER_XSERVER_TYPE" = "xpra" ]; then
        DOCKER_XSERVER_ARGS="-e USE_XPRA=true -e DISPLAY=:10000 -e XPRA_PORT"
    fi
}

#generate container and start command given ad paramater
generate_container(){
    $PRINT_DEBUG "generating new container : $CONTAINER_NAME"
    write_value_to_config_file $EXECMODE $CURRENT_IMAGE_ID

    # special treatement for ccache as empty string might cause compiler error
    if [ $MOUNT_CCACHE_VOLUME ]; then
        $PRINT_DEBUG "Adding -e CCACHE_DIR to DOCKER_RUN_ARGS"
        DOCKER_RUN_ARGS="$DOCKER_RUN_ARGS -e CCACHE_DIR=${DOCKER_DEV_CCACHE_DIR}"
    fi

    #initial run exits no matter what due to entrypoint (user id settings)
    #/bin/bash will be default nonetheless when called later without command
    docker run $DOCKER_FLAGS $RUNTIME_ARG $DOCKER_RUN_ARGS $DOCKER_XSERVER_ARGS \
                    -e SCRIPTSVERSION=${SCRIPTSVERSION} \
                    -e PRINT_WARNING=${PRINT_WARNING} \
                    -e PRINT_INFO=${PRINT_INFO} \
                    -e PRINT_DEBUG=${PRINT_DEBUG} \
                    -e PROJECT_NAME=${PROJECT_NAME} \
                    -e EXECMODE=${EXECMODE} \
                    $IMAGE_NAME || exit 1
    # default container exists after initial run

    $PRINT_DEBUG "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME  > /dev/null
    $PRINT_DEBUG "running /opt/check_init_workspace.bash in $CONTAINER_NAME"
    docker exec $DOCKER_FLAGS $CONTAINER_NAME /opt/check_init_workspace.bash
    $PRINT_DEBUG "check if iceccd needs to be started $CONTAINER_NAME"
    check_iceccd
    $PRINT_DEBUG "check if xpra needs to be started $CONTAINER_NAME"
    check_xpra
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    docker exec $DOCKER_FLAGS $CONTAINER_NAME $@
    DOCKER_EXEC_RETURN_VALUE=$?
}

#starts container with the param given in first run
start_container(){
    $PRINT_DEBUG "docker start $CONTAINER_NAME"
    docker start $CONTAINER_NAME > /dev/null
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    $PRINT_DEBUG "check if iceccd needs to be started $CONTAINER_NAME"
    check_iceccd
    $PRINT_DEBUG "check if xpra needs to be started $CONTAINER_NAME"
    check_xpra
    $PRINT_DEBUG "running $@ in $CONTAINER_NAME"
    docker exec $DOCKER_FLAGS $CONTAINER_NAME $@
    DOCKER_EXEC_RETURN_VALUE=$?
}
