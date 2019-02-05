From d-reg.hb.dfki.de/rosbasic/melodic_18.04:latest

RUN mkdir -p /opt/uuw-sim/src
WORKDIR /opt/uuw-sim

#generate workspace
RUN . /opt/ros/melodic/setup.sh && catkin_make

WORKDIR /opt/uuw-sim/src

RUN git clone https://github.com/uuvsimulator/uuv_simulator.git
RUN git clone https://github.com/tu-darmstadt-ros-pkg/hector_localization
RUN git clone https://github.com/ros-teleop/teleop_tools

WORKDIR /opt/uuw-sim

RUN rosdep install --from-paths src --ignore-src --rosdistro=melodic -y --skip-keys "gazebo gazebo_msgs gazebo_plugins gazebo_ros gazebo_ros_control gazebo_ros_pkgs"

#build uuw-sim
RUN . /opt/uuw-sim/devel/setup.sh && catkin_make install

WORKDIR /opt/devel
RUN mkdir -p /opt/devel/src

# keep entrypoint, but add new sourse
RUN echo "source /opt/uuw-sim/devel/setup.sh" >> /opt/init_dev_shell.sh





