#!/bin/bash
set -e

sudo apt install curl
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce

sudo adduser $(id -un) docker
su - ${USER}
sudo systemctl restart docker

echo
echo "[INFO] If you want to use a registry to push/pull images or if you'd like to enable gpu support, refer to doc/010_Setup_Docker.md"
