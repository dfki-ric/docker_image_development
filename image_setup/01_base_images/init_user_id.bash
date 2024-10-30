#!/bin/bash

# this script will be called by .bashrc

# $PRINT_DEBUG is set later by the docker run command in docker_commands.bash or by the entrypoint

# on initialization check if the UID of the rosuser user has to be changed:
if [ "$NUID" -a ! -f /initialized_uid ]; then
    OUID=$(id -u dockeruser)
    if [ "$NUID" != "$OUID" ]; then
        $PRINT_DEBUG "UID is going to be changed from $(id -u dockeruser) to $NUID"
        # delete existing users with NUID, that might be present in the base image
        sed -i /"x:$NUID"/d /etc/passwd
        # if group id is given also:
        if [ "$NGID" ]; then
            $PRINT_DEBUG "GID is going to be changed from $(id -g dockeruser) to $NGID"
            sed -i s/"x:$OUID"/"x:$NUID"/ /etc/passwd
            sed -i s/"$OUID::"/"$NGID::"/ /etc/passwd
            chmod 644 /etc/passwd
        else # if no new group id is given just change UID:
            sed -i s/"x:$OUID"/"x:$NUID"/ /etc/passwd
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
