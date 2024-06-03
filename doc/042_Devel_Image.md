## Devel Image

Devel images are build upon base images and provide a light-weight and safe environment to develop a functional project- or workspace-specific docker setup.
If you are starting out a new docker development workflow for your project, a devel image will not yet be available on the registry.
Refer to the create devel image subsection to create one.
The devel images contain project specific libraries and can be pushed to the registry to provide a common foundation for cooperative development.

### Run From a Devel Image

Just follow the instructions given in [docker usage](020_Usage.md) for using a container and running commands in it.
Make sure you have access to the Docker registry if you haven't already pulled the image (might require docker login and potentially a VPN connection).
Make sure that you use the exec mode `devel` (in your settings.bash or as argument to exec.bash).

The devel image is pulled with only the dependencies of the workspace installed.
The devel container is set up to mount several directories within the host's repository clone:

* **/opt/startscripts** corresponds to the host's `docker_development/startscripts`
* **/opt/workspace** corresponds to the host's `docker_development/workspace`
* **/home/dockeruser** corresponds to the host's `docker_development/home`

These are initially empty. That means, in order to run applications from the workspace, it needs to be set up (and usually built) at the first run to fully initialize the container.

In order to do this, instantiate and attach to the container using `./exec.bash devel` (as explained above).
If the image was created properly, instructions are printed how to proceed from there.
Usually this will include running the script `bash /opt/setup_workspace.bash` potentially followed by additional build steps.

To wrap it up, you can edit files in the workspace from your host system, but to compile and run, you need to enter the container as explained above (via `./exec.bash devel`).
In case you are using VSCode also check out the "Remote - Containers" extension.


IMPORTANT: In order to apply new settings (like 3d acceleration), the container and saved settings have to be reset: `rm -f -- has_gpu_support.txt {devel,release}-container_id.txt`.


### Create a Devel Image


Devel images contain pre-installed libraries of specific projects (not shared as commonly as the ones installed in the base images).

The general steps are:

* Fork this repository for your project.
* Select the desired base image (Ubuntu, Rock, Ros etc).
* Add the installation of OS dependencies to the Dockerfile to add them to the environment.
* Add workspace initialization scripts/howto, e.g. `/opt/setup_workspace.bash`

The suggested workflow and related topics are explained in detail in the following sections.

#### Initialize the Repository

The image is accompanied by this repository. Therefore you should fork this repo to your project's namespace or into a new group using the git web interface. 
This way, changes and updates can be tracked and integrated more easily in both directions.

Then clone your fork to your system into the desired folder.

Afterwards you edit the `settings.bash` in order to
  * set a new project name,
  * make sure the default exec mode is specified `base`,
  * select the base image to use,
  * set your registry (empty if none).

Noe you can use ./exec to launch your container based on the base image and edit the workspace script (image_setup/02_devel_image/setup_workspace.bash or /opt/setup_workspace.bash in the container) until it works.
You may need to run this script to test your workspace setup (clone repos, etc.) repeatedly until it works.
You may need to clean up the workspace (i.e., the mounted directories) manually in between those runs, in order to simulate a fresh setup.

#### Installation of Workspace Dependencies in the Dockerfile

Go to `docker_development/image_setup/02_devel_image` and add installation commands (`apt install ...`) in order to pre-install all required workspace dependencies in the Dockerfile.
The Dockerfile is intended to contain any OS dependencies the workspace has (that are not already provided by the base image).

Especially if you are not sure which packages need to be installed at this point, it might make sense to start with the next step, to prepare the workspace. Then you can complete the dependencies in the Dockerfile, using the helper scripts for dependency enumeration.

You can start `bash /opt/write_osdeps.bash` to determine which workspace-specific packages are required by the workspace.
The script detects Rock and ROS workspaces and list all OS dependencies depending on the packages, provided that metadata about dependencies is available.
The workspace dependencies are written into the `image_setup/02_devel_image/workspace_os_dependencies.txt` and installed upon building a new devel image.
Install instructions for packages that are not workspace dependencies (or in the metadata) sould be directly added into the Dockerfile

__The later release image is not based on the devel container, it is based on the image. Any tools or dependencies not installed via the Dockerfile of the devel image will not be available in the release.__

Now you can make the first attempt to build the new image, using `bash build.bash` in `image_setup/02_devel_image/`.

Adding the installation of the packages to the Dockerfile of the devel image also adds the feature that they don't have to be re-installed every time the container is re-created. This might happen, when you clean up docker e.g. with `docker system prune` and your container is not running. When all dependencies are added to the image (Dockerfile), nothing has to be re-installed once you re-create the container after such a cleanup.

When the devel container is started for the first time, the script `/opt/init_workspace.bash` is automatically executed within the container.
It is executed each time the container is created. It is recommended to make it print instructions for necessary post-initialization steps to this script, e.g., add a hint to run `/opt/setup_workspace.bash` after initialization:

```
RUN echo 'echo -e "\n\e[32mplease run /opt/setup_workspace.bash to initialize the workspace\e[0m\n"' >> /opt/init_workspace.bash
```

#### Post-Installation Steps via setup_workspace.bash

For the devel image the `setup_workspace.bash` script is copied to **/opt/setup_workspace.bash** within the container. It is intended to contain all the steps to initialize the actual workspace, i.e., clone the required repositories via `autoproj_bootstrap` and `aup` or via `wstool`.

