. ../../settings.bash

#docker buidl paramaters
export DATE=$(date)
export TAG=$(date +%Y_%m_%d-%H_%M)
export HOST=$(hostname)
export DEVEL_IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE

#if [ "$DOCKER_REGISTRY_AUTOPULL" = true ]; then
    #do not pull for release, use the local image, as the release should be based on the exact same devel image
#fi

RELEASE_IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
echo "Buidling release image: ${RELEASE_IMAGE_NAME}_$TAG by $USER on $HOST Date: $DATE"

docker build --no-cache --build-arg DEVEL_IMAGE_NAME --build-arg USER --build-arg HOST --build-arg DATE -f Dockerfile -t $RELEASE_IMAGE_NAME ../..

echo "tagging $RELEASE_IMAGE_NAME as ${RELEASE_IMAGE_NAME}_$TAG"
docker tag $RELEASE_IMAGE_NAME ${RELEASE_IMAGE_NAME}_$TAG

echo
echo "don't forget to push the image if you wish:"
echo "docker push $RELEASE_IMAGE_NAME"
echo "docker push ${RELEASE_IMAGE_NAME}_$TAG"
echo


