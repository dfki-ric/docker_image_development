#!/bin/bash

# set initialize workspace of derived images
# derived images may add own scripts to workspace init like this
# ADD my_workspace_init_script.bash /opt/my_workspace_init_script.bash
# RUN chmod 755 /opt/my_workspace_init_script.bash
# RUN echo "/opt/my_workspace_init_script.bash" >> /opt/init_workspace.bash

if [ ! -f /initialized_workspace ]; then
    # make sure the ~/.bashrc exists and is owned by the new user id set for the container user
    [ -f ~/.bashrc ] || ( sudo touch ~/.bashrc && sudo chown $NUID:$NGID /home/dockeruser/.bashrc )
    # try to find a line defining the PS1 env var for bash
    PS1_LINE=$(cat ~/.bashrc | grep "^export PS1=")
    if [ "$PS1_LINE" = "" ]; then 
        # no PS1 setting in bashrc, setting it
        sudo echo 'export PS1="${EXECMODE}@${PROJECT_NAME}-docker:\w\$ "' >> ~/.bashrc
    fi

    #only executed on container creation
    sudo touch /initialized_workspace
    /opt/init_workspace.bash
fi
