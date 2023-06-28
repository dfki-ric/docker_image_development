## Initial Set-Up if someone already prapared a docker_image_development clone for your project

1. Clone the your docker_image_development
   1. `git clone git@git.hb.dfki.de:MY_PROJECT/docker_image_development.git` PROJECTNAME
   2. `cd PROJECTNAME`
3. Setup Docker (if not already done on that PC):
   1. sudo apt install docker.io
   2. sudo adduser $(id -un) docker
   3. Optionally setup (nvidia 3D accelleration)[010_Setup_Docker.md#nvidia-docker-optional]
   4. Logout of computer and login again   
4. Prepare pulling the image (if need to pull new image):
   1. If you have a private registry for the devel images:
     1. Connect VPN (if you need it)
     2. Do Registry Login e.g. `docker login USER@d-reg.hb.dfki.de` ([one time setup steps and more info](010_Setup_Docker.md#using-a-registry))
5. Pull image and start container (if not already available, [additional information](042_Devel_Image.md#run-from-a-devel-image))
   1. `./exec.bash devel`
6. Setup workspace:
   1. Run workspace setup in container shell `/opt/setup_workspace.bash`
   2. Build workspace as usual
