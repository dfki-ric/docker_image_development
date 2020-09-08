# Build Release Image

Release images are created from a fully initialized devel image by copying the mounted host directories into the container. 

In order to achieve this, ou just execute the `build.sh` located here and push the newly generated image to your registry as desired.

There is no need to edit the Dockerfile here. The script just copies the folders that were mounted by the devel container into the newly created image.