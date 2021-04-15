#!/bin/bash

#https://success.docker.com/article/use-a-script-to-initialize-stateful-container-data
#TODO: set ros_core URI // from outside in run script??
#get HOST ip /sbin/ip route|awk '/default/ { print $3 }'


# in clase of legacy scripts using new base images, set it here
if [ -z "$PRINT_INFO" ]; then
    # we expect that in info is neither "echo" or ":", nothing has been set
    echo "Your docker_image_development scripts are outdated, please update (merge) from https://github.com/dfki-ric/docker_image_development"
    echo "WARNING: Verbosity levels disabled, printing everything (as before)"
    export PRINT_DEBUG=echo
    export PRINT_INFO=echo
    export PRINT_WARNING=echo
fi


#set the correct UID from host
if [ ! -f /initialized_container ]; then

    $PRINT_INFO
    $PRINT_INFO -e "\e[33mSetting the containers devel user id to host user id\e[0m"
    $PRINT_INFO
    #only executed by docker run
    sudo touch /initialized_container
    sudo -E /bin/bash /opt/init_user_id.bash
    # id script needs exit to apply uid next docker start, so exiting here
    # the exec script expects this to happen and rund start/exec afterwards
    exit 0
fi

exec "$@"
