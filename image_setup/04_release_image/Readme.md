# Release

This is a more manual step that preparing a standard release but it saves image memeory size.

In frozen images the image still contains all headers an libraries that are used to build the image.
While this can help to restore/change releases these images might not be suitable for "real" deployment in cloud services.

The release build process starts with a basic image (not a :base image) to be set in the Dockerfile. It has to match the parent image of the :base image you choose, e.g. for developmentimage/plain_22.04:base use ubuntu:22.04 (or nvidia/opengl:1.2-glvnd-devel-ubuntu22.04. See image_setup/01_base_image when in doubt)

Fill the files.txt with your desired files (your executable, default config files, plugins).
The scripts will collect all linked shared objects of the files in that list and put them into the new image.

The files.txt needs to contain the paths from within the container for each individual file.
If you need to add whole folders, you can use `find -type f -exec readlink -f {} \;` in the container to generate a list.

If you need special libs with a lot of plugins/resource files (like e.g. Qt5), consider insalling those via the Dockerfile instaed of adding them to the files.txt

Also, you'll need to create an entrypoint that directly runs your allpication.
The example provided will still allow to run the console by providing it ad command paramater


# running
./exec.bash will not work. You need to run manually and provide all nessecary paramaters.
TIP: you can mount config files and storage locations to have persistent data

If you delete your devel call container exec.bash in devel mode with VERBOSE=1, it will tell you the docker run paramaters used to start the image:

```bash
$> ./delete_container.bash release
$> VERBOSE=true ./exec.bash devel /bin/bash`
```

docker run --rm --privileged --gpus=all -ti --net=host -v $(pwd)/ps3_local.yml:/config.yml  -e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix d-reg.hb.dfki.de/developmentimage/rrc_gamepad_client_20.04:release

