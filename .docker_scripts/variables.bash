#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/settings.bash

# In case you are using CD server and need to use other registries, they can be overridden via env variables
if [ ! "$OVERRIDE_BASE_REGISTRY" = "" ]; then
    export OLD_BASE_REGISTRY=$BASE_REGISTRY
    export BASE_REGISTRY=$OVERRIDE_BASE_REGISTRY
fi

if [ ! "$OVERRIDE_DEVEL_REGISTRY" = "" ]; then
    export OLD_DEVEL_REGISTRY=$DEVEL_REGISTRY
    export DEVEL_REGISTRY=$OVERRIDE_DEVEL_REGISTRY
fi

if [ ! "$OVERRIDE_RELEASE_REGISTRY" = "" ]; then
    export OLD_RELEASE_REGISTRY=$RELEASE_REGISTRY
    export RELEASE_REGISTRY=$OVERRIDE_RELEASE_REGISTRY
fi

SCRIPTSVERSION=$(cat $ROOT_DIR/VERSION | head -n1 | awk -F' ' '{print $1}')

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

# get a md5 for the current folder used as container name suffix
# (several checkouts  of this repo possible without interfering)
FOLDER_MD5=$(echo $ROOT_DIR | md5sum | cut -b 1-8)
