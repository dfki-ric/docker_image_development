#!/bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )
source $ROOT_DIR/settings.bash

check_config_file_exists(){
    #init config file, if nonexistent
    if [ ! -f $ROOT_DIR/.container_config.txt ]; then
        echo "# do not edit, this file is generated and updated automatically when running exec.bash" >> $ROOT_DIR/.container_config.txt
    fi
}

write_value_to_config_file(){
    #check if file exists and create if nonexistent
    check_config_file_exists
    # to be able to write, the value must already exits in the file
    # find old var line
    OLDLINE=$(cat $ROOT_DIR/.container_config.txt | grep "^$1=")
    NEWLINE="$1=$2"
    if [ "$OLDLINE" = "" ]; then 
        # new value, just append
        echo "$NEWLINE" >> $ROOT_DIR/.container_config.txt
    else
        #value exists, replace line
        sed -i "s/^$OLDLINE/$NEWLINE/g" "$ROOT_DIR/.container_config.txt"
    fi
}

read_value_from_config_file(){
    #check if file exists and create if nonexistent
    check_config_file_exists
    READVARNAME=$1
    echo $(cat $ROOT_DIR/.container_config.txt | grep "^$READVARNAME=" | awk -F'=' '{print $2}')
}

print_stored_image_tags(){
    $PRINT_WARNING "available image tags:"
    for tag in $(tail -n +2 $ROOT_DIR/.stored_images.txt | grep = | cut -d '=' -f 1); do $PRINT_WARNING "    - $tag"; done
}
