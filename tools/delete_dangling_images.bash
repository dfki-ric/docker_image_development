#!/bin/bash

# list all images that are dangling
(echo -e "\n\e[1m\e[33mWARNING: The following images would be deleted:\n\n\e[0m" && docker images -f dangling=true ) | less -r -X

# prompt for confirmation & delete
docker image prune
