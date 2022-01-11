# Short Howto:

Mostly you don't need to execute any of these scripts

## 01_base_images

You don't need to do this normally, base images are shared globally on hub.docker.com, just select one in the settings.bash

## 02_devel_image

Devel images are shared on a per-project base,
only when you cloned this repo from https://github.com/dfki-ric/docker_image_development,
you need to set up the development image, follow the [devel setup documentation](../doc/042_Devel_Image.md).

## 03_release_image

Once your code is ready and compiled, you can release it in a single image.
The previously mountded home, workspace and startscripts folders are copied into the release image. [Follow this documentation](043_Release_Image.md)

## 04_save_release

When you want to share your release as an archive, this will save the image and a script collection so others don't have to clone this repo.

