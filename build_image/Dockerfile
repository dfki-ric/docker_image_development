From d-reg.hb.dfki.de/rosbasic/melodic_18.04:latest
#https://git.hb.dfki.de/dfki-dockerfiles/ros-docker-with-hw-acceleration/blob/master/Ubuntu18.04_Melodic/Dockerfile

RUN mkdir -p /opt/uuw-sim/src
WORKDIR /opt/uuw-sim

#generate uuwsim workspace
RUN . /opt/ros/melodic/setup.sh && catkin_make

WORKDIR /opt/uuw-sim/src

RUN git clone https://github.com/uuvsimulator/uuv_simulator.git
RUN git clone https://github.com/tu-darmstadt-ros-pkg/hector_localization
RUN git clone https://github.com/ros-teleop/teleop_tools

WORKDIR /opt/uuw-sim

RUN rosdep install --from-paths src --ignore-src --rosdistro=melodic -y --skip-keys "gazebo gazebo_msgs gazebo_plugins gazebo_ros gazebo_ros_control gazebo_ros_pkgs"

#build uuw-sim
RUN . /opt/uuw-sim/devel/setup.sh && catkin_make install

#we can set the workspace, but not the content, it is mounted later
RUN mkdir -p /opt/workspace/src
WORKDIR /opt/workspace

# keep entrypoint, but add new source
RUN echo "source /opt/uuw-sim/devel/setup.sh" >> /opt/setup_env.sh

#add workspace init to container initialization
ADD setup_mare_it_workspace.sh /opt/setup_mare_it_workspace.sh
RUN chmod 755 /opt/setup_mare_it_workspace.sh
#opt/init_workspace.sh is run by the entrypoint of the base image
RUN echo "/opt/setup_mare_it_workspace.sh" >> /opt/init_workspace.sh









