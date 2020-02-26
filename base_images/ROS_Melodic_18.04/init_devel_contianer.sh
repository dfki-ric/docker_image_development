xhost +local:root

if [ $# -lt 2  ] ;then
     echo "Incorrect usage. Use: docker-run.sh <param1> <param2>"
     echo "<param1>: Give the global path to the folder that will be the workspace on the local host machine"
     echo "<param2>: Give the name of the container you are about to create"
     exit 1
fi

HOST_WORKSPACE=$1
CONTAINER_NAME=$2

#remove first two params from $@
shift
shift

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
           d-reg.hb.dfki.de/rosbasic/melodic_18.04:latest \
           $@ \


xhost -local:root


