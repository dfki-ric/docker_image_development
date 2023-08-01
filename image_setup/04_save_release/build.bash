#!/bin/bash

set -e

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
THIS_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $ROOT_DIR/settings.bash

if [ "$DEFAULT_EXECMODE" = "devel" ]; then
    echo "the DEFAULT_EXECMODE variable has to be release in the settings.bash in order to export"
    exit 1
fi

TARGETPATH=$THIS_DIR
if [ $# -eq 1 ]; then
    TARGETPATH=$1
    if [ ! -d "$TARGETPATH" ]; then
        echo "folder not found: $TARGETPATH"
        exit 1
    fi
fi

export DATE=$(date +%Y_%m_%d-%H_%M)

PROJECT_NAME_NO_SUBFOLDER=${PROJECT_NAME//\//_}

IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
SCRIPTFOLDER=${PROJECT_NAME_NO_SUBFOLDER}_scripts_${DATE}

mkdir -p $SCRIPTFOLDER
#build a scripts zip:
echo "creating scripts archive: $SCRIPTFOLDER.tar.gz"
cp -R $ROOT_DIR/.docker_scripts/ ./$SCRIPTFOLDER/.docker_scripts/
cp $ROOT_DIR/settings.bash ./$SCRIPTFOLDER/
cp $ROOT_DIR/exec.bash ./$SCRIPTFOLDER/
cp $ROOT_DIR/stop.bash ./$SCRIPTFOLDER/
cp $ROOT_DIR/delete_container.bash ./$SCRIPTFOLDER/
cp $ROOT_DIR/VERSION ./$SCRIPTFOLDER/
cp $ROOT_DIR/doc/010_Setup_Docker.md ./$SCRIPTFOLDER/Readme_Docker.md
cp $THIS_DIR/Readme_scripts.md ./$SCRIPTFOLDER/Readme.md
echo "complete -W \"$(ls $ROOT_DIR/startscripts | xargs) /bin/bash\" ./exec.bash" >> $SCRIPTFOLDER/autocomplete.me
tar czf ${TARGETPATH}/$SCRIPTFOLDER.tar.gz $SCRIPTFOLDER
rm -rf $SCRIPTFOLDER


echo "saving ${IMAGE_NAME} to ${TARGETPATH}/${PROJECT_NAME_NO_SUBFOLDER}_image_${DATE}.tar.gz"
docker save ${IMAGE_NAME} | gzip > ${TARGETPATH}/${PROJECT_NAME_NO_SUBFOLDER}_image_${DATE}.tar.gz
