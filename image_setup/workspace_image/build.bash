
. ../../settings.bash


export BASE_IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_BASE_IMAGE
docker pull $BASE_IMAGE_NAME

IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE

docker build --no-cache -f Dockerfile --build-arg BASE_IMAGE_NAME -t $IMAGE_NAME .


echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME"
echo
