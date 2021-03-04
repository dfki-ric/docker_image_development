ARG BASE_IMAGE_NAME

FROM ${BASE_IMAGE_NAME}

# To avoid some errors when fetching apt-get updates. # See: https://stackoverflow.com/a/35976127 
ENV DEBIAN_FRONTEND=noninteractive

# generic packages to install non-workspace dependencies ( those are added later )
RUN apt-get update && apt-get install -y \
    bash-completion

# setup locale to avoid ASCII conflicts
RUN locale-gen en_US.UTF-8
ENV LANG="en_US.UTF-8"

# make sure SHELL variable is set. Crucial for base/scripts! => moved to setup_workspace.bash
## REMOVE THIS ONCE rock-core PR 173 is merged
ENV SHELL="/bin/bash"

# add workspace init to container initialization
ADD setup_workspace.bash /opt/setup_workspace.bash
RUN chmod 755 /opt/setup_workspace.bash

# add the dependency list to the image
ADD workspace_os_dependencies.txt /opt/installed_workspace_os_dependencies.txt
# install dependencies from the list
RUN grep -vE '^#' /opt/installed_workspace_os_dependencies.txt | xargs sudo apt install -y

# opt/init_workspace.sh is run once via dockercommands.sh by calling check_init_workspace.sh
RUN echo "echo" >> /opt/init_workspace.bash
RUN echo 'echo -e "\e[32mplease run /opt/setup_workspace.bash to initialize the workspace\e[0m"' >> /opt/init_workspace.bash
RUN echo "echo" >> /opt/init_workspace.bash

# If you want to run the setup automatically, you can add it directly to the script
# it is executed every time the container is re-created
#RUN echo "/opt/setup_workspace.sh" >> /opt/init_workspace.sh







