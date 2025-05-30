#!/bin/bash

set -e

THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/variables.bash

check_registry_overrides

#docker build paramaters
export DATE=$(date)
export TAG=$(date +%Y_%m_%d-%H_%M)
export HOST=$(hostname)
export DEVEL_IMAGE_NAME=${DEVEL_REGISTRY:+${DEVEL_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE

#if [ "$DOCKER_REGISTRY_AUTOPULL" = true ]; then
    #do not pull for release, use the local image, as the release should be based on the exact same devel image
#fi

FROZEN_IMAGE_NAME=${FROZEN_REGISTRY:+${FROZEN_REGISTRY}/}$WORKSPACE_FROZEN_IMAGE
echo "Buidling release image: ${FROZEN_IMAGE_NAME}_$TAG by $USER on $HOST Date: $DATE"

# tag the docker development repo with the release date
git tag -a frozen_$TAG -m"${FROZEN_IMAGE_NAME}_$TAG"
# tag the devel image used to create the release (for extracting workspaces later)
docker tag $DEVEL_IMAGE_NAME ${DEVEL_IMAGE_NAME}_$TAG

docker build --no-cache --build-arg DEVEL_IMAGE_NAME --build-arg USER --build-arg HOST --build-arg DATE -f $THIS_DIR/Dockerfile -t $FROZEN_IMAGE_NAME --label "frozen-image-name=$FROZEN_IMAGE_NAME" --label "frozen-image-created-from=${DEVEL_IMAGE_NAME} - $(docker inspect --format '{{.Id}}' $DEVEL_IMAGE_NAME)" --label "dockerfile_repo_commit=$(git rev-parse HEAD)" $ROOT_DIR

echo "tagging $FROZEN_IMAGE_NAME as ${FROZEN_IMAGE_NAME}_$TAG"
docker tag $FROZEN_IMAGE_NAME ${FROZEN_IMAGE_NAME}_$TAG

echo
echo "don't forget to push or store the image, if you wish:"
echo "docker push $FROZEN_IMAGE_NAME"
echo "docker push ${FROZEN_IMAGE_NAME}_$TAG"
echo "docker push ${DEVEL_IMAGE_NAME}_$TAG"
echo "bash store.bash ${FROZEN_IMAGE_NAME}_$TAG <SHORTNAME>"
echo
