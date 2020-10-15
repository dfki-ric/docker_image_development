## Release Image

### Run From a Release Image via Docker Registry

Make sure you have access to the Docker registry if you don't already have pulled the image (VPN, Login).
Make sure that you use the exec mode `release`.

Just follow the generic instructions given in the [docker_usage](doc/020_Usage.md) for attaching to a container and running commands in it.

### Run From a Release Image contained in a .tar.gz archive

If you have received a release image and corresponding scripts as .tar.gz archives, you can execute the following steps to load and use it.

* Load the docker image with: docker load < IMAGE_ARCHIVE.tar.gz
* Extract the script archive: tar -xzf SCRIPTS_ARCHIVE.tar.gz
* Proceed with the general instructions from the [docker_usage](doc/020_Usage.md)

### Create a Release Image

Release images are created from a devel image by copying the mounted host directories into the container.

The release is not based on the devel container, so any tools or dependencies you installed in devel mode, that are not part of the devel image, are not available in the release.

__WARNING: This copies your complete workspace, home, and startscripts directories from this folder into the release image (including sources and possibly other sensitive data). If you don't want this, you should add source folders to the top level .dockerignore file, and afterwards check to make sure the created image doesn't contain the files before distributing it.__

Or you can use an internal registry for your release images to not disclose your code to others.

In order to achieve this, execute the `build.bash` in the directory `image_setup/03_release_image`. Afterwards you can push the newly generated image to your registry as desired.

There is no need to edit the Dockerfile here. The script just copies the folders that were mounted by the devel container into the newly created image.

You should change the default exec mode to `release` for your forked repository after the image was pushed to your registry. To let others download the release image directly.
