#/!bin/bash

# exit this scritp on first error
set -e

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )

catch_exit_err(){
    echo "some part ended with error, deleting credentials and exiting"
    ./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/delete_git_credentials
    echo "credentials deleted, exiting"
    exit 1
}
# call catch_exit_err on error exit codes
trap "catch_exit_err" ERR


echo ${ROOT_DIR}

# build initial devel image
cd ${ROOT_DIR}/image_setup/02_devel_image
bash build.bash

cd ${ROOT_DIR}

# Use git credential.helper store (it is stored in home folder), delete before building release
# Params have to be set outside of this script by your CI/CD implementation/server
./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/init_git
./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/store_git_credentials $GIT_USER $GIT_ACCESS_TOKEN $GIT_SERVER

# TODO setup_workspace.bash should be non-interactive
./exec.bash devel /opt/setup_workspace.bash

# write osdeps to external file
./exec.bash devel /opt/write_osdeps.bash

# build a devel image with dependencies
cd ${ROOT_DIR}/image_setup/02_devel_image
bash build.bash

cd ${ROOT_DIR}
./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/build

# the credentails have to be deleted before the release is build
./exec.bash devel /opt/startscripts/ContinuousDeploymentHooks/delete_git_credentials

# build the release image
cd ${ROOT_DIR}/image_setup/03_release_image
bash build.bash


