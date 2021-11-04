#!/bin/bash

if [ "$1" = "" ]; then 
    echo "you need to provide a (short) name for the stored image"
    echo "bash store.bash IMAGENAME SHORTNAME"
    exit 1
fi

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )
source $ROOT_DIR/settings.bash

STORED_IMAGE_NAME=$2
RELEASE_IMAGE_NAME=$1
STORED_IMAGES_FILE=$ROOT_DIR/.stored_images.txt

# create image list, if not available
if [ ! -f $STORED_IMAGES_FILE ]; then
    echo "# do not edit, this file is generated and updated automatically when running image_setup/03_release/store.bash" >> $STORED_IMAGES_FILE
    git add $STORED_IMAGES_FILE
fi

#add entry
OLDLINE=$(cat $STORED_IMAGES_FILE | grep $STORED_IMAGE_NAME)
NEWLINE="$STORED_IMAGE_NAME=$RELEASE_IMAGE_NAME"

if [ "$OLDLINE" = "" ]; then 
    # new value, just append
    echo "$NEWLINE" >> $STORED_IMAGES_FILE
else
    #value exists, replace line, using | a delimiter because / is part of the image name
    sed -i "s|$OLDLINE|$NEWLINE|g" $STORED_IMAGES_FILE
fi

read -p "push stored image? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

docker push $RELEASE_IMAGE_NAME

echo
echo "Please commit and push the .stored_images.txt of the main repository"
echo
