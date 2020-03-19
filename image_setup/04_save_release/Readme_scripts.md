# Load image into docker

`docker load < dockerimage.tar.gz`

# running

`bash exec_in_release.bash bash` - run a bash inside the container
`bash exec_in_release.bash hello_world` - a hello_world program

# 3D acceleration

When you have nvidia-docker running, the image supports 3d acceleration

To enable 3d acceleration, install it based on htis instructions:

https://github.com/NVIDIA/nvidia-docker

IMPORTANT: The install howto of nvidia-docker also states that you need docker 19.03 from docker.com
as long this version is not in the ubuntu sources

IMPORTANT: In order to allpy new settings (like 3d Acceleration), the container and saved settings have to be reset: `rm -rf has_gpu_support.txt release-container_id.txt`


