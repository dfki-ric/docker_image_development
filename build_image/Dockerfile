From d-reg.hb.dfki.de/rosbasic/melodic_18.04:latest
#https://git.hb.dfki.de/dfki-dockerfiles/ros-docker-with-hw-acceleration/blob/master/Ubuntu18.04_Melodic/Dockerfile

RUN mkdir -p /opt/uuw-sim/src
WORKDIR /opt/uuw-sim

#add gazebo to ros installation
# To avoid some errors when fetching apt-get updates. # See: https://stackoverflow.com/a/35976127 
ENV DEBIAN_FRONTEND=noninteractive
#update ros key (ols one in base image)
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && apt-get install -y ros-melodic-gazebo-* ros-melodic-moveit ros-melodic-moveit-visual-tools ros-melodic-pcl-ros ros-melodic-rqt-reconfigure
#generate uuwsim workspace, need to build to generate setup.sh
RUN . /opt/ros/melodic/setup.sh && catkin init && catkin build

WORKDIR /opt/uuw-sim/src

RUN git clone https://github.com/uuvsimulator/uuv_simulator.git
RUN git clone https://github.com/tu-darmstadt-ros-pkg/hector_localization
RUN git clone https://github.com/ros-teleop/teleop_tools

WORKDIR /opt/uuw-sim

RUN rosdep install --from-paths src --ignore-src --rosdistro=melodic -y --skip-keys "gazebo gazebo_msgs gazebo_plugins gazebo_ros gazebo_ros_control gazebo_ros_pkgs"

#build uuw-sim
RUN . /opt/uuw-sim/devel/setup.sh && catkin build

#we can set the workspace, but not the content, it is mounted later
RUN mkdir -p /opt/workspace/src
WORKDIR /opt/workspace

# keep entrypoint, but add new source
RUN echo "source /opt/uuw-sim/devel/setup.bash" >> /opt/setup_env.sh

#add workspace init to container initialization
ADD setup_workspace.sh /opt/setup_workspace.sh
RUN chmod 755 /opt/setup_workspace.sh
#opt/init_workspace.sh is run by the entrypoint of the base image
RUN echo "/opt/setup_workspace.sh" >> /opt/init_workspace.sh

ENV PATH="/opt/startscripts:${PATH}"






