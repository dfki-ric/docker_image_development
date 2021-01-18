#!/bin/bash

. ../../settings.bash

if [ "$DEFAULT_EXECMODE" = "devel" ]; then
    echo "the $DEFAULT_EXECMODE has to be release in the settings.bash in order to export"
    exit 1
fi

export DATE=$(date +%Y_%m_%d-%H_%M)

PROJECT_NAME_NO_SUBFOLDER=${PROJECT_NAME//\//_}

IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
SCRIPTFOLDER=${PROJECT_NAME_NO_SUBFOLDER}_scripts_${DATE}

mkdir -p $SCRIPTFOLDER
# build a scripts zip:
echo "creating scripts archive: $SCRIPTFOLDER.tar.gz"
cp ../../docker_commands.bash ./$SCRIPTFOLDER/
cp ../../settings.bash ./$SCRIPTFOLDER/
cp ../../exec.bash ./$SCRIPTFOLDER/
cp ../../stop.bash ./$SCRIPTFOLDER/
cp ../../doc/010_Setup_Docker.md ./$SCRIPTFOLDER/Readme_Docker.md
cp ./Readme_scripts.md ./$SCRIPTFOLDER/Readme.md
echo "complete -W \"$(ls ../../startscripts | xargs) /bin/bash\" ./exec.bash" >> $SCRIPTFOLDER/autocomplete.me
tar czf $SCRIPTFOLDER.tar.gz $SCRIPTFOLDER
rm -rf $SCRIPTFOLDER


echo "saving ${IMAGE_NAME} to ${PROJECT_NAME_NO_SUBFOLDER}_image_${DATE}.tar.gz"
docker save ${IMAGE_NAME} | gzip > ${PROJECT_NAME_NO_SUBFOLDER}_image_${DATE}.tar.gz
