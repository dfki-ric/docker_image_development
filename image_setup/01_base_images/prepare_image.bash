#!/bin/bash

# To avoid some errors when fetching apt-get updates. # See: https://stackoverflow.com/a/35976127 
export DEBIAN_FRONTEND=noninteractive

# general requirements
apt-get update && apt-get install -y \
    apt-utils \
    bash-completion \
    build-essential \
    cmake \
    ccache \
    icecc \
    xpra \
    git \
    locales \
    nano \
    psmisc \
    python3 \
    python3-dev \
    sudo \
    vim-tiny \
    wget

locale-gen en_US.UTF-8

# create dockeruser user (usermod -u UID username will be used later to maybe adapt UID on first start).
groupadd dockeruser-group 
useradd --shell /bin/bash -c "development user" -m -G dockeruser-group dockeruser

# set user sudoers previlege for start script (w/o password), the /opt/init_user_id.bash script
# is using NUID and NGID environment variables, but ist executed by the user using sudo, so these vars have to be kept
echo -e "dockeruser ALL=(ALL) NOPASSWD: ALL \
    \nDefaults        env_keep += \"NUID\" \
    \nDefaults        env_keep += \"NGID\"" >> /etc/sudoers

# init /opt/init_workspace.bash is run on docker run once from entrypoint
# You can use echo to add scripts here, that should be run when your (derived) container starts
touch /opt/init_workspace.bash
chmod 755 /opt/init_workspace.bash

# delete downloaded and installed .deb files to lower image size
apt-get clean
