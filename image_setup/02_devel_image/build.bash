#!/bin/bash

THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/src/variables.bash

export BASE_IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}$WORKSPACE_BASE_IMAGE

IMAGE_NAME=${DEVEL_REGISTRY:+${DEVEL_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE

if [ "$DOCKER_REGISTRY_AUTOPULL" = true ]; then
    echo
    echo pulling image: $BASE_IMAGE_NAME
    echo
    docker pull $BASE_IMAGE_NAME
fi

docker build --no-cache -f $THIS_DIR/Dockerfile --build-arg BASE_IMAGE_NAME -t $IMAGE_NAME --label "devel-image-name=$IMAGE_NAME" --label "devel-image-created-from=${BASE_IMAGE_NAME} - $(docker inspect --format '{{.Id}}' $BASE_IMAGE_NAME)" --label "dockerfile_repo_commit=$(git rev-parse HEAD)" $THIS_DIR


echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME"
echo
