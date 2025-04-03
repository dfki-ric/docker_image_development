#!/bin/bash

set -e

# set executable to be contained in the image
export FILELIST=filelist.txt

THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/variables.bash


#docker build paramaters
export DATE=$(date)
export TAG=$(date +%Y_%m_%d-%H_%M)
export HOST=$(hostname)
export DEVEL_IMAGE_NAME=${DEVEL_REGISTRY:+${DEVEL_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE

RELEASE_IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}${WORKSPACE_RELEASE_IMAGE}
echo "Buidling minimal release image: ${RELEASE_IMAGE_NAME}_$TAG by $USER on $HOST Date: $DATE"



#run collect_dependencies in devel docker
echo "collecting dependencies from devel image"

cp $THIS_DIR/$FILELIST $ROOT_DIR/workspace/
cd $ROOT_DIR
./exec.bash devel /opt/collect_dependencies.bash $FILELIST minimal_release
./stop.bash devel
cd $THIS_DIR
#rm -rf $ROOT_DIR/workspace/additional_workspace_files.txt

rm -rf dependencies.tar.gz || true
mv $ROOT_DIR/workspace/dependencies.tar ./

docker build --no-cache --build-arg EXECUTABLE=$EXECUTABLE --build-arg EXECUTABLE_PARAMS="$EXECUTABLE_PARAMS" --build-arg DISTRO_IMAGE -f $THIS_DIR/Dockerfile -t $RELEASE_IMAGE_NAME --label "release-image-name=$RELEASE_IMAGE_NAME" --label "release-image-created-from=${DEVEL_IMAGE_NAME} - $(docker inspect --format '{{.Id}}' $DEVEL_IMAGE_NAME)" --label "dockerfile_repo_commit=$(git rev-parse HEAD)" $THIS_DIR

echo "tagging $RELEASE_IMAGE_NAME as ${RELEASE_IMAGE_NAME}_$TAG"
docker tag $RELEASE_IMAGE_NAME ${RELEASE_IMAGE_NAME}_$TAG

echo
echo "don't forget to push or store the image, if you wish:"
echo "docker push $RELEASE_IMAGE_NAME"
echo "docker push ${RELEASE_IMAGE_NAME}_$TAG"
echo "bash store.bash ${RELEASE_IMAGE_NAME}_$TAG <SHORTNAME>"
echo

