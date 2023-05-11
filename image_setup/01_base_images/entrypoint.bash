#!/bin/bash

#https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
#TODO: set ros_core URI // from outside in run script??
#get HOST ip /sbin/ip route|awk '/default/ { print $3 }'


# in clase of legacy scripts using new base images, set it here
if [ -z "$PRINT_INFO" ]; then
    # we expect that in info is neither "echo" or ":", nothing has been set
    echo
    echo "WARNING: Your docker_image_development scripts are outdated, please pull your repo or merge a newer version from https://github.com/dfki-ric/docker_image_development"
    echo -e "\t* docker_image_developent verbosity levels are disabled for ouputs from the image, printing everything (as before)"
    echo
    export PRINT_DEBUG=echo
    export PRINT_INFO=echo
    export PRINT_WARNING=echo
fi

IMAGEVERSION=$(cat /opt/VERSION | head -n1 | awk -F' ' '{print $1}')
#SCRIPTSVERSION provided via ENV in run command

IMAGE_MAJOR=$(echo $IMAGEVERSION | awk -F'.' '{print $1}')
IMAGE_MINOR=$(echo $IMAGEVERSION | awk -F'.' '{print $2}')
IMAGE_PATCH=$(echo $IMAGEVERSION | awk -F'.' '{print $3}')
SCRIPTS_MAJOR=$(echo $SCRIPTSVERSION | awk -F'.' '{print $1}')
SCRIPTS_MINOR=$(echo $SCRIPTSVERSION | awk -F'.' '{print $2}')
SCRIPTS_PATCH=$(echo $SCRIPTSVERSION | awk -F'.' '{print $3}')

# if SCRIPTSVERSION is not set at all, the scripts are too old (but compatible)
if [ -z "$SCRIPTSVERSION" ]; then
    $PRINT_WARNING
    $PRINT_WARNING "WARNING: Your docker_image_development scripts are outdated, please pull your repo or merge a newer version from from https://github.com/dfki-ric/docker_image_development"
    $PRINT_WARNING -e "\t* docker_image_developent Version checks disabled"
    $PRINT_WARNING
else
    if [ "$IMAGEVERSION" != "$SCRIPTSVERSION" ]; then
        $PRINT_DEBUG "Scripts/Image version mismatch"
        # check major versions
        if [ "$IMAGE_MAJOR" -gt "$SCRIPTS_MAJOR" ]; then
            echo
            echo -e "\e[31mError: The image was produced with incompatible scripts\e[0m: Please pull your repo or merge a newer version from from https://github.com/dfki-ric/docker_image_development"
            echo
            exit 0
        else
            if [ "$IMAGE_MINOR" -gt "$SCRIPTS_MINOR" ]; then
                $PRINT_INFO
                $PRINT_INFO "The image was produced with a newer minor scripts version: Consider pulling your repo or merge a newer version from from https://github.com/dfki-ric/docker_image_development"
                $PRINT_INFO
            else
                if [ "$IMAGE_PATCH" -gt "$SCRIPTS_PATCH" ]; then
                    $PRINT_DEBUG
                    $PRINT_DEBUG "The image was produced with a newer patch scripts version: Consider pulling your repo or merge a newer version from from https://github.com/dfki-ric/docker_image_development"
                    $PRINT_DEBUG
                fi
            fi
        fi
        if [ "$IMAGE_MAJOR" -lt "$SCRIPTS_MAJOR" ]; then
            echo
            echo -e "\e[31mError: The image was produced with incompatible scripts version\e[0m: Please update your images"
            echo
            exit 0
        else
            if [ "$IMAGE_MINOR" -lt "$SCRIPTS_MINOR" ]; then
                $PRINT_INFO
                $PRINT_INFO "The image was produced with a lesser minor scripts version: Consider updating your images"
                $PRINT_INFO
            else
                if [ "$IMAGE_PATCH" -lt "$SCRIPTS_PATCH" ]; then
                    $PRINT_DEBUG
                    $PRINT_DEBUG "The image was produced with a lesser patch scripts version: Consider updating your images"
                    $PRINT_DEBUG
                fi
            fi
        fi
    fi
fi


# initialize the base and devel container, set the correct UID from host
if [ ! -f /initialized_container ]; then
    $PRINT_INFO
    $PRINT_INFO -e "\e[33mSetting the containers devel user id to host user id\e[0m"
    $PRINT_INFO
    #only executed by docker run
    sudo touch /initialized_container
    # we initialize the container with an uid and exit once, no need to execute the release version and exit below
    sudo touch /initialized_container_release
    
    # create ccache dir, if variable set (enabled in settings and CCACHE_DIR set in run command)
    if [ ! -z $CCACHE_DIR ]; then
        sudo mkdir -p $CCACHE_DIR
        # the dockeruser might still have the wrong id, so using the NUID here
        sudo chown $NUID $CCACHE_DIR
    else
        unset CCACHE_DIR
    fi

    # use -E to keep env (for PRINT_* environment)
    sudo -E /bin/bash /opt/init_user_id.bash
    # id script needs exit to apply uid next docker start, so exiting here
    # the exec script expects this to happen and rund start/exec afterwards

    exit 0
fi

# initialize the release image
if [ ! -f /initialized_container_release ]; then
    sudo touch /initialized_container_release
    # the release image also has to exit on the initial docker run, it is expected by the docker_commands.bash
    exit 0
fi
exec "$@"
