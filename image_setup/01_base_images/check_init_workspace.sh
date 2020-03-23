#!/bin/bash

#set initialite workspace of derived images
#derived images may add own scripts to workspace init like this
# ADD my_workspace_init_script.sh /opt/my_workspace_init_script.sh
# RUN chmod 755 /opt/my_workspace_init_script.sh
# RUN echo "/opt/my_workspace_init_script.sh" >> /opt/init_workspace.sh

if [ ! -f /initialized_workspace ]; then
    #only executed on container creation
    sudo touch /initialized_workspace
    /opt/init_workspace.bash
fi

