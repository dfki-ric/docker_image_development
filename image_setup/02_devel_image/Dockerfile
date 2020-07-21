ARG BASE_IMAGE_NAME

FROM ${BASE_IMAGE_NAME}

# To avoid some errors when fetching apt-get updates. # See: https://stackoverflow.com/a/35976127 
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    bash-completion

# add workspace init to container initialization
ADD setup_workspace.bash /opt/setup_workspace.bash
RUN chmod 755 /opt/setup_workspace.bash

# opt/init_workspace.sh is run once via dockercommands.sh by calling check_init_workspace.sh
RUN echo "echo" >> /opt/init_workspace.bash
RUN echo 'echo -e "\e[32mplease run /opt/setup_workspace.bash to initialize the workspace\e[0m"' >> /opt/init_workspace.bash
RUN echo "echo" >> /opt/init_workspace.bash

# If you want to run the setup automatically, you can add it directly to the script
# it is executed every time the container is re-created
#RUN echo "/opt/setup_workspace.sh" >> /opt/init_workspace.sh







