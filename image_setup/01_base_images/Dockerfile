ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG INSTALL_SCRIPT


LABEL version="0.1"
LABEL description="This image was generated to be a base image for docker_development"

# To avoid some errors when fetching apt-get updates. # See: https://stackoverflow.com/a/35976127 
ENV DEBIAN_FRONTEND=noninteractive

# general requirements
RUN apt-get update && apt-get install -y \
    build-essential \
    apt-utils \
    git \
    wget \
    cmake \
    sudo \
    cmake \
    python3 \
    python3-dev \
    locales

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

ENV SHELL /bin/bash

ADD ${INSTALL_SCRIPT} /opt/install.bash
RUN chmod 755 /opt/install.bash
RUN /opt/install.bash


ADD init_user_id.bash /opt/init_user_id.bash

# create user (usermod -u UID username will be used later to maybe adapt UID on fitst start).
# using salted password: openssl passwd -1 -salt xyz  yourpass    # pw UserRos
# RUN useradd -m -U -p '$1$xyz$pzVfEx0ZWLPizymvlx2P70' -G sudo,users rosuser
RUN groupadd devel-group
RUN useradd --shell /bin/bash -c "development user" -m -G devel-group devel

# set user sudoers previlege for start script (w/o password), the /opt/init_user_id.bash script
# is using NUID and NGID environment variables, but ist executed by the user using sudo, so these vars have to be kept
RUN echo "devel ALL=(ALL) NOPASSWD: ALL \
    \nDefaults        env_keep += \"NUID\" \
    \nDefaults        env_keep += \"NGID\"" >> /etc/sudoers


#init /opt/init_container.bash should be run on docker run once from entrypoint
#add scripts here, that should be run when your (derived) container starts
RUN touch /opt/init_workspace.bash
ADD check_init_workspace.bash /opt/check_init_workspace.bash 

ADD entrypoint.bash /opt/entrypoint.bash

#these scripts must be runnable by users, not only root
RUN chmod 755 /opt/entrypoint.bash /opt/init_user_id.bash /opt/init_workspace.bash /opt/check_init_workspace.bash

WORKDIR /opt/workspace

ENV PATH="/opt/startscripts:${PATH}"

ENTRYPOINT ["/opt/entrypoint.bash"]
CMD ["/bin/bash"]

