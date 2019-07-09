# Docker development for mare-it

The build_image folder is only used to build a new image, normally don't use it

`If you have no nvidia graphics card: sudo apt install docker.io and skip this section`

You will need nvidia-docker2: 

https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-2.0)

WARNING: Check if your docker version is compatible:

when in doubst, install docker-ce from the docker apt sources:

https://docs.docker.com/install/linux/docker-ce/debian/



# Docker quick guide

Docker separates between images and containers.

## Images

Images are fixed states from which runtime containers can be started from.

They are generated using so called Dockerfiles

## Containers

A container derives from an image and is created by running an image.
Once a container is "run" (a.k.a. created), it can be started again.
Local changes are preseved in the container until the container is deleted

#setup docker

* Add your user to the docker group

`sudo usermod -aG docker $USER` (https://docs.docker.com/install/linux/linux-postinstall/)

* Log out and log back in so that your group membership is re-evaluated.


# setup workspace

* login to dfki docker registry using your DFKI-RIC Domain account:

```docker login d-reg.hb.dfki.de```

* select a development folder 
* clone this repo to it

* initially start the container and a bash shell inside

```bash ./exec_in_devel.sh /bin/bash```

This will create a dev and a home folder in your selected development folder
It also downloads the image

The first run creates a `workspace` and a `home` folder
They are mounted to `/opt/workspace` and as `/home/devel` directory in the container, bash starts in /opt/workspace

This makes it possible to use the editors, git etc. on your host system and not from within the docker container

You can run ```sh ./use_devel_container.sh``` anytime you wish to add more consoles to the container

On the first run, when no workspace/src folder exist, the workspace is initialized automatically using the build_image/setup_mare_it_workspace.sh script


# Running 

## start container

* you can call ```bash ./exec_in_devel.sh /bin/bash``` again, the workspace initialization is skipped this time

Now you can run roslaunch 

`roslaunch offshore_field test_world.launch`


or use a startscript from the startscripts folder (they are in the path)

```bash ./exec_in_devel.sh my_startscript.sh```


## attach more bashes 

You can attach more bashes to the container using this command again

```bash ./exec_in_devel.sh /bin/bash```

# upgrade image

if you need to upgrade to a new image version, you need to delete the container

`docker rm ros-melodic-devel-18.04-mare-it`

and re-init the container

```sh init_devel_container.sh```






