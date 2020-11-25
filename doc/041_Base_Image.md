## Base Images

Normally, base images are already existing on docker hub, so you only have to re-generate them if they need to be updated.

These images provide basic common functionality for docker development:

* User ID settings for mounted volumes (init_user_id.bash)
  * The container user "devel" gets the same uid as the user on the host => no permission problems on shared files in mounted folders
* 3D Hardware acceleration (nvidia-docker)
  * using https://github.com/NVIDIA/nvidia-docker (please install, if you need it)
* setup helpers for workspace initialisation used in later stages

They are already runnable, but won't have your projects dependencies pre-installed.

### Create Base Images

If you are the one that is initally creating the images for your own registry (or you have none), this is your workflow:

1. Go to the `image_setup/01_base_images` folder.
2. Call the build scripts you need the base images for.
3. If you have a registry, push them.

These images are project- or workspace-independent base images.
Except for the plain ubuntu images, they are intended to provide a base, mostly for robotic frameworks, e.g. ros or rock.
They install only dependencies of the frameworks and common libraries.

After calling the build script, you may push the result to your registry.

