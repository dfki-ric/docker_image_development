#!/bin/bash


# list all images that are dangling
(echo -e "\n\e[1m\e[33mWARNING: The following images would be deleted:\n\n\e[0m" && docker images -f dangling=true ) | less -r -X


# prompt for deletion
read -p "    => Do you want to delete all listed images? (Y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
    for hash in $(docker images -f dangling=true -q); do docker rmi -f $hash; done
else
    echo 
    echo "As you wish, I won't do anything."
    exit 1
fi
