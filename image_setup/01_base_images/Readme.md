
# Base Images

If these images are pushed to a docker registry this building step can be omitted for most users.

These images are workspace-independent base images mostly for robotc frameworks.
They install the dependencies of the frameworks and common libraries.

These images provide basic common functionality for docker development:

* User ID settings for mounted volumes (init_user_id.sh)
  * The contariner user "devel" gets the same uid as the user on the host
  * so there are no permission problems on shared files in mounted folders
* 3D Hardware acceleration (nvidia-docker)
  * using https://github.com/NVIDIA/nvidia-docker (please install, if you need it)
* setup helpers for workspace initialisation used in later stages

# Build a Empty Base Image

* call the build_plain.sh sccript
* push the result

# Build a ROS Base Image

* call the build_ros.sh sccript
* push the result


# Build a ROCK Base Image

* call the build_rock.sh sccript
* push the result


