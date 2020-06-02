# Docker Development 

These scripts are helping to set up a docker-based development and release workflow.

**Requisite:** Please install Docker according to the [README_Docker.md](README_Docker.md)!

The docker development is based on different docker image setup steps, some of which can be omitted when a local registry is set up and the required image is already available.

In order to check for available images you can browse the DFKI [internal registry](https://d-reg.hb.dfki.de/repositories) (Login required).

## 01 Base Image
**In case the required base image is already available in your registry, please jump to the 02 Workspace Image section.**

* build a base image for Rock or ROS (shared for all)
   * readme in _image_setup/01_base_image_

## 02 Workspace Image

### Build Workspace Image
**In case the required workspace image is available in your registry. Refer to the "Use Existing Workspace Image" subsection.**
* fork this repo to your projects namespace or into a new group using the git web interface.
   * This way, changes and updates can be tracked and updated more easily in both directions.
* clone this repo to your system
   * git clone https://git.hb.dfki.de/MY_PROJECT/docker_development MY_PROJECT
* build a project specific workspace image with a mounted workspace, home and startscript folder
   * readme in _image_setup/02_workspace_image_
   * before you run a container, check and edit the settings.bash to configure your images!
   * refer to the suggested development workflow in the readme in _image_setup/02_workspace_image_
* git push the changes to your fork of this repository
* docker push the image to the registry```docker push <image_repository:tag>```

### Use Existing Workspace Image
**In case the required workspace image is already available in your registry it will automatically be pulled.**
* git clone your project specific fork to your system
   * git clone https://git.hb.dfki.de/MY_PROJECT/docker_development MY_PROJECT
* build the project specific workspace image (automatically pulled from registry & generate mounted workspace, home and startscript folder)
   * readme in _image_setup/02_workspace_image_
   * execute /opt/setup_workspace.bash to setup the workspace locally

## 03 Release Image
**In case the required release image is already available in your registry it will automatically be pulled.**
* build a release image containing the workspace
   * readme in _image_setup/03_release_image_
* docker push the image to the registry```docker push <image_repository:tag>```


## 04 Distribute Image
* build archives with image and scripts to deploy to others
   * readme in _image_setup/04_save_release_

<br></br>

# Working with the Images

## Start Container

You can start the workspace in devel or release mode. Default is set in your setting.bash and can be overwritten by passing devel/release as argument.

* call ```./exec.bash /bin/bash```
* or ```./exec.bash devel /bin/bash```
* or ```./exec.bash release /bin/bash```
 
  * In case a release image is available in your registry, it will be automatically pulled and launched

Now you can run programs as you like

Or you execute a startscript from the startscripts folder (they are in the path) and also available in the release

```./exec.bash devel/release bash```

```./exec.bash devel/release hello_world```

This can be used to execute specific executables from your workspace. Source the autocomplete.me script to enable autocompletion for the ./exec.bash script.


## Attach More Bashes or Start More Programs

Each subsequent call to exec.bash is using the same container

You can attach more bashes to the container using the exec.bash command again

```./exec.bash /bin/bash```

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

## Upgrade Image

Upgrades are detected automatically, only the workspace and home folders are preserved.
Programs manually installed using apt are lost.

You can docker pull images manually by executing ```update_workspace_images.bash```