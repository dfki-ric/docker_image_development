xhost +local:root

#if [ $# -lt 2  ] ;then
#     echo "Incorrect usage. Use: docker-run.sh <param1> <param2>"
#     echo "<param1>: Give the global path to the folder that will be the workspace on the local host machine"
#     exit 1
#fi

HOST_WORKSPACE=$(pwd)
CONTAINER_NAME=ros-melodic-devel-18.04-mare-it

#remove first two params from $@
#shift

mkdir -p $HOST_WORKSPACE/workspace
mkdir -p $HOST_WORKSPACE/home

DNSIP=$(nmcli dev show | grep 'IP4.DNS' | grep "\[1\]" | \
    egrep -oe "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}")

docker run -ti --runtime=nvidia \
           -v $HOST_WORKSPACE/workspace/:/opt/workspace -v $HOST_WORKSPACE/home/:/home/devel \
           -e NUID=$(id -u) -e NGID=$(id -g) \
           -u devel \
           --dns $DNSIP \
           -e DISPLAY -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix \
           --name $CONTAINER_NAME \
           d-reg.hb.dfki.de/mare-it/uuv-sim_18.04:latest
