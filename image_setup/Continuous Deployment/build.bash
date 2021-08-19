#/!bin/bash

. ../../settings.bash

# REBUILD_DEVEL can be set to "rebuild_devel" to build a new devel image
# if env already set, use external set value
# you can use this if your console does not support inputs (e.g. a jenkins build job)
REBUILD_DEVEL=${REBUILD_DEVEL:="false"}

# exit this scritp on first error
set -e

#print all commands (don't expand vars)
set -v

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )

catch_exit_err(){
    echo "some part ended with error, deleting credentials and exiting"
    ./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/delete_git_credentials
    echo "credentials deleted, exiting"
    exit 1
}
# call catch_exit_err on error exit codes
trap "catch_exit_err" ERR

export SILENT=true

echo ${ROOT_DIR}
cd ${ROOT_DIR}

if [ "$REBUILD_DEVEL" = "true" ]; then 
    # build initial devel image
    cd ${ROOT_DIR}/image_setup/02_devel_image
    bash build.bash
    cd ${ROOT_DIR}
fi

# Use git credential.helper store (it is stored in home folder), delete before building release
# Params have to be set outside of this script by your CI/CD implementation/server
./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/init_git
echo "calling store_git_credentials for $GIT_USER on $GIT_SERVER"
./exec.bash devel "/opt/startscripts/ContinuousDeploymentHooks/store_git_credentials ${GIT_USER} ${GIT_ACCESS_TOKEN} ${GIT_SERVER}"

# TODO setup_workspace.bash should be non-interactive
./exec.bash devel /opt/setup_workspace.bash store

if [ "$REBUILD_DEVEL" = "true" ]; then 
    # write osdeps to external file
    ./exec.bash devel /opt/write_osdeps.bash
    # build a devel image with dependencies
    cd ${ROOT_DIR}/image_setup/02_devel_image
    bash build.bash
    cd ${ROOT_DIR}
fi

./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/build

# the credentails have to be deleted before the release is build
./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/delete_git_credentials

# build the release image
cd ${ROOT_DIR}/image_setup/03_release_image
bash build.bash

RELEASE_IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
CD_IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_CD_IMAGE
docker tag $RELEASE_IMAGE_NAME $CD_IMAGE_NAME
echo "Tagged CD image: $WORKSPACE_CD_IMAGE"
