xhost +local:root

if [ $# -lt 1  ] || [ $# -gt 1  ] ;then
     echo "Incorrect usage. Use: docker-run.sh <param1>"
     echo "<param1>: Give the path to the folder that will be the workspace on the local machine"
     exit 1
fi
mkdir -p $1/dev
mkdir -p $1/home

docker run -ti --runtime=nvidia \
           -v $1/dev/:/opt/devel -v $1/home/:/home/devel \
           -e NUID=$(id -u) -e NGID=$(id -g) \
           -e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix \
           --name ros-melodic-devel-18.04-mare-it \
           d-reg.hb.dfki.de/mare-it/uuv-sim_18.04:latest





