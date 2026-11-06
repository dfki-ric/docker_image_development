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

# docker-compose.exec.bash.yml is extended by the files in .docker_scripts/compose/ depending on exec mode and settings
if [ "$EXECMODE" = "base" ] || [ "$EXECMODE" = "devel" ]; then
    # in case the devel image is pulled, we need the create the folders here
    mkdir -p $ROOT_DIR/workspace
    mkdir -p $ROOT_DIR/home
    add_compose_file execmode_$EXECMODE
    if [ "$MOUNT_CCACHE_VOLUME" = "true" ]; then
        export CCACHE_VOLUME_NAME="ccache_${WORKSPACE_BASE_IMAGE//[\/,:]/_}"
        $PRINT_INFO "mounting ccache volume ${CCACHE_VOLUME_NAME} to /ccache"
        docker volume create $CCACHE_VOLUME_NAME > /dev/null
        add_compose_file ccache
    fi
fi

if [ "$EXECMODE" = "stored" ]; then
    # Read image name from command line, first arg already shifted away
    set_stored_image_name $1
    shift
fi

# generating the standalone compose file does not need the image
if [ "$DOCKER_REGISTRY_AUTOPULL" = true ] && [ "$GENERATING_STANDALONE_COMPOSE" != true ]; then
    $PRINT_INFO
    $PRINT_INFO pulling image: $IMAGE_NAME
    $PRINT_INFO
    docker pull $IMAGE_NAME
fi

# this flag defines if an interactive container (console inputs) is created or not
# if env already set, use external set value
# you can use this if your console does not support inputs (e.g. a jenkins build job)
INTERACTIVE=${INTERACTIVE:="true"}

# use current folder name + execmode + path md5 as container name
# (several checkouts  of this repo possible withtout interfering)
set_container_name

$PRINT_INFO
$PRINT_INFO -e "\e[32musing ${IMAGE_NAME%:*}:\e[4;33m${IMAGE_NAME##*:}\e[0m"
$PRINT_INFO
$PRINT_DEBUG $CMD_STRING
$PRINT_DEBUG

CONTAINER_IMAGE_ID=$(read_value_from_config_file $EXECMODE)
CURRENT_IMAGE_ID=$(docker inspect --format '{{.Id}}' $IMAGE_NAME)

# check which xserver type should be used and add the compose file accordingly
set_xserver_compose_files

check_git_post_merge_hook_exists
