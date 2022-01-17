#get a md5 for the curretn folder used as container name suffix
#(several checkouts  of this repo possible without interfering)
ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
FOLDER_MD5=$(echo $ROOT_DIR | md5sum | cut -b 1-8)

source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/file_handling.bash
source $ROOT_DIR/.docker_scripts/variables.bash

# stop on error
set -e

EXECMODE=$1

if [ "$EXECMODE" = "" ]; then
    EXECMODE=$DEFAULT_EXECMODE
fi
if [ "$EXECMODE" = "CD" ]; then
    EXECMODE="release"
fi

#use current folder name + $EXECMODE + path md5 as container name
#(several checkouts  of this repo possible withtout interfering)
CONTAINER_NAME="${ROOT_DIR##*/}-$EXECMODE-$FOLDER_MD5"

$PRINT_INFO "stopping ${CONTAINER_NAME}"
docker stop ${CONTAINER_NAME} > /dev/null || true
docker rm ${CONTAINER_NAME} > /dev/null
$PRINT_INFO "successfully removed ${CONTAINER_NAME}"
write_value_to_config_file $EXECMODE "deleted"
