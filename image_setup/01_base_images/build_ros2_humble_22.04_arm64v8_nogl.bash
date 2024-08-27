#!/bin/bash
set -e

#copy scripts VERSION file to put it into the image
THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
cp $ROOT_DIR/VERSION $THIS_DIR/

. $ROOT_DIR/settings.bash
export IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}developmentimage/ros2_humble_22.04_arm64v8_nogl

export BASE_IMAGE=arm64v8/ubuntu:22.04
export INSTALL_SCRIPT=install_ros2_dependencies.bash

docker pull $BASE_IMAGE
docker build --no-cache -f Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE --build-arg INSTALL_SCRIPT --label "base-image-name=$IMAGE_NAME:base" --label "base-image-created-from=${BASE_IMAGE} - $(docker inspect --format '{{.Id}}' $BASE_IMAGE)" --label "dockerfile_repo_commit=$(git rev-parse HEAD)" .

# remove VERSION file from here
rm -rf VERSION

echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_NAME:base"
echo
