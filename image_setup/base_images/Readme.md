
# Base Images

If these images are pushed to a docker registry this building step can be omitted for most users.

This iamges are workspace-independent base image for robotc frameworks.
They install the dependencies of the frameworks and common libraries.

These images provide basic common functionality for docker development:

* User ID settings for mounted volumes (init_user_id)
  * The conteriner user "devel" gest the same uid as the user on the host
  * no permission problems on shared files
* 3D Hardware acceleration (nvidia-docker 2)
  * using https://github.com/NVIDIA/nvidia-docker (please install, if you need it)
* setup helpers for workspace initialisation used in later stages


# Build a ROS base image

* call the build_ros.sh sccript
* push the result


# Build a ROCK base image

* call the build_rock.sh sccript
* push the result