It is recommended to not include building/compiling the workspace (e.g., via `amake` or `catkin build`) in this script, but again rather print instructions for the required follow-up steps for the finalization of the container setup that are then to be executed manually.
This decoupling is intended to make it easier to spot the source of problems in the process. As it can take rather a long time overall, and if not decoupled it might not be obviously at which point the error occurred.

You may need to run this script to test your workspace setup (clone repos, etc.) repeatedly until it works.

You may need to clean up the workspace (i.e., the mounted directories) manually in between those runs, in order to simulate a fresh setup.

Keep in mind that when using the devel image, the setup script is copied into the image during build, rather than being mounted as is the case for base images.
If your workspace does not require a lot of OS dependencies, i.e., the workspace setup is rather quick, than you might consider developing the setup_workspace.bash script using the base image.
To speed up the debugging process by using workspace related libraries you may use the devel image, where they are pre-installed (if listed in the Dockerfile).
In order to avoid rebuilding the image for each try, you can edit and test the script inside the container and finally copy the content of the functional script into the one located in the `image_setup/02_devel_image` directory. This will be copied into the devel image during the next build.

If during the process you notice that dependencies external to the workspace are still missing, don't forget to add them to the Dockerfile too, and potentially go back to the previous step.



### Checklist: Suggested Workflow

As a recap, here the steps in short:

<table border="0">
 <tr>
    <th>Step</th>
    <th>ToDo</th>
    <th></th>
    <th>File to edit/execute</th>
 <tr>
    <td>0.</td>
    <td>Clone this repository</td>
    <td></td>
    <td></td>
 </tr>
 <tr>
    <td>1.</td>
    <td>Edit project name, select base image, set exec mode to base & set registry if needed</td>
    <td> => </td>
    <td>in the repo's root directory edit:<br><code>settings.bash</code> </td>
 </tr>
 <tr>
    <td>2.</td>
    <td>Add the steps to setup your workspace<br></br> (e.g. using buildconf, wstool, git-repo, etc.)</td>
    <td> => </td>
    <td>in the repo's root directory edit:<br><code>image_setup/02_devel_image/setup_workspace.bash</code> </td>
 </tr>
  <tr>
    <td>3.</td>
    <td>Start container and attach shell to it to test the setup script</td>
    <td> => </td>
    <td>in the repo's root directory execute:<br><code>bash exec.bash base</code> </td>
 </tr>
 <tr>
    <td>4.</td>
    <td>Test the script for workspace initialization</td>
    <td> => </td>
    <td>in the attached container shell run:<br><code>bash /opt/setup_workspace.bash</code></td>
 </tr>
 <tr>
    <td>5.</td>
    <td>Find out what OS dependencies are required</td>
    <td> => </td>
 <td> Exit the container with <code>exit</code> and run <code>./exec.bash /opt/write_osdeps.bash</code> to extract workspace dependencies<br>
         The dependencies list will be written to <code>image_setup/02_devel_image/workspace_os_dependencies.txt</code> and added to the devel image<br>
         When you don't use ROCK or ROS put the dependencies manually to your Dockerfile in <code>image_setup/02_devel_image</code>
    </td>
 </tr>
 <tr>
    <td>6.</td>
    <td>Build the initial version of the devel image with OS dependencies</td>
    <td> => </td>
    <td>in <code>image_setup/02_devel_image</code> run: <code>bash build.bash</code> </td>
 </tr>
  <tr>
    <td>7.</td>
    <td>You should change the default exec mode to <code>devel</code> and push to your fork after pusing the image to the docker registry</td>
    <td> => </td>
    <td>in the repo's root directory edit: <code>settings.bash</code> </td>
 </tr>
 <tr>
    <td>8.</td>
    <td>push this repo to your project git</td>
    <td></td>
    <td></td>
 </tr>
</table>



### Establish Authentication to Remote Repositories in the Container

As a prerequiste for the installation of a non-trivial Autoproj or wstool environment you will probably want to set up a method for authentication at some remote git server. There are at least two options for this.

* Git Credential Cache via HTTPS Protocol
* SSH (Public Key) Authentication

__To commit/push your changes, it is recommended to do this from the host workspace folder and not from the mounted one within the container. This way, the committer and credentials of the host system is used.__

#### Option 1) Git Credential Cache via HTTPS Protocol

The idea of this option is to use https user authentication in combination with the [git credential cache](https://git-scm.com/docs/git-credential-cache) so that git will only asks once per repository server (github, gitlab etc.).

You may want to add these lines to the .bashrc of your container:
```bash
git config --global credential.helper 'cache --timeout=2000'
git config --global url."https://".insteadOf git://
```
The git config can also be used to override git-ssh urls globally to http in case the repositories have git submodules defined with ssh urls.
e.g. `git config --global url."https://git.hb.dfki.de/".insteadOf git@git.hb.dfki.de:`, it would be even better better is it to use a relative path as submodule url.


#### Option 2) SSH (Public Key) Authentication

**Important** Extra caution is required if you use ssh keys in your Docker containers. Make sure that the images you produce do not contain your private keys (also not any of the intermediate images). The images might be distributed to other people and these people might thus gain access to your key. Note that the release images that are produced by these scripts may store copies of all files in the mounted directories, possibly including hidden directories and sensitive data.

1. Mount an additional volume containing your ssh key

To use a mounted ssh key, please add the mount instructions in the settings.bash file. 
__Don't copy or link your personal ssh key to any of the default mounted volumes.__

Updated expression in settings.bash for mounting the folder `<host_folder_containing_ssh>` as volume in the container at `<mounted_ssh_folder_in_container>`:
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
