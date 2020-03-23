#!/bin/bash

#https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
#TODO: set ros_core URI // from outside in run script??
#get HOST ip /sbin/ip route|awk '/default/ { print $3 }'

#set the correct UID from host
if [ ! -f /initialized_container ]; then
    #only executed by docker run
    sudo touch /initialized_container
    sudo sh /opt/init_user_id.bash
    #id script needs exit to apply uid nest start

    echo
    echo -e "\e[33mdevel user id set, logging out automatically\e[0m"
    echo "If you want to use this container directly, name it, start it and use docker exec -ti"
    echo

    #entrypoit is only executed on docker run, exit here
    exit 0
fi

exec "$@"
