#!/bin/bash

# In this file you can add a script that intitializes your workspace

# stop on errors
set -e

BUILDCONF=
BRANCH=

if [ ! $1 = "" ]; then
   echo "overriding git credential helper to $1"
   CREDENTIAL_HELPER_MODE=$1
fi

# for Continuous Deployment builds the mode needs to be overridden to be non-interactive
# if set outside this script, use that value, if unset use cache
CREDENTIAL_HELPER_MODE=${CREDENTIAL_HELPER_MODE:="cache"}

# In this file you can add a script that intitializes your workspace

if [ ! -d /opt/workspace/env.sh ]; then
   echo -e "\e[32m[INFO] First start: setting up the commonGUI workspace.\e[0m"

   # init workspace dir
   mkdir -p /opt/workspace
   cd /opt/workspace

   # set git config
   git config --global user.name "Image Builder"
   git config --global user.email "image@builder.me"
   git config --global credential.helper ${CREDENTIAL_HELPER_MODE}

   # setup ws using autoproj
   wget rock-robotics.org/autoproj_bootstrap
   ruby autoproj_bootstrap git $BUILDCONF branch=$BRANCH --seed-config=/opt/config_seed.yml --no-color --no-interactive
   source env.sh
   aup --no-color --no-interactive
   amake

   echo -e "\e[32m[INFO] workspace successfully initialized.\e[0m"
else 
   echo -e "\e[31m[ERROR] workspace already initialized.\e[0m"
   exit 1
fi
