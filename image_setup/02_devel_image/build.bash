
. ../../settings.bash

export BASE_IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}$WORKSPACE_BASE_IMAGE
IMAGE_NAME=${DEVEL_REGISTRY:+${DEVEL_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE

[ "$ARCH" != "x86_64" ] && export BASE_IMAGE_NAME=$(dirname $BASE_IMAGE_NAME)/$ARCH/$(basename $BASE_IMAGE_NAME)
[ "$ARCH" != "x86_64" ] && IMAGE_NAME=$(dirname $IMAGE_NAME)/$ARCH/$(basename $IMAGE_NAME)


if [ "$DOCKER_REGISTRY_AUTOPULL" = true ]; then
    echo
    echo pulling image: $BASE_IMAGE_NAME
    echo
    docker pull $BASE_IMAGE_NAME
fi

docker build --no-cache -f Dockerfile --build-arg BASE_IMAGE_NAME -t $IMAGE_NAME .


echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME"
echo
