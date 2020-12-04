. ../../settings.bash

#docker build paramaters
export DATE=$(date)
export TAG=$(date +%Y_%m_%d-%H_%M)
export HOST=$(hostname)
export DEVEL_IMAGE_NAME=${DEVEL_REGISTRY:+${DEVEL_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE
[ "$ARCH" != "x86_64" ] && export DEVEL_IMAGE_NAME=$(dirname $DEVEL_IMAGE_NAME)/$ARCH/$(basename $DEVEL_IMAGE_NAME)

#if [ "$DOCKER_REGISTRY_AUTOPULL" = true ]; then
    #do not pull for release, use the local image, as the release should be based on the exact same devel image
#fi

IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
[ "$ARCH" != "x86_64" ] && IMAGE_NAME=$(dirname $IMAGE_NAME)/$ARCH/$(basename $IMAGE_NAME)
echo "Buidling release image: ${IMAGE_NAME}_$TAG by $USER on $HOST Date: $DATE"

docker build --no-cache --build-arg DEVEL_IMAGE_NAME --build-arg USER --build-arg HOST --build-arg DATE -f Dockerfile -t $IMAGE_NAME ../..

echo "tagging $IMAGE_NAME as ${IMAGE_NAME}_$TAG"
docker tag $IMAGE_NAME ${IMAGE_NAME}_$TAG

echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME"
echo "docker push ${IMAGE_NAME}_$TAG"
echo
