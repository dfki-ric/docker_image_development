#!/bin/bash

# this script will be called by .bashrc

# $PRINT_DEBUG is set later by the docker run command in docker_commands.bash or by the enrtypoint

# on initialization check if the UID of the rosuser user has to be changed:
if [ "$NUID" -a ! -f /initialized_uid ]; then
    if [ "$NUID" != "$(id -u devel)" ]; then
        $PRINT_DEBUG "UID is going to be changed from $(id -u devel) to $NUID"
        # if group id is given also:
        if [ "$NGID" ]; then
            $PRINT_DEBUG "GID is going to be changed from $(id -g devel) to $NGID"
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
        chown -R devel:devel-group /home/devel
        $PRINT_DEBUG -e "\n \033[0;32m EXITING THE CONTAINER PLEASE RELOGIN ! \n(using \"docker start -ai <containername>\")\e[0m"
    else
        $PRINT_DEBUG "UID did not need to be changed"
    fi
fi

#indicate theat the initialization was done
if [ ! -f /initialized_uid ]; then
    touch "/initialized_uid"
fi
