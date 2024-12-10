#!/bin/bash

if [ "$1" = "" ]; then 
    echo "you need to provide a (short) name for the stored image"
    echo "bash store.bash IMAGENAME SHORTNAME"
    exit 1
fi

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
source $ROOT_DIR/settings.bash
source $ROOT_DIR/.docker_scripts/variables.bash

STORED_IMAGE_NAME=$2
RELEASE_IMAGE_NAME=$1

if [[ " ${EXECMODES[*]} " =~ " ${RELEASE_IMAGE_NAME##*:} " ]]; then
    $PRINT_WARNING "Trying to store image with plain <${RELEASE_IMAGE_NAME##*:}> tag."
    $PRINT_WARNING "This tag is not unique and might cause the stored image to be overwritten!"
    $PRINT_WARNING "Please use a unique name, e.g. the date tagged release image, or manually tag the image before storing."
    exit
fi

STORED_IMAGES_FILE=$ROOT_DIR/.stored_images.txt

# create image list, if not available
if [ ! -f $STORED_IMAGES_FILE ]; then
    echo "# do not edit! this file is generated and updated automatically when running image_setup/03_release/store.bash" >> $STORED_IMAGES_FILE
fi

# add entry
OLDLINE=$(cat $STORED_IMAGES_FILE | grep $STORED_IMAGE_NAME)
NEWLINE="$STORED_IMAGE_NAME=$RELEASE_IMAGE_NAME"

if [ "$OLDLINE" = "" ]; then 
    # new value, just append
    echo "$NEWLINE" >> $STORED_IMAGES_FILE
else
    # value exists, replace line, using | as delimiter because / is part of the image name
    read -p "An image with tag <$STORED_IMAGE_NAME> is already used. Do you wish to overwrite? (Y/N): " overwrite && [[ $overwrite == [yY] || $overwrite == [yY][eE][sS] ]] || exit 1
    sed -i "s|$OLDLINE|$NEWLINE|g" $STORED_IMAGES_FILE
fi

git add $STORED_IMAGES_FILE

read -p "push stored image? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] && docker push $RELEASE_IMAGE_NAME

$PRINT_INFO
$PRINT_INFO "Please commit and push the .stored_images.txt in the main repository"
$PRINT_INFO
