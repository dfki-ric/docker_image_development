# Docker Development 


These scripts are helping to set up a docker-based development and release workflow.

Please install Docker according to the [README_Docker.md](README_Docker.md)

**In case someone else already build workspace images and they available in your registry, please jump to the Development section**

They are based on different docker image setup steps, which can be omitted for other workspaces when a local registry is set up and ther iamge is already available

* build a base image for Rock or ROS (shared for all)
   * if already in your registry, omit this step
   * readme in _image_setup/01_base_image_
* build a workspace image (shared for project) with a mounted workspace, hoem and startscript folders
   * if already in your registry, omit this step
   * readme in _image_setup/02_workspace_image_

# Development 

* git clone this repo to your system, rename the repo name locally
   * git clone https://git.hb.dfki.de/MY_PROJECT/docker_development MY_PROJECT

Before you run a container, check and edit the settings.bash to configure your images


## Set up authentication on the container

As prerequiste for the installation of an Autoproj environment you will need to set up your git credentials, there are at least two options for this.

### Option 1) Using ssh keys

**Important** If you use ssh keys in your Docker containers, make sure that any image you produce is not including the keys -also not any of the intermediate images. The images might reach other people and these people would have access to your key. Note that the releases that are produced by these scripts copy in the image the default mounted volumes. 

1. Mount an additional volumen containing your ssh key

To use a mounted ssh key, please add the mount instructions in the [settings.bash](https://git.hb.dfki.de/dfki-dockerfiles/docker_development/-/blob/master/settings.bash) file. Don't copy or link your personal ssh key to any of the default mounted volumes.

Updated expression in [settings.bash](https://git.hb.dfki.de/dfki-dockerfiles/docker_development/-/blob/master/settings.bash) for mounting the folder `<host_folder_containing_ssh>` as volume in the container at `<mounted_ssh_folder_in_container>`:
```
export ADDITIONAL_DOCKER_RUN_ARGS=" \
        --dns-search=dfki.uni-bremen.de \
        -v <host_folder_container_ssh>:<mounted_ssh_folder_in_container> \
        "
```

Then, in the container, you will have to add that key to the container's ssh-agent.

2. Log in your container

```
sh use_devel_container <container_name> 
```

3. Add the key that you mounted from the host to the container's ssh-agent

```
eval "$(ssh-agent -s)"
ssh-add <mounted_ssh_folder_in_container>/id_rsa
```

### Option 2) set a git password cache and use https as git protocol

The idea of this option is to use https user authentification in combination with the git password cache so that autoproj only asks once for each repository server.

Add these lines to the .bashrc of your container:
```
git config --global credential.helper 'cache --timeout=2000'
git config --global url."https://".insteadOf git://
```


## Start Container

You can start the workspace in devel or release mode:

* call ```./exec_in_devel.sh /bin/bash``` 
* or   ```./exec_in_release.sh /bin/bash``` 
  * In case a release image is available in your registry, it will be automatically pulled and launched

Now you can run programs as you like

Or you execute a startscript from the startscripts folder (they are in the path) and also available in the release

```./exec_in_devel.sh bash```

```./exec_in_devel.sh hello_world```

This can be used to execute specific executables from your workspace


## Attach More Bashes or Start More Programs

Each subsequent call to exec\_in\_devel is using the same container

You can attach more bashes to the container using the exec\_in\_ command again

```./exec_in_devel.sh /bin/bash```

or 

```./exec_in_devel.sh bash```

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

## Using gdb in the container

For gdb to be usable in your container, you can use the flag  `--priviledged` [source](https://hub.docker.com/r/andyneff/hello-world-gdb).

## Programming in a Rock environemnt with Docker and VScode

You can edit code, compile and debug in your container from a host using the remote development package from VScode. Once you have your container created and visual studio with the [remote development extension pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack) installed in your host you can access your containers for development with this extension.

Another useful extension for vscode to work with Rock is the [rock extension](https://marketplace.visualstudio.com/items?itemName=rock-robotics.rock). This tool gives you access to the most common autoproj commands directly from the vscode interface.

# Release Docker images with the results

* build a release image containing the workspace
   * readme in _image_setup/03_release_image_
* build archives with image and scritps to deploy to others
   * readme in _image_setup/04_save_release_


# Upgrade Image

Upgrades are detected automatically, only the workspace and home folders are preserved.
Programs manually installed using apt are lost.

You can docker pull images manually by executing ```update_workspace_images.bash```

# Start Your own Project and Images

In case you want to setup your own workspace image, please fork this repository into your group using the git web interface.
This way, changes and updates can be tracked and updated more easily in both directions.

* fork this repository to the new group
* git clone it to your system, rename the repo name locally
   * git clone https://git.hb.dfki.de/MY_PROJECT/docker_development MY_PROJECT
* Edit the settings.bash with your project paramaters, the base iamges are most probably in the registry
* Edit the image_setup/02_workspace_image/Dockerfile to install your workspace dependencies
* If you want, edit/fill the setup_workspace script
* build the workspace image
   * docker push the image ```docker push <image_repository:tag>```
* start setting up/building the workspace ```./exec_in_devel.sh /bin/bash```
* build the release image
   * docker push the image ```docker push <image_repository:tag>```
* git push the changes to your fork of this repository

Now others can clone this repository and directly call ```./exec_in_release.sh /bin/bash```.
Docker will pull the release image automatically.


