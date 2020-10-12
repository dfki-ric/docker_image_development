#!/bin/bash

DRY_RUN=true
WORKDIR=$(pwd)
COUNT=0
git --version > /dev/null || exit 1

##########################################################################################################
echo -e "\e[1mATTENTION:\e[0m This script may change your git configuration of ALL recursive directories!"
echo "           Use the --exec flag for changes to take effect!"
echo -e "           Hit Ctrl+C to abort!\n"
sleep 8

if [ "$1" == "--exec" ]; then
    echo -e "           Okay, you mean it. Let's go..\n"
    DRY_RUN=false
fi

##########################################################################################################
IFS=$'\n'
# find all .git directories and see if they use https alread
for dir in $(find . -iname ".git"); do
    cd $(dirname $dir) && echo -n "Checking: "$(basename $(pwd))
    git remote -v | grep -v https > /dev/null 2>&1
    if [ $? != "0" ]; then
        echo -e " => \e[32malready https\e[0m"
        cd $WORKDIR
    else
        echo -e " => \e[33mupdating $(git remote -v | grep -v https | wc -l) remote URL\e[0m"
        # loop through remotes of current dir, double check for https and set-url for fetch and push
        for remote in $(git remote -v); do
            echo $remote | grep https > /dev/null && continue
            REMOTE=$(echo $remote | awk '{print $1}')
            METHOD=$(echo $remote | awk '{print $3}')
            CURRENT_URL=$(echo $remote | awk '{print $2}')
            NEW_URL=$(echo $CURRENT_URL | sed 's|:||g;s|git@|https://|g')
            echo -e "  \e[4m$REMOTE $METHOD\e[0m:\n    $CURRENT_URL\n    => $NEW_URL"
            if [ !$DRY_RUN ]; then
                if [ $(echo $METHOD | sed 's/[()]//g') == "push" ]; then
                    git remote set-url --push $REMOTE $NEW_URL
                else
                    git remote set-url $REMOTE $NEW_URL
                fi
            fi
            (( COUNT++ ))
        done
        cd $WORKDIR
    fi
done

echo "Updated $COUNT remote URLS!"
unset IFS
