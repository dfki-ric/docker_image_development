#!/bin/bash

set -e

THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/variables.bash

#docker build paramaters
export DATE=$(date)
export TAG=$(date +%Y_%m_%d-%H_%M)
export HOST=$(hostname)
export DEVEL_IMAGE_NAME=${DEVEL_REGISTRY:+${DEVEL_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE

#if [ "$DOCKER_REGISTRY_AUTOPULL" = true ]; then
    #do not pull for release, use the local image, as the release should be based on the exact same devel image
#fi

RELEASE_IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
echo "Buidling release image: ${RELEASE_IMAGE_NAME}_$TAG by $USER on $HOST Date: $DATE"

# tag the docker development repo with the release date
git tag -a release_$TAG -m"${RELEASE_IMAGE_NAME}_$TAG"
# tag the devel image used to create the release (for extracting workspaces later)
docker tag $DEVEL_IMAGE_NAME ${DEVEL_IMAGE_NAME}_$TAG

docker build --no-cache --build-arg DEVEL_IMAGE_NAME --build-arg USER --build-arg HOST --build-arg DATE -f $THIS_DIR/Dockerfile -t $RELEASE_IMAGE_NAME --label "release-image-name=$RELEASE_IMAGE_NAME" --label "release-image-created-from=${DEVEL_IMAGE_NAME} - $(docker inspect --format '{{.Id}}' $DEVEL_IMAGE_NAME)" --label "dockerfile_repo_commit=$(git rev-parse HEAD)" $ROOT_DIR

echo "tagging $RELEASE_IMAGE_NAME as ${RELEASE_IMAGE_NAME}_$TAG"
docker tag $RELEASE_IMAGE_NAME ${RELEASE_IMAGE_NAME}_$TAG

echo
echo "don't forget to push or store the image, if you wish:"
echo "docker push $RELEASE_IMAGE_NAME"
echo "docker push ${RELEASE_IMAGE_NAME}_$TAG"
echo "docker push ${DEVEL_IMAGE_NAME}_$TAG"
echo "bash store.bash ${RELEASE_IMAGE_NAME}_$TAG <SHORTNAME>"
echo
