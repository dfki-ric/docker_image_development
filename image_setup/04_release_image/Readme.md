# Minimal release

This is a more manual step that preparing a standard release but it saves image memeory size.

In frozen images the image still contains all headers an libraries that are used to build the image.
While this can help to restore/change releases these images might not be suitable for "real" deployment in cloud services.

The minimal release build process starts with a basic image (not a :base image) to be set in the build.bash file.

Also in normal docker deployments there is a one image one app rule. This is why you also have to set the executable in build.bash.
The scripts will collect all linked shared objects and put them into the new image.

It will not collect plugins (not linked) and required configuration files. 

You can add them into the additional_workspace_files.txt files in paph from insice the container.
If you need to add whole folders, you can use `find -type f -exec readlink -f {} \;` in the container to generate a list.

Also, you'll need to create an entrypoint that directly runs your allpication.
The example provided will still allow to run the console by providing it ad command paramater


# running
./exec.bash will not work. You need to run manually and provide all nessecary paramaters.
TIP: you can mount confid files and storage locations to have persistent data

docker run --rm --privileged --gpus=all -ti --net=host -v $(pwd)/ps3_local.yml:/config.yml  -e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix d-reg.hb.dfki.de/developmentimage/rrc_gamepad_client_20.04:release
