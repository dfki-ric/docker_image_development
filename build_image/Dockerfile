From d-reg.hb.dfki.de/docker_development/ros_melodic_18.04:latest
#https://git.hb.dfki.de/dfki-dockerfiles/ros-docker-with-hw-acceleration/blob/master/Ubuntu18.04_Melodic/Dockerfile


# add gazebo to ros installation
# To avoid some errors when fetching apt-get updates. # See: https://stackoverflow.com/a/35976127 
ENV DEBIAN_FRONTEND=noninteractive
#update ros key (ols one in base image)
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && apt-get install -y\
    ros-melodic-gazebo-* \
    ros-melodic-moveit \
    ros-melodic-moveit-visual-tools \
    ros-melodic-pcl-ros \
    ros-melodic-rqt-reconfigure \
    ros-melodic-uuv-simulator \
    ros-melodic-uuv-descriptions \
    ros-melodic-uuv-sensor-ros-plugins \
    ros-melodic-uuv-sensor-ros-plugins-msgs \
    ros-melodic-uuv-gazebo-ros-plugins-msgs \
    ros-melodic-dynamic-robot-state-publisher \
    ros-melodic-joint-state-controller \
    ros-melodic-joint-trajectory-controller \
    ros-melodic-ros-controllers \
    ros-melodic-panda-moveit-config \
    ros-melodic-uuv-gazebo-worlds \
    ros-melodic-uuv-thruster-manager \
    ros-melodic-uuv-world-ros-plugins \
    ros-melodic-teleop-tools \
    ros-melodic-ros-controllers \
    libzmqpp-dev \
    ruby-dev \
    bash-completion

# we can set the workspace, but not the content, it is mounted later
WORKDIR /opt/workspace


# add workspace init to container initialization
ADD setup_workspace.sh /opt/setup_workspace.sh
RUN chmod 755 /opt/setup_workspace.sh

# opt/init_workspace.sh is run once via dockercommands.sh by calling check_init_workspace.sh
RUN echo "echo" >> /opt/init_workspace.sh
RUN echo 'echo -e "\e[32mplease run /opt/setup_workspace.sh to initialize mare-it workspace\e[0m"' >> /opt/init_workspace.sh
RUN echo "echo" >> /opt/init_workspace.sh
#RUN echo "/opt/setup_workspace.sh" >> /opt/init_workspace.sh

ENV PATH="/opt/startscripts:${PATH}"






