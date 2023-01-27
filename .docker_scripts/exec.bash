#!/bin/bash

CMD_STRING=""

### EVALUATE ARGUMENTS AND SET EXECMODE
EXECMODE=$1
if [[ " ${EXECMODES[*]} " =~ " $EXECMODE " ]]; then
    $PRINT_WARNING "overriding default execmode $DEFAULT_EXECMODE to: $EXECMODE"
    shift
else
    EXECMODE=$DEFAULT_EXECMODE
fi

### EVALUATE REMAINING ARGUMENTS OR SET TO DEFAULT
if [ -z "$1" ]; then
    CMD_STRING="No run argument given. Executing: /bin/bash"
    set -- "/bin/bash"
elif [ "$1" = "write_osdeps" ]; then
    CMD_STRING="Executing: /opt/write_osdeps.bash"
    set -- "/opt/write_osdeps.bash"
else 
    CMD_STRING="Executing: $1"
fi

### START EXECUTION
set_image_name $1

if [ "$EXECMODE" == "base" ]; then
    mkdir -p $ROOT_DIR/workspace
    mkdir -p $ROOT_DIR/home
    ADDITIONAL_DOCKER_MOUNT_ARGS=" \
        -v $ROOT_DIR/workspace/:/opt/workspace \
        -v $ROOT_DIR/home/:/home/dockeruser \
        -v $ROOT_DIR/image_setup/02_devel_image/setup_workspace.bash:/opt/setup_workspace.bash \
        -v $ROOT_DIR/image_setup/02_devel_image/config_seed.yml:/opt/config_seed.yml \
        -v $ROOT_DIR/image_setup/02_devel_image/workspace_os_dependencies.txt:/opt/workspace_os_dependencies.txt \
        -v $ROOT_DIR/image_setup/02_devel_image/list_rock_osdeps.rb:/opt/list_rock_osdeps.rb \
        -v $ROOT_DIR/image_setup/02_devel_image/list_ros_osdeps.bash:/opt/list_ros_osdeps.bash \
        -v $ROOT_DIR/image_setup/02_devel_image/write_osdeps.bash:/opt/write_osdeps.bash \
        "
    if [ "$MOUNT_CCACHE_VOLUME" = "true" ]; then
        DOCKER_DEV_CCACHE_DIR="/ccache"
        CACHE_VOLUME_NAME="ccache_${WORKSPACE_BASE_IMAGE//[\/,:]/_}"
        $PRINT_INFO "mounting ccache volume ${CACHE_VOLUME_NAME} to ${DOCKER_DEV_CCACHE_DIR}"
        docker volume create $CACHE_VOLUME_NAME > /dev/null
        ADDITIONAL_DOCKER_MOUNT_ARGS="$ADDITIONAL_DOCKER_MOUNT_ARGS -v $CACHE_VOLUME_NAME:${DOCKER_DEV_CCACHE_DIR}"
    fi
fi

if [ "$EXECMODE" = "devel" ]; then
    # in case the devel image is pulled, we need the create the folders here
    mkdir -p $ROOT_DIR/workspace
    mkdir -p $ROOT_DIR/home
    ADDITIONAL_DOCKER_MOUNT_ARGS=" \
        -v $ROOT_DIR/startscripts:/opt/startscripts \
        -v $ROOT_DIR/workspace/:/opt/workspace \
        -v $ROOT_DIR/home/:/home/dockeruser \
        -v $ROOT_DIR/image_setup/02_devel_image/workspace_os_dependencies.txt:/opt/workspace_os_dependencies.txt \
        -v $ROOT_DIR/image_setup/02_devel_image/list_rock_osdeps.rb:/opt/list_rock_osdeps.rb \
        -v $ROOT_DIR/image_setup/02_devel_image/list_ros_osdeps.bash:/opt/list_ros_osdeps.bash \
        -v $ROOT_DIR/image_setup/02_devel_image/write_osdeps.bash:/opt/write_osdeps.bash \
        "
    if [ "$MOUNT_CCACHE_VOLUME" = "true" ]; then
        DOCKER_DEV_CCACHE_DIR="/ccache"
        CACHE_VOLUME_NAME="ccache_${WORKSPACE_BASE_IMAGE//[\/,:]/_}"
        $PRINT_INFO "mounting ccache volume ${CACHE_VOLUME_NAME} to ${DOCKER_DEV_CCACHE_DIR}"
        docker volume create $CACHE_VOLUME_NAME > /dev/null
        ADDITIONAL_DOCKER_MOUNT_ARGS="$ADDITIONAL_DOCKER_MOUNT_ARGS -v $CACHE_VOLUME_NAME:${DOCKER_DEV_CCACHE_DIR}"
    fi
    if [ "$USE_ICECC" = "true" ] && [[ "${ADDITIONAL_DOCKER_RUN_ARGS}" != *"--net=host"* ]] && [[ "${ADDITIONAL_DOCKER_RUN_ARGS}" != *"10245:10245"* ]] ; then
        $PRINT_WARNING -e "\e[4;33m\nicecc is enabled but whouldn't be reachable, adding -p 10245:10245 -p 8765:8765/udp to the run args\e[0m\n"
        ADDITIONAL_DOCKER_RUN_ARGS="$ADDITIONAL_DOCKER_RUN_ARGS -p 10245:10245 -p 8765:8765/udp"
    fi
fi

if [ "$EXECMODE" = "storedrelease" ]; then
    # Read image name from command line, first arg already shifted away
    set_stored_image_name $1
    shift
fi

if [ "$DOCKER_REGISTRY_AUTOPULL" = true ]; then
    $PRINT_INFO
    $PRINT_INFO pulling image: $IMAGE_NAME
    $PRINT_INFO
    docker pull $IMAGE_NAME
fi

# this flag defines if an interactive container (console inputs) is created or not
# if env already set, use external set value
# you can use this if your console does not support inputs (e.g. a jenkins build job)
INTERACTIVE=${INTERACTIVE:="true"}

# use current folder name + devel + path md5 as container name
# (several checkouts  of this repo possible withtout interfering)
CONTAINER_NAME=${CONTAINER_NAME:="${ROOT_DIR##*/}-$EXECMODE-$FOLDER_MD5"}

$PRINT_INFO
$PRINT_INFO -e "\e[32musing ${IMAGE_NAME%:*}:\e[4;33m${IMAGE_NAME##*:}\e[0m"
$PRINT_INFO
$PRINT_DEBUG $CMD_STRING
$PRINT_DEBUG

CONTAINER_IMAGE_ID=$(read_value_from_config_file $EXECMODE)
CURRENT_IMAGE_ID=$(docker inspect --format '{{.Id}}' $IMAGE_NAME)

DOCKER_RUN_ARGS=" \
                --name $CONTAINER_NAME \
                -e NUID=$(id -u) -e NGID=$(id -g) \
                -u dockeruser \
                $ADDITIONAL_DOCKER_RUN_ARGS \
                $ADDITIONAL_DOCKER_MOUNT_ARGS \
                "

# check which xserver type should be used and set additional args accordingly
set_xserver_args

check_git_post_merge_hook_exists
