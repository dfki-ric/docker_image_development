#/!bin/bash

ROOT_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )


# TODO check success return values

echo ${ROOT_DIR}

# build initial devel
cd ${ROOT_DIR}/image_setup/02_devel_image
bash build.bash

cd ${ROOT_DIR}
# TODO setup_workspace.bash should be non-interactive
# TODO Use git credential.helper store (it is stored in home folder), delete before building release (add to dockerignore?)
./exec.bash devel /bin/bash -C "git config --global user.email bob@dfki.de"
./exec.bash devel /bin/bash -C "git config --global user.name \"Bob the Builder\""
./exec.bash devel /bin/bash -C "git config --global credential.helper store"
./exec.bash devel /bin/bash -C "echo https://${GIT_USER}:${GIT_ACCESS_TOKEN}@git.hb.dfki.de > ~/.git-credentials"


./exec.bash devel /opt/setup_workspace.bash
echo docker container inspect --format '{{.State.ExitCode}}'
# write osdeps to external file
./exec.bash devel /opt/write_osdeps.bash

# build a devel image with dependencies
cd ${ROOT_DIR}/image_setup/02_devel_image
bash build.bash

cd ${ROOT_DIR}
# TODO: check if startscripts/build script is available
./exec.bash devel build

cd ${ROOT_DIR}/image_setup/03_release_image
bash build.bash


