#!/bin/bash

# adds a string parameter to a variable if that part is not already there
# usage ARGS=$(add_param_if_not_present "${ARGS}" -blubb)
add_param_if_not_present() {
    if [[ "$1" == *" $2 "* ]]; then
        #prarameter part is already there
        echo "$1"
    else
        echo "$1 $2"
    fi
}