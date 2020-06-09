# Base Images

If these images are pushed to a docker registry this building step can be omitted for most users.
In order to check for available images you can browse the DFKI [internal registry](https://d-reg.hb.dfki.de/repositories) (Login required).

These images are workspace-independent base images mostly for robotic frameworks.
They install the dependencies of the frameworks and common libraries.

These images provide basic common functionality for docker development:

* User ID settings for mounted volumes (init_user_id.bash)
  * The container user "devel" gets the same uid as the user on the host => no permission problems on shared files in mounted folders
* 3D Hardware acceleration (nvidia-docker)
  * using https://github.com/NVIDIA/nvidia-docker (please install, if you need it)
* setup helpers for workspace initialisation used in later stages

# Build an Empty Base Image

* call the build_plain_18.04.bash script
* push the result

# Build a ROS Base Image

* call the build_ros_18.04.bash script
* push the result


# Build a ROCK Base Image

* call the build_rock_18.04.bash script
* push the result


