
docker pull d-reg.hb.dfki.de/docker_development/ros_melodic_18.04:latest

IMAGE_BASENAME=d-reg.hb.dfki.de/mare-it/uuv-sim_18.04

docker build --no-cache -f Dockerfile -t $IMAGE_BASENAME:devel .


echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_BASENAME:devel"
echo
