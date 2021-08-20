ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG INSTALL_SCRIPT
ARG INSTALL_ARGS

LABEL description="This image was generated to be a base image for docker_image_development"
LABEL dockerfile_repo_url="https://github.com/dfki-ric/docker_image_development"
LABEL maintainer="DFKI RIC"

# To avoid some errors when fetching apt-get updates. # See: https://stackoverflow.com/a/35976127 
ENV DEBIAN_FRONTEND=noninteractive

# general requirements
RUN apt-get update && apt-get install -y \
    apt-utils \
    bash-completion \
    build-essential \
    cmake \
    git \
    locales \
    nano \
    psmisc \
    python3 \
    python3-dev \
    sudo \
    vim-tiny \
    wget

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8  ENV=LANGUAGE en_US:en LC_ALL=en_US.UTF-8 SHELL=/bin/bash PATH="/opt/startscripts:${PATH}"

# create devel user (usermod -u UID username will be used later to maybe adapt UID on fitst start).
RUN groupadd devel-group && useradd --shell /bin/bash -c "development user" -m -G devel-group devel

# set user sudoers previlege for start script (w/o password), the /opt/init_user_id.bash script
# is using NUID and NGID environment variables, but ist executed by the user using sudo, so these vars have to be kept
RUN echo "devel ALL=(ALL) NOPASSWD: ALL \
    \nDefaults        env_keep += \"NUID\" \
    \nDefaults        env_keep += \"NGID\"" >> /etc/sudoers

RUN mkdir -p /ccache

# init /opt/init_workspace.bash is run on docker run once from entrypoint
# You can use echo to add scripts here, that should be run when your (derived) container starts
RUN touch /opt/init_workspace.bash

ADD check_init_workspace.bash /opt/check_init_workspace.bash 
ADD init_user_id.bash /opt/init_user_id.bash
ADD VERSION /opt/VERSION
ADD entrypoint.bash /opt/entrypoint.bash
ADD ${INSTALL_SCRIPT} /opt/install.bash

#these scripts must be runnable by users, not only root
RUN chmod 755 /opt/entrypoint.bash /opt/init_user_id.bash /opt/init_workspace.bash /opt/check_init_workspace.bash /opt/install.bash

WORKDIR /opt/workspace

ENTRYPOINT ["/opt/entrypoint.bash"]
CMD ["/bin/bash"]

RUN /opt/install.bash ${INSTALL_ARGS}
