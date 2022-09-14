#/!bin/bash

# Copies/Synchronizes folders that are mounted to the devel image to a remote server
# This allows for compiling code on a workstation/laptop and deploy the compiled
# development code to a server or remote pc and execute the freshly compiled code there
# without creating and deploying a release image (after initial copy only changed files are
# uploaded to the remote)

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
echo $ROOT_DIR

# check if paramaters are given
if [ "$#" -ne 3 ]; then
    echo "usage: sync_workspace.bash SSH_USER HOST FOLDER_ON_HOST"
    exit 1
fi

USER=$1
HOST=$2
DOCKER_GIT_REPO_FOLDER=$3

DIRS="$ROOT_DIR/startscripts $ROOT_DIR/home $ROOT_DIR/workspace"

echo "uploading workspace files to $HOST:$DOCKER_GIT_REPO_FOLDER"
du -hs $DIRS
rsync --archive --compress --info=progress2 $DIRS $USER@$HOST:$DOCKER_GIT_REPO_FOLDER/



