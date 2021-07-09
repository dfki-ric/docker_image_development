ARG BASE_IMAGE_NAME

FROM ${BASE_IMAGE_NAME}

# To avoid some errors when fetching apt-get updates. # See: https://stackoverflow.com/a/35976127 
ENV DEBIAN_FRONTEND=noninteractive

# generic packages to install non-workspace dependencies ( those are added later )
RUN apt-get update && apt-get install -y \
    bash-completion \
    cmake \
    git \
    libdb5.3++-dev \
    libeigen3-dev \
    libffi-dev \
    liblzma-dev \
    libqwt5-qt4-dev \
    libxml++2.6-dev \
    libxml2-utils \
    python-yaml \
    ruby \
    ruby-dev \
    ruby-nokogiri \
    xmlstarlet

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

# opt/init_workspace.bash is run once via dockercommands.bash by calling check_init_workspace.bash
# $PRINT_INFO is set later by the docker run command in docker_commands.bash
RUN echo '$PRINT_INFO' >> /opt/init_workspace.bash
RUN echo '$PRINT_INFO -e "\e[32mplease run /opt/setup_workspace.bash to initialize the workspace\e[0m"' >> /opt/init_workspace.bash
RUN echo '$PRINT_INFO' >> /opt/init_workspace.bash

# If you want to run the setup automatically, you can add it directly to the script
# it is executed every time the container is re-created
#RUN echo "/opt/setup_workspace.bash" >> /opt/init_workspace.bash
RUN usermod -aG dialout devel






