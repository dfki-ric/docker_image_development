

IMAGE_NAME=d-reg.hb.dfki.de/docker_development/plain_18.04

export BASE_IMAGE=nvidia/opengl:1.0-glvnd-devel-ubuntu18.04
export INSTALL_SCRIPT=install_plain_dependencies.sh

docker pull $BASE_IMAGE
docker build --no-cache -f Dockerfile -t $IMAGE_NAME:latest --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT .



echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME:latest"
echo
