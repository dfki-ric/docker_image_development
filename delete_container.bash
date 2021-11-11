#get a md5 for the curretn folder used as container name suffix
#(several checkouts  of this repo possible without interfering)
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
FOLDER_MD5=$(echo $ROOT_DIR | md5sum | cut -b 1-8)

source $ROOT_DIR/docker_commands.bash

# stop on error
set -e

EXECMODE=$DEFAULT_EXECMODE

if [ "$1" = "base" ]; then
    EXECMODE="base"
    shift
fi
if [ "$1" = "devel" ]; then
    EXECMODE="devel"
    shift
fi
if [ "$1" = "release" ]; then
    EXECMODE="release"
    shift
fi
if [ "$1" = "CD" ]; then
    EXECMODE="release"
    shift
fi
if [ "$1" = "storedrelease" ]; then
    EXECMODE="storedrelease"
    shift
fi

#use current folder name + $EXECMODE + path md5 as container name
#(several checkouts  of this repo possible withtout interfering)
CONTAINER_NAME="${ROOT_DIR##*/}-$EXECMODE-$FOLDER_MD5"

echo "stopping ${CONTAINER_NAME}"
docker stop ${CONTAINER_NAME} > /dev/null || true
docker rm ${CONTAINER_NAME} > /dev/null || true
echo "successfully removed ${CONTAINER_NAME}"
write_value_to_config_file $EXECMODE "deleted"
