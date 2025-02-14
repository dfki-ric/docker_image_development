#!/bin/bash


# usage build_base_image FROM_IMAGE BASE_IMAGE_NAME INSTALL_SCRIPT [PLATFORM]
build_base_image() {
    export FROM_IMAGE="$1"
    export BASE_IMAGE_NAME=$2
    export INSTALL_SCRIPT=$3
    export PLATFORM=$4

    set -e
    #copy scripts VERSION file to put it into the image
    THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
    cp $ROOT_DIR/VERSION $THIS_DIR/

    . $ROOT_DIR/settings.bash
    export IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}developmentimage/
    export IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}developmentimage/${BASE_IMAGE_NAME}

    if [ "${PLATFORM}" != "" ]; then
        export PLATFORM_ARG="--platform=${PLATFORM}"
        echo building ${IMAGE_NAME} from ${FROM_IMAGE} for ${PLATFORM} architecture
    else
        echo building ${IMAGE_NAME} from ${FROM_IMAGE}
    fi

    docker pull $FROM_IMAGE
    docker build ${PLATFORM_ARG} --no-cache -f $THIS_DIR/Dockerfile -t $IMAGE_NAME:base --build-arg BASE_IMAGE="${FROM_IMAGE}" --build-arg INSTALL_SCRIPT --label "base-image-name=$IMAGE_NAME:base" --label "base-image-created-from=${FROM_IMAGE} - $(docker inspect --format '{{.Id}}' $FROM_IMAGE)" --label "dockerfile_repo_commit=$(git rev-parse HEAD)" $THIS_DIR

    # remove VERSION file from here
    rm -rf $THIS_DIR/VERSION

    echo 
    echo "you can now use $IMAGE_NAME:base as WORKSPACE_BASE_IMAGE in your settings.bash"
    echo
    echo "don't forget to push the image if you wish:"
    echo "docker push $IMAGE_NAME:base"
    echo

}

# make the script also runnable from console
# check if this is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then 
    # this script is run directly and is not sourced by another script
    echo run directly

    #check if coreect number of args a given
    if [ $# -ne 3 ] && [ $# -ne 4 ]; then
        echo "illegal number of parameters"
        echo use: build_base_image.bash FROM_IMAGE BASE_IMAGE_NAME INSTALL_SCRIPT [PLATFORM]
        exit 1
    fi
    # actually build
    build_base_image $1 $2 $3 $4
fi