# Build devel image

Devel images contain pre-installed libraries of specific projects (not shared as commonly as the ones installed in the base images).

The general steps are:

* Fork this repository for your project.
* Select the desired base image (Ubuntu, Rock, Ros etc). In order to check for available images you can browse the DFKI [internal registry](https://d-reg.hb.dfki.de/repositories) (Login required).
* Add the installation of OS dependencies to the Dockerfile to add them to the environment.
* Add workspace initialization scripts/howto

The suggested workflow and related topics are explained in detail in the following sections.

## Initialize the Repository

The image is accompanied by this repository. Therefore you should fork this repo to your project's namespace or into a new group using the git web interface. 
This way, changes and updates can be tracked and updated more easily in both directions.

Then clone your fork to your system into the desired folder.

Afterwards you edit the `settings.bash` in order to
  * set a new project name,
  * make sure the default exec mode is specified `devel`,
  * select the base image to use,
  * set your registry (empty if none).

Now you can make the first attempt to build the new image, using `bash build.sh`. Without changes to the Dockerfile, this will be equal to the base image.
This is useful to see if the general process is working, and to proceed initializing the workspace within the newly generated container (try to run `bash exec.bash` too).


## Installation of Workspace Dependencies in the Dockerfile

Go to `docker_development/image_setup/02_devel_image` and add installation commands (`apt install ...`) in order to pre-install all required workspace dependencies in the Dockerfile.
The Dockerfile is intended to contain any OS dependencies the workspace has (that are not already provided by the base image).

Especially if you are not sure which packages need to be installed at this point, it might make sense to start with the next step, to prepare the workspace. Then you can complete the dependencies in the Dockerfile, using the helper scripts for dependency enumeration.
The `list_*_osdeps...` scripts help to determine which workspace-specific packages are required by the workspace.
These are available for Rock and ROS workspaces and list all OS dependencies depending on the packages provided metadata. They can be found in the `image_setup/02_devel_image` folder.

When the devel container is started for the first time, the script `/opt/init_workspace.sh` is executed within the container.
You can use it to initialize the workspace, but it is executed each time a new image is available.

It is recommended to make it print instructions for necessary post-initialization steps into to this script, e.g., add a hint to run `/opt/setup_workspace.sh` after initialization to the image:

```
RUN echo 'echo -e "\n\e[32mplease run /opt/setup_workspace.sh to initialize the workspace\e[0m\n"' >> /opt/init_workspace.sh
```


## Post-Installation Steps via setup_workspace.sh

The `setup_workspace.sh` script will be mounted to **/opt/setup_workspace.sh** within the container. It is intended to contain all the steps to initialize the actual workspace, i.e., clone the required repositories via `autoproj_bootstrap` and `aup` or via `wstool`.

It is recommended to not include building/compiling the workspace (e.g., via `amake` or `catkin build`) in this script, but again rather print instructions for the required follow-up steps for the finalization of the container setup that are then to be executed manually.
This decoupling is intended to make it easier to spot the source of problems in the process. As it can take rather a long time overall, and if not decoupled it might not be obviously at which point the error occurred.

You may need to run this script to test your workspace setup (clone repos, etc.) repeatedly until it works. You may need to clean up the workspace (i.e., the mounted directories) manually in between those runs, in order to simulate a fresh setup.

If during the process you notice that dependencies external to the workspace are still missing, don't forget to add them to the Dockerfile too, and potentially go back to the previous step.



# Checklist: Suggested Workflow

As a recap, here the steps in short:

<table border="0">
 <tr>
    <th>Step</th>
    <th>ToDo</th>
    <th></th>
    <th>File to edit/execute</th>
 <tr>
    <td>0.</td>
    <td>Fork this repository</td>
    <td> => </td>
    <td></td>
 </tr>
 <tr>
    <td>1.</td>
    <td>Edit project name, select base image, exec mode & registry</td>
    <td> => </td>
    <td> edit (in the repo's root directory): `settings.bash` </td>
 </tr>
 <tr>
    <td>2.</td>
    <td>Add the steps to setup your workspace<br></br> (e.g. using buildconf)</td>
    <td> => </td>
    <td> edit: `setup_workspace.bash` </td>
 </tr>
 <tr>
    <td>3.</td>
    <td>Build the initial version of the devel image</td>
    <td> => </td>
    <td>exec: `bash build.sh` </td>
 </tr>
  <tr>
    <td>4.</td>
    <td>Start container and attach shell to it</td>
    <td> => </td>
    <td>exec (in the repo's root directory): `bash exec.bash devel` </td>
 </tr>
 <tr>
    <td>5.</td>
    <td>Run the script for workspace initialization</td>
    <td> => </td>
    <td>exec (in the attached container shell): `bash /opt/setup_workspace.bash`</td>
 </tr>
 <tr>
    <td>6.</td>
    <td>Find out what OS dependencies are required</td>
    <td> => </td>
    <td> ROS:<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - Add `list_ros_osdeps.bash` to your mounted workspace and run it there.<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - You will probably need to source the ROS environment and `rosdep update` for this.<br></br>
         ROCK:<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - Add `list_rock_osdeps.rb` to your mounted workspace and run it there.<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - You will probably need to source your `env.sh` for this.<br></br>
         </td>
 </tr>
 <tr>
    <td>7.</td>
    <td>Add those OS dependencies for installation to Dockerfile</td>
    <td> => </td>
    <td>edit: copy/paste output from previous step into your Dockerfile</td>
 </tr>
 <tr>
    <td>8.</td>
    <td>Rebuild your image with OS dependencies</td>
    <td> => </td>
    <td>exec (in the repo's root directory): `bash build.sh` </td>
 </tr>
</table>


# Establish Authentication to Remote Repositories in the Container

As a prerequiste for the installation of a non-trivial Autoproj environment you will probably want to set up a method for authentication at some remote git server. There are at least two options for this.

## Option 1) SSH (Public Key) Authentication

**Important** If you use ssh keys in your Docker containers, make sure that any image you produce is not including the keys -also not any of the intermediate images. The images might reach other people and these people would have access to your key. Note that the releases that are produced by these scripts copy in the default mounted volumes to the image.

1. Mount an additional volume containing your ssh key

To use a mounted ssh key, please add the mount instructions in the [settings.bash](https://git.hb.dfki.de/dfki-dockerfiles/docker_development/-/blob/master/settings.bash) file. Don't copy or link your personal ssh key to any of the default mounted volumes.

Updated expression in [settings.bash](https://git.hb.dfki.de/dfki-dockerfiles/docker_development/-/blob/master/settings.bash) for mounting the folder `<host_folder_containing_ssh>` as volume in the container at `<mounted_ssh_folder_in_container>`:
```bash
export ADDITIONAL_DOCKER_RUN_ARGS=" \
        --dns-search=dfki.uni-bremen.de \
        -v <host_folder_container_ssh>:<mounted_ssh_folder_in_container> \
        "
```

Then, in the container, you will have to add that key to the container's ssh-agent.

2. Log in your container

3. Add the key that you mounted from the host to the container's ssh-agent

```bash
eval "$(ssh-agent -s)"
ssh-add <mounted_ssh_folder_in_container>/id_rsa
```

### Option 2) Git Credential Cache via HTTPS Protocol

The idea of this option is to use https user authentication in combination with the [git credential cache](https://git-scm.com/docs/git-credential-cache) so that git will only asks once per repository server (github, gitlab etc.).

You may want to add these lines to the .bashrc of your container:
```bash
git config --global credential.helper 'cache --timeout=2000'
git config --global url."https://".insteadOf git://
```

