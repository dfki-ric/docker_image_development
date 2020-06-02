#get a md5 for the curretn folder used as container name suffix
#(several checkouts  of this repo possible withtou interfering)
FOLDER_MD5=$(echo $(pwd) | md5sum | cut -b 1-8)

. ./settings.bash

EXECMODE=$DEFAULT_EXECMODE

if [ "$1" = "devel" ]; then
    EXECMODE="devel"
    shift
fi
if [ "$1" = "release" ]; then
    EXECMODE="release"
    shift

fi

#use current folder name + $EXECMODE + path md5 as container name
#(several checkouts  of this repo possible withtout interfering)
CONTAINER_NAME="${PWD##*/}-$EXECMODE-$FOLDER_MD5"

echo "stopping ${CONTAINER_NAME}"
docker stop ${CONTAINER_NAME}