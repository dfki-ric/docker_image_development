ARG BASE_IMAGE

FROM ${BASE_IMAGE}

# This is a intermediate layer, that gets thown away in the build process
# This is because the git credentials of the jenkins buildserver should not be stored within the image


LABEL version="0.1"
LABEL maintainer "Steffen Planthaber"
LABEL description="This image was generated to be used with Gitlab-CI"

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
    lsb-release \
    gnupg2 \
    gosu

#install ROS melodic (second install because needs gnupg)
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && apt-get install -y ros-melodic-desktop python-rosinstall python-rosinstall-generator python-wstool python-catkin-tools
RUN rosdep init && rosdep update


#let's keep /opt/rock as install path, so the scripts don't have to be edited
RUN mkdir -p /opt/workspace
WORKDIR /opt/workspace


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


ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["/bin/bash"]

