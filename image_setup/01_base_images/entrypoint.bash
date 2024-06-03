#!/bin/bash

#https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
#TODO: set ros_core URI // from outside in run script??
#get HOST ip /sbin/ip route|awk '/default/ { print $3 }'


IMAGEVERSION=$(cat /opt/VERSION | head -n1 | awk -F' ' '{print $1}')
#SCRIPTSVERSION provided via ENV in run command

IMAGE_MAJOR=$(echo $IMAGEVERSION | awk -F'.' '{print $1}')
IMAGE_MINOR=$(echo $IMAGEVERSION | awk -F'.' '{print $2}')
IMAGE_PATCH=$(echo $IMAGEVERSION | awk -F'.' '{print $3}')
SCRIPTS_MAJOR=$(echo $SCRIPTSVERSION | awk -F'.' '{print $1}')
SCRIPTS_MINOR=$(echo $SCRIPTSVERSION | awk -F'.' '{print $2}')
SCRIPTS_PATCH=$(echo $SCRIPTSVERSION | awk -F'.' '{print $3}')

# if SCRIPTSVERSION is not set at all expect "manual" run from command line/dockerfile etc, no version checks then
if [ -n "$SCRIPTSVERSION" ]; then
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

# The init_user_id.bash change of a uid requires the container to exit, but we don't want that bahavior when running custom commands
# so the CMD in the dockerfile is "init_container" to detect a default start, translated to /bin/bash when no exit is required (already exited once)
# in case docker run is called with a command (or startscript), that one is executed directly

# init_container is the default cmd in the Dockerfile, executed on docker run AND docker start
# this part is executed when the default command is used
if [ "$*" == "init_container" ]; then
    if [ ! -f /initialized_container ]; then
        # only executed by initial docker run, not on docker start
        # releases are creating this file in thrir Dockerfile, so this is not run at all from release images
        sudo touch /initialized_container
        
        $PRINT_INFO
        $PRINT_INFO -e "\e[33mSetting the containers devel user id to host user id\e[0m"
        $PRINT_INFO

        # create ccache dir, if variable set (enabled in settings and CCACHE_DIR set in run command)
        if [ ! -z $CCACHE_DIR ]; then
            sudo mkdir -p $CCACHE_DIR
            # the dockeruser might still have the wrong id, so using the NUID here
            sudo chown $NUID $CCACHE_DIR
        else
            unset CCACHE_DIR
        fi

        # initialize the container, set the correct UID from host
        # use -E to keep env (for PRINT_* environment)
        sudo touch /initial_exit
        sudo -E /bin/bash /opt/init_user_id.bash
        # we need to exit here and not in the next if clause, as sudo cannot be run afterwards
        exit 0
    fi
    if [ ! -f /initial_exit ]; then
        sudo touch /initial_exit
        # even thogh the uid setup is not needed by exec.bash, this initial exit is expected also for releases
        # id script needs exit to apply uid next docker start, so exiting here
        # the exec script expects this to happen and rund start/exec afterwards
        exit 0
    else 
        # subsequent docker start commands should start a console as default
        # exec.bash is using additinal docker exec calls to launch additional programs
        # this just keeps the container running
        exec "/bin/bash"
    fi
fi

# if a non-default cmd is set after docker run, use that one, allows to directly run containers via e.g. docker-compose
# in case a custom command is given (even /bin/bash), you won't have uid setup, but for r.g. releaes you don't need it
eval "$@"
