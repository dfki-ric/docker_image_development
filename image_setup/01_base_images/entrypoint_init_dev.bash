#!/bin/bash

source /opt/entrypoint_check_versions.bash


# initialize the base and devel container, set the correct UID from host
$PRINT_INFO
$PRINT_INFO -e "\e[33mSetting the containers devel user id to host user id\e[0m"
$PRINT_INFO
#only executed by docker run
sudo touch /initialized_container

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


# The init_user_id.bash change of a uid requires the container to exit, but we don't want that bahavior when running custom commands
# so the CMD in the dockerfile is "init_container" to detect a default start, translated to /bin/bash when no exit is required (already exited once)
# in case docker run is called with a command (or startscript), that one is executed directly
exit 0

