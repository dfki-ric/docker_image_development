
echo "If you have re-build the base image, it has to be pushed to the registry bebore the workspace image is build"
read -r -p "Are you sure to build now? [y/N] " response
if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    echo "no"
    exit 0
fi

. ../../settings.bash


export BASE_IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_BASE_IMAGE
docker pull $BASE_IMAGE_NAME

IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE

docker build --no-cache -f Dockerfile --build-arg BASE_IMAGE_NAME -t $IMAGE_NAME .


echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME"
echo
