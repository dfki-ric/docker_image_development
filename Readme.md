# Docker quick guide

Docker separates between images and containers.

## Images

Images are fixed states from which runtime containers can be started from.

They are generated using so called Dockerfiles

## Containers

A container derives from an image ans is creted by running an image




# setup workspace

* select a development folder 

This will create a dev and a home folder in your selected development folder:

sh devel.sh $(pwd)

They are mounted to /opt/devel and as home directory for the devel user, by default, bash starts in /opt/devel

* init your workspace, the setup.sh from uuwsim is auto-mounted

mkdir src

clone env into src and build/install

```
cd src
git clone https://git.hb.dfki.de/models-environments/offshore_field
git clone https://git.hb.dfki.de/models-robots/cuttlefish
rosdep install --from-paths src --ignore-src --rosdistro=melodic -y --skip-keys "gazebo gazebo\_msgs gazebo\_plugins gazebo\_ros gazebo\_ros\_control gazebo\_ros\_pkgs"
catkin\_make install
```

exit container

```$> exit```

# run

* start container
```
sh reuse_devel.sh
roscore
```

* attach bashes 

sh add_bash.sh
. devel/setup.sh 
roslaunch offshore_field test_world.launch

sh add_bash.sh
. devel/setup.sh 
roslaunch cuttlefish upload_cuttlefish.launch




