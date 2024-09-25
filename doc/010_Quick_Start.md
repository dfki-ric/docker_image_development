## Initial Setup
The setup depends whether soneone already prepared settigns and a docker_image_development fork for your project or not.

### Initial Set-Up if someone already prepared a docker_image_development clone for your project

1. Clone the your docker_image_development
   1. `git clone git@git.hb.dfki.de:MY_PROJECT/docker_image_development.git` PROJECTNAME
   2. `cd PROJECTNAME`
3. Setup Docker (if not already done on that PC):
   1. sudo apt install docker.io
   2. sudo adduser $(id -un) docker
   3. Optionally setup [nvidia 3D accelleration](010_Setup_Docker.md#nvidia-docker-optional)
   4. Logout of computer and login again   
4. Prepare pulling the image (if need to pull new image):
   1. If you have a private registry for the devel images:
     1. Connect VPN (if you need it)
     2. Do Registry Login, e.g., `docker login USER@d-reg.hb.dfki.de` ([one time setup steps and more info](010_Setup_Docker.md#using-a-registry))
5. Pull image and start container (if not already available, [additional information](042_Devel_Image.md#run-from-a-devel-image))
   1. `./exec.bash devel`
   2. If this does not download a new image check if you executed the steps under 4.
   3. If downloading does not work, you can build your own devel image
      1.  `cd image_setup/02_devel_image`
      2.  `bash build.bash`
6. Setup workspace:
   1. Run workspace setup in container shell `/opt/setup_workspace.bash`
   2. Build workspace as usual
  
### Initial setup if there is no prepared fork for your project

1. Fork docker_image_development (or create/push this repo to your private/company git server)
2. Clone your fork of docker_image_development (as in "already prepared howto" above)
3. Setup Docker (as above, if not already done on that PC)
4. Edit settings.bash
   1. set the project name, and registry urls (if required)  (defines the name of the images created)
   2. select a base image
5. Prepare a devel image [link](042_Devel_Image.md#create-a-devel-image)), and push it to a registry, if you have one (probably a private one in your company, set in the settings.bash)
6. Set the default execmode to "devel" in settings.bash
7. git push the changes you made in this repo to your fork of docker_image_development (settings.bash, Dockerfiles, setup_workspace.bash)

Other devs can now use the "already prepared" setup above. 

