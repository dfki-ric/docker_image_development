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
    build-essential \
    cmake \
    python \
    python-dev


ADD ${INSTALL_SCRIPT} /opt/install.sh
RUN chmod 755 /opt/install.sh
RUN /opt/install.sh


ADD init_user_id.sh /opt/init_user_id.sh
#ADD setup_env.sh /opt/setup_env.sh

# create user (usermod -u UID username will be used later to maybe adapt UID in start.sh).
# using salted password: openssl passwd -1 -salt xyz  yourpass    # pw UserRos
# RUN useradd -m -U -p '$1$xyz$pzVfEx0ZWLPizymvlx2P70' -G sudo,users rosuser
RUN groupadd devel-group
RUN useradd --shell /bin/bash -c "development user" -m -G devel-group devel

# set user sudoers previlege for start script (w/o password), the /opt/init_user_id.sh script
# is using NUID and NGID environment variables, but ist executed by the user using sudo, so these vars have to be kept
RUN echo "devel ALL=(ALL) NOPASSWD: ALL \
    \nDefaults        env_keep += \"NUID\" \
    \nDefaults        env_keep += \"NGID\"" >> /etc/sudoers


#init /opt/init_container.sh should be run on docker run once from entrypoint
#add scripts here, that should be run when your (derived) container starts
RUN touch /opt/init_workspace.sh
ADD check_init_workspace.sh /opt/check_init_workspace.sh 

ADD entrypoint.sh /opt/entrypoint.sh

#these scripts must be runnable by users, not only root
RUN chmod 755 /opt/entrypoint.sh /opt/init_user_id.sh /opt/init_workspace.sh /opt/check_init_workspace.sh

RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash"]

