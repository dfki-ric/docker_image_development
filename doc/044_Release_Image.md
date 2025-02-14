## Release Image

### Run From a Release Image via Docker Registry

Make sure you have access to the Docker registry if you haven't already pulled the image (might require docker login and potentially a VPN connection).

./exec.bash will not work. You need to run manually and provide all nessecary paramaters.

TIP: you can mount config files and storage locations to have persistent data

docker run --rm --privileged --gpus=all -ti --net=host -v $(pwd)/ps3_local.yml:/config.yml  -e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix d-reg.hb.dfki.de/developmentimage/rrc_gamepad_client_20.04:release

As release images are "normal" images, the can also just come as a docker compose file or simular, without the repo.


### Create a Release Image

The release build process starts with a basic image (not a :base image) to be set in the build.bash file. This means nothind from the devel/frozen image is included by default.

You need to set the base image the release is creted from in the `image_setup/04_release_image/Dockerfile`

To add executables, add them to the `image_setup/04_release_image/additional_workspace_files.txt`

The scripts will collect all linked shared objects and copy them into the new image (no need to install dependencies via apt in the dockerfile).
If you only have one executable, only this will be in the list, but additional resource/config files and plugins are not automatically detected.
You need to add those to the list manually.

If you need to add whole folders, you can use `find -type f -exec readlink -f {} \;` in the container to generate a file list.

Also, you'll need to edit the entrypoint to directly run your allpication `image_setup/04_release_image/entrypoint.bash`.
The example provided will still allow to run the console by providing it as command paramater

In order to build the release, execute the `build.bash` in the directory `image_setup/04_release_image`. Afterwards you can push the newly generated image to your registry as desired.

