#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/file_handling.bash

SCRIPTSVERSION=$(cat $ROOT_DIR/VERSION | head -n1 | awk -F' ' '{print $1}')

# get a md5 for the current folder used as container name suffix
# (several checkouts  of this repo possible without interfering)
FOLDER_MD5=$(echo $ROOT_DIR | md5sum | cut -b 1-8)

EXECMODES=("base" "devel" "release" "storedrelease" "CD")

PRINT_WARNING=echo
PRINT_INFO=echo
PRINT_DEBUG=:

if [ "$VERBOSE" = true ] && [ "$SILENT" = true ]; then
    echo "Error: cannot be VERBOSE and SILENT at the same time"
    echo "Edit the settings.bash accordingly or if not set there use unset VERBOSE or unset SILENT in your console"
    exit 1
fi

if [ "$VERBOSE" = true ]; then
    PRINT_WARNING=echo
    PRINT_INFO=echo
    PRINT_DEBUG=echo
fi

if [ "$SILENT" = true ]; then
    PRINT_WARNING=:
    PRINT_INFO=:
    PRINT_DEBUG=:
fi

function evaluate_execmode(){
    EXECMODE=$1
    if [ "$EXECMODE" = "" ]; then
        EXECMODE=$DEFAULT_EXECMODE
    fi
}

function check_registry_overrides() {
    # In case you are using CD server and need to use other registries, they can be overridden via env variables
    if [ ! "$OVERRIDE_BASE_REGISTRY" = "" ]; then
        export OLD_BASE_REGISTRY=$BASE_REGISTRY
        export BASE_REGISTRY=$OVERRIDE_BASE_REGISTRY
        $PRINT_DEBUG "Overriding devel registry from $OLD_BASE_REGISTRY to $BASE_REGISTRY"
    fi
    
    if [ ! "$OVERRIDE_DEVEL_REGISTRY" = "" ]; then
        export OLD_DEVEL_REGISTRY=$DEVEL_REGISTRY
        export DEVEL_REGISTRY=$OVERRIDE_DEVEL_REGISTRY
        $PRINT_DEBUG "Overriding devel registry from $OLD_DEVEL_REGISTRY to $DEVEL_REGISTRY"
    fi
    
    if [ ! "$OVERRIDE_RELEASE_REGISTRY" = "" ]; then
        export OLD_RELEASE_REGISTRY=$RELEASE_REGISTRY
        export RELEASE_REGISTRY=$OVERRIDE_RELEASE_REGISTRY
        $PRINT_DEBUG "Overriding devel registry from $OLD_RELEASE_REGISTRY to $RELEASE_REGISTRY"
    fi
}

# DOCKER_REGISTRY and WORKSPACE_${EXECMODE}_IMAGE from settings.bash
function set_image_name(){
    check_registry_overrides
    if [ "$EXECMODE" = "base" ]; then
        IMAGE_NAME=${BASE_REGISTRY:+${BASE_REGISTRY}/}$WORKSPACE_BASE_IMAGE
    fi
    if [ "$EXECMODE" = "devel" ]; then
        IMAGE_NAME=${DEVEL_REGISTRY:+${DEVEL_REGISTRY}/}$WORKSPACE_DEVEL_IMAGE
    fi
    if [ "$EXECMODE" = "release" ]; then
        IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_RELEASE_IMAGE
    fi
    if [ "$EXECMODE" = "storedrelease" ]; then
        set_stored_image_name $1
    fi
    if [ "$EXECMODE" = "CD" ]; then
        IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_CD_IMAGE
        DOCKER_REGISTRY_AUTOPULL=true
    fi
}
