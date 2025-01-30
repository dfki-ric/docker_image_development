#!/bin/bash
source /opt/workspace/env.sh || true

FILELIST=$1
TARGET_FOLDER=$2


#delet old file
> dependencies.txt

collect_linked_libs() {
    echo "adding deps of $1"
    ldd $1 | sed '/not found/d' | awk '{print $3}' | sed '/^[[:space:]]*$/d' >> dependencies.txt
}
export -f collect_linked_libs

echo "collecting dependencies for $PROGRAM in $TARGET_FOLDER"

cd /opt/workspace
source env.sh


# collect_linked_libs of all file list items
cat $FILELIST | xargs -I {} /bin/bash -c "collect_linked_libs {}"

#remove duplicate lines
awk '!seen[$0]++' dependencies.txt > tmp.txt && mv tmp.txt dependencies.txt


sudo apt install rsync

# echo $DEPS
mkdir -p $TARGET_FOLDER
rsync -aLv --files-from=$FILELIST / $TARGET_FOLDER
rsync -aLv --files-from=dependencies.txt / $TARGET_FOLDER

echo "creating tar.gz file"
cd $TARGET_FOLDER
tar cvf ../dependencies.tar *

rm -rf $TARGET_FOLDER
rm -rf dependencies.txt
