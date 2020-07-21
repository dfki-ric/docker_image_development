# Build workspace image

_WARNING: Before you can set up the workspace image, the base image has to be pushed._

Workspace images contain pre-installed libraries of specific projects (not shared as commonly as the ones installed in the base_images)

You need to adapt the Dockerfile to the needs of your project:

* If the image is already in your registry, this step can be omitted

In order to check for available images you can browse the DFKI [internal registry](https://d-reg.hb.dfki.de/repositories) (Login required).


The following steps are explained in detail in the next sections.

* Add workspace dependencies of your project to the image (add the install to the Dockerfile)
* Add workspace initialization scripts/howto
* suggested workflow for workspace image development
* setting up of ssh credentials


## Workspace Dependencies

* You should try to pre-install all workspace dependencies using this Dockerfile.
* The list_*_osdeps scripts help to determine which workspace-specific packages are required
* Add these dependencies to be installed by the Dockerfile

## Workspace Initialization

When the devel container is started for the first time, the /opt/init_workspace.sh script is executed.
You can use it to initialize the workspace, but it is executed each time a new image is available.

The best way is to add a /opt/setup_workspace.sh script to the image, and add a usage instruction to the /opt/init_workspace.sh script.

```
RUN echo 'echo -e "\n\e[32mplease run /opt/setup_workspace.sh to initialize the workspace\e[0m\n"' >> /opt/init_workspace.sh
```

## Suggested Workflow

<table border="0">
 <tr>
    <th>Step</th>
    <th>ToDo</th>
    <th></th>
    <th>File to edit/execute</th>
 <tr>
    <td>0.</td>
    <td>edit image names, tags & registry</td>
    <td> => </td>
    <td> edit: ../../settings.bash </td>
 </tr>
 <tr>
    <td>1.</td>
    <td>describe the steps to setup your workspace<br></br> (e.g. using buildconf)</td>
    <td> => </td>
    <td> edit: setup_workspace.bash </td>
 </tr>
 <tr>
    <td>2.</td>
    <td>build image</td>
    <td> => </td>
    <td>exec: bash build.sh </td>
 </tr>
  <tr>
    <td>3.</td>
    <td>start container</td>
    <td> => </td>
    <td>exec: bash ./exec_in_devel /bin/bash </td>
 </tr>
 <tr>
    <td>4.</td>
    <td>setup workspace</td>
    <td> => </td>
    <td>exec: bash /opt/setup_workspace.bash</td>
 </tr>
 <tr>
    <td>5.</td>
    <td>list osdeps</td>
    <td> => </td>
    <td> ROS:<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - add list_ros_osdeps.rb to your mounted workspace<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - source setup.bash and execute ruby list_ros_osdeps.rb<br></br>
         ROCK:<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - add list_rock_osdeps.* to your mounted workspace<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - source your env.sh and execute bash list_rock_osdeps.bash<br></br>
         </td>
 </tr>
 <tr>
    <td>6.</td>
    <td>add osdeps to Dockerfile</td>
    <td> => </td>
    <td>edit: copy/paste output from previous step into your Dockerfile</td>
 </tr>
 <tr>
    <td>7.</td>
    <td>rebuild your image to include osdeps</td>
    <td> => </td>
    <td>exec: bash build.sh </td>
 </tr>
</table>


## Set up authentication on the container

As prerequiste for the installation of an Autoproj environment you will need to set up your git credentials, there are at least two options for this.

### Option 1) Using ssh keys

**Important** If you use ssh keys in your Docker containers, make sure that any image you produce is not including the keys -also not any of the intermediate images. The images might reach other people and these people would have access to your key. Note that the releases that are produced by these scripts copy in the default mounted volumes to the image. 

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

