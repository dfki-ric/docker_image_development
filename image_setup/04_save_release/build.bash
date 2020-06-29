#!/bin/bash

. ../../settings.bash

if [ "$DEFAULT_EXECMODE" = "devel" ]; then
    echo "the $DEFAULT_EXECMODE has to be release in the settings.bash in order to export"
    exit 1
fi

export DATE=$(date +%Y_%m_%d-%H_%M)

IMAGE_NAME=${DOCKER_REGISTRY:+${DOCKER_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE

echo "saving ${IMAGE_NAME} to ${PROJECT_NAME}_image_${DATE}.tar.gz"

docker save ${IMAGE_NAME} | gzip > ${PROJECT_NAME}_image_${DATE}.tar.gz


#build a scripts zip:
echo creating scripts archive

mkdir -p ${PROJECT_NAME}_scripts_${DATE}
cd ${PROJECT_NAME}_scripts_${DATE}
cp ../../../docker_commands.bash ./
cp ../../../settings.bash ./
cp ../../../exec.bash ./
cp ../../../stop.bash ./

echo "complete -W \"$(ls ../../../startscripts | xargs) /bin/bash\" ./exec.bash" >> autocomplete.me


cp ../Readme_scripts.md ./Readme.md

cd ..
tar czf ${PROJECT_NAME}_scripts_${DATE}.tar.gz ${PROJECT_NAME}_scripts_${DATE}

rm -rf ${PROJECT_NAME}_scripts_${DATE}


