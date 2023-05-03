#!/bin/bash
source /opt/workspace/env.sh || true

PROGRAM=$1
TARGET_FOLDER=$2
ADDITIONAL_FILES_FILE=$3

echo "collecting dependencies for $PROGRAM in $TARGET_FOLDER"

cd /opt/workspace
source env.sh

ldd $PROGRAM | sed '/not found/d' | awk '{print $3}' | sed '/^[[:space:]]*$/d' > dependencies.txt

#cat dependencies.txt | awk -v folder=$TARGET_FOLDER '{printf "COPY ./%s%s %s\n",folder,$1,$1}' > filelist.txt

sudo apt install rsync

# echo $DEPS
mkdir -p $TARGET_FOLDER
rsync -aLv --files-from=dependencies.txt / $TARGET_FOLDER
rsync -aLv --files-from=$ADDITIONAL_FILES_FILE / $TARGET_FOLDER
cp $PROGRAM $TARGET_FOLDER

echo "creating tar.gz file"
cd $TARGET_FOLDER
tar cvf ../dependencies.tar *

rm -rf $TARGET_FOLDER
rm -rf dependencies.txt
