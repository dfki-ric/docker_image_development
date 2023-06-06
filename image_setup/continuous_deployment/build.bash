#/!bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
CD_ROOT_DIR=$ROOT_DIR
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/variables.bash

# exit this script on first error
set -e
# print all commands (don't expand vars)
set -v

catch_exit_err(){
    echo "some part ended with error, deleting credentials and exiting"
    ./exec.bash devel /opt/startscripts/continuous_deployment_hooks/delete_git_credentials
    echo "credentials deleted, exiting"
    exit 1
}
# call catch_exit_err on error exit codes
trap "catch_exit_err" ERR

# REBUILD_DEVEL can be set to "rebuild_devel" to build a new devel image
# if env already set, use external set value
# you can use this if your console does not support inputs (e.g. a jenkins build job)
REBUILD_DEVEL=${REBUILD_DEVEL:="false"}

# put ./exec script in silent mode
export SILENT=true

####################################### FUNCTION DEFINITIONS ###
patch_settings_file(){
    # remove mounting host directories
  $PRINT_DEBUG "Patching settings.bash file"
  $PRINT_DEBUG "  Removing directory mounts"
  sed -iE 's/-v *([a-zA-Z0-9\/]+):([a-zA-Z0-9\/]+)//g' ${ROOT_DIR}/settings.bash
  $PRINT_DEBUG "  Removing privileged argument"
  sed -i 's/--privileged//g' ${ROOT_DIR}/settings.bash
}

store_git_credentials(){    
    # Use git credential.helper store (it is stored in home folder), delete before building release
    # Params have to be set outside of this script by your CI/CD implementation/server
    ./exec.bash devel /opt/startscripts/continuous_deployment_hooks/init_git
    ${PRINT_INFO} "calling store_git_credentials for $GIT_USER on $GIT_SERVER"
    ./exec.bash devel "/opt/startscripts/continuous_deployment_hooks/store_git_credentials ${GIT_USER} ${GIT_ACCESS_TOKEN} ${GIT_SERVER}"
}

build_devel_image(){
    bash ${CD_ROOT_DIR}/image_setup/02_devel_image/build.bash
}

build_or_pull_devel_image(){
    if [ "$REBUILD_DEVEL" = "true" ]; then 
        # build initial devel image
        build_devel_image
    else
        # update devel image even in case it is not enabled in settings.bash
        bash ${CD_ROOT_DIR}/tools/update_image.bash devel || ( XTMP=$? && \
             ${PRINT_WARNING} -e "\nUnable to pull devel image from registry. Set environment variable REBUILD_DEVEL to true to build devel image from scratch." && \
             exit ${XTMP} )
    fi
}

setup_workspace(){
    # TODO setup_workspace.bash must be non-interactive
    ./exec.bash devel /opt/setup_workspace.bash store
}

update_workspace_dependencies()
{
    ./exec.bash devel /opt/write_osdeps.bash
}

####################################################### MAIN ###
${PRINT_DEBUG} "Continuous deployment uses ${CD_ROOT_DIR} as root dir."
cd ${CD_ROOT_DIR}

check_registry_overrides

patch_settings_file

build_or_pull_devel_image

store_git_credentials

setup_workspace

update_workspace_dependencies

build_devel_image

# build workspace
./exec.bash devel /opt/startscripts/continuous_deployment_hooks/build

# the credentails have to be deleted before the release is build
./exec.bash devel /opt/startscripts/continuous_deployment_hooks/delete_git_credentials

# build the release image
bash ${CD_ROOT_DIR}/image_setup/03_release_image/build.bash

# run the tests
./exec.bash release "/opt/startscripts/continuous_deployment_hooks/test"

RELEASE_IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
CD_IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_CD_IMAGE
echo "Using $CD_IMAGE_NAME to tag $RELEASE_IMAGE_NAME"
docker tag $RELEASE_IMAGE_NAME $CD_IMAGE_NAME
echo "Tagged CD image: $WORKSPACE_CD_IMAGE"
