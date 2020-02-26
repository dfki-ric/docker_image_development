

export BASE_IMAGE=nvidia/opengl:1.0-glvnd-devel-ubuntu18.04
export INSTALL_SCRIPT=install_ros_dependencies.sh


docker build -f Dockerfile -t d-reg.hb.dfki.de/rosbasic/melodic_18.04:latest --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT .




