
docker pull d-reg.hb.dfki.de/docker_development/ros_melodic_18.04:latest

docker build --no-cache -f Dockerfile -t d-reg.hb.dfki.de/mare-it/uuv-sim_18.04:devel .
