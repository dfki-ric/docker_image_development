# Docker Development 

These scripts are helping to set up a docker-based development and release workflow.

**Requisite:** Please install Docker according to the [README_Docker.md](README_Docker.md)!

The docker development is based on different docker image setup steps, some of which can be omitted when a local registry is set up and the required image is already available.

In order to check for available images you can browse the DFKI [internal registry](https://d-reg.hb.dfki.de/repositories) (Login required).

# Running

When the default execmode is set correctly, you can omit the mode (devel,release) after `./exec.bash`.
When no command is given, exec.bash defaults to /bin/bash

* Clone this repository
* Optional: Login to the docker registry containing the images (if not on dockerhub, or no registry available)

## When a release image is available:

* call `$> ./exec.bash release STARTSCRIPT`
 * STARTSCRIPT here is a script from the image, with a high probability of also being in the startscritps folder of this repo
 * The image will be pulled automatically
* Optional: call `$> source autocomplete.me` to have code completion after ./exec.bash
 * This will use the completion with the scripts in this repo, new scripts might nor be available inside the image
  * Possibly reset this repo to the date of the release image to improve this situation

## When no release image is available:

In case you got a release as tar.gz file, load it locally using the instructions provided with the file.

### Use a devel image:

In case you have to create a release image you can use a "devel image".

* call `$> ./exec.bash devel`
 * follow the instructions on first start (most probably: call /opt/setup_workspace.bash)
 * this creates a mounted home and workspace folder in this folder
   * they are mounted as the users home and /opt/workspace folders in the container
   * you can edit files by using your host system and compile using the console created with `$> ./exec.bash devel`
     * TIP: in case you are using VSCode also check out the "Remote - Containers" extension
   
To create a release image, have a look at the [release image Readme](image_setup/03_release_image/Readme.md)!

Change the default execmode in settings.bash to release and push this repo

## When no devel image is available:

You are the one initially creating the images for your project.

### Create a devel image

   * fork this repo to your projects namespace or into a new group using the git web interface.
     * This way, changes and updates can be tracked and updated more easily in both directions.
   * clone your fork to your system into your desired folder
     * git clone https://git.hb.dfki.de/MY_PROJECT/docker_development MY_PROJECT_FOLDER
   
   * edit the settings.bash 
     * set a new project name
     * select the base image to use
     * set your registry (empty if none)

  * edit the image_setup/02_devel_image/setup_workspace.bash and make it work
    * in the docker container is is mounted as /opt/setup_workspace.bash
    * call `$> ./exec.bash base`
     * call `bash /opt/setup_workspace.bash` to test your workspace setup (clone repos, etc.) until it works
  * edit the image_setup/02_devel_image/Dockerfile
   * Add all additionally installed packages to the apt-get line
   * Add possibly needed commands needed to make your code run in this container
  
To create a devel image, have a look at the [devel image Readme](image_setup/02_devel_image/Readme.md)!

Change the default devel in settings.bash to release and push this repo

## When no base images are available:

You are the one initally creating the images for your registry, or you don't have one

* go to the image_setup/01_base_images folder
* call the build scritps you need base images for
* if you have a registry, push them

Also see the [base image Readme](image_setup/01_base_images/Readme.md)!




# Distribute a release image Image
* build archives with image and scripts to deploy to others
   * readme in _image_setup/04_save_release_

<br></br>



## Attach More Bashes or Start More Programs

Each subsequent call to exec.bash is using the same container

You can attach more bashes to the container using the exec.bash command again

```./exec.bash /bin/bash```

## Updating an image from registry

You can cd into the tools folder andf call `update_image.bash` this updated the image of the current default exec mode.
Call `update_image.bash [base|devel|release]` to update other images

## Refreshing the container

This should not be needed, but is somtimes requires for testing.
The easiest way is to delete the accorting *-container_id.txt file.
The container will be re-created on the next call of exec.

THe same happens when you update the image by pulling


# Special Topics

## Changing a release
In case you need to change parts of an existing release, you can:

* extract a release to a devel workspace using the script in the tools folder
   * You need to generate a devel image or have access to it in the registry
   * change the default execmode or use `./exec.bash devel`
   * use the devel mode to do the changes
   * build a new release
* Edit the code within the container
  *  Changes are lost when the container is deleted/refreshed or "docker commit"the changes



## Using iceccd in the container

Note: This has not been thoroughly tested. But feel free to try and provide feedback.

### Step 1 (option a)

Iceccd in the container has problems to find the iceccd server. To solve this, you have to modify the config file  `/etc/icecc/icecc.conf` to set `ICECC_SCHEDULER_HOST`to the address of the scheduler. 

### Step 1 (option b)

When starting your container, use the flag  `--net=host` so that host and container share the same network interfaces.

### Step 2

Stop the iceccd daemon on your host with

```
sudo service iceccd stop
```

and restart it in the container

```
sudo service iceccd restart
```

It should be possible to have more complex setups for the iceccd in containers/hosts. So that not necessarily the host has to stop using icecc or multiple container can make use of it.

## Programming in a Rock environemnt with Docker and VScode

You can edit code, compile and debug in your container from a host using the remote development package from VScode. Once you have your container created and visual studio with the [remote development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) installed in your host you can access your containers for development with this extension.

Another useful extension for vscode to work with Rock is the [rock extension](https://marketplace.visualstudio.com/items?itemName=rock-robotics.rock). This tool gives you access to the most common autoproj commands directly from the vscode interface.
