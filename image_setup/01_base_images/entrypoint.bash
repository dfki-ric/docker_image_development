#!/bin/bash

#https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
#TODO: set ros_core URI // from outside in run script??
#get HOST ip /sbin/ip route|awk '/default/ { print $3 }'

#set the correct UID from host
if [ ! -f /initialized_container ]; then

    echo
    echo -e "\e[33mSetting the containers devel user id to host user id\e[0m"
    echo
    #only executed by docker run
    sudo touch /initialized_container
    sudo sh /opt/init_user_id.bash
    # id script needs exit to apply uid next docker start, so exiting here
    # the exec script expects this to happen and rund start/exec afterwards
    exit 0
fi

exec "$@"
