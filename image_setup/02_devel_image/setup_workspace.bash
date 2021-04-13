#!/bin/bash

# In this file you can add a script that intitializes your workspace

# stop on errors
set -e

# In this file you can add a script that intitializes your workspace

# ROCK BUILDCONF EXAMPLE
#
if [ ! -d /opt/workspace/autoproj ]; then
   echo -e "\e[32m[INFO] First start: setting up the commonGUI workspace.\e[0m"

   # init workspace dir
   mkdir -p /opt/workspace
   cd /opt/workspace

   # set git config
   git config --global user.name "Image Builder"
   git config --global user.email "image@builder.me"
   git config --global credential.helper cache

   # setup ws using autoproj
   wget rock-robotics.org/autoproj_bootstrap
   ruby autoproj_bootstrap git https://git.hb.dfki.de/ndlcom/buildconf branch=master
   source env.sh
   aup
   amake

   echo -e "\e[32m[INFO] workspace successfully initialized.\e[0m"
else 
   echo -e "\e[31m[ERROR] workspace already initialized.\e[0m"
   exit 1
fi
