#!/bin/bash

# this script will be called by .bashrc

# $PRINT_DEBUG is set later by the docker run command in docker_commands.bash or by the entrypoint

# on initialization check if the UID of the rosuser user has to be changed:
if [ "$NUID" -a ! -f /initialized_uid ]; then
    if [ "$NUID" != "$(id -u dockeruser)" ]; then
        $PRINT_DEBUG "UID is going to be changed from $(id -u dockeruser) to $NUID"
        # if group id is given also:
        if [ "$NGID" ]; then
            $PRINT_DEBUG "GID is going to be changed from $(id -g dockeruser) to $NGID"
            sed s/"x:1000"/"x:$NUID"/ /etc/passwd > /temp
            mv /temp /etc/passwd
            sed s/"1000::"/"$NGID::"/ /etc/passwd > /temp
            mv /temp /etc/passwd
            chmod 644 /etc/passwd
        else # if no new group id is given just change UID:
            sed s/"x:1000"/"x:$NUID"/ /etc/passwd > /temp
            mv /temp /etc/passwd
            chmod 644 /etc/passwd
        fi
        # change ownerchip to new UID and GID
        chown -R dockeruser:dockeruser-group /home/dockeruser
        $PRINT_DEBUG -e "\n \033[0;32m EXITING THE CONTAINER PLEASE RELOGIN ! \n(using \"docker start -ai <containername>\")\e[0m"
    else
        $PRINT_DEBUG "UID did not need to be changed"
    fi
fi

if [ "$DOCKER_GROUP_ID" -a ! -f /initialized_docker_gid ]; then
    if [ "$DOCKER_GROUP_ID" != "$(getent group docker | cut -d: -f3)" ]; then
        $PRINT_DEBUG "Docker GID is going to be changed to $DOCKER_GROUP_ID"
        groupadd docker || true
        groupmod -g $DOCKER_GROUP_ID docker
        usermod -aG docker dockeruser
        $PRINT_DEBUG -e "\n \033[0;32m EXITING THE CONTAINER PLEASE RELOGIN ! \n(using \"docker start -ai <containername>\")\e[0m"
    else
        $PRINT_DEBUG "Docker GID  did not need to be changed"
    fi
fi


# indicate that the initialization was done
if [ ! -f /initialized_uid ]; then
    touch "/initialized_uid"
fi
