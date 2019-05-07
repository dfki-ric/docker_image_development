
echo "updating docker image"
docker pull d-reg.hb.dfki.de/mare-it/uuv-sim_18.04:latest

echo "\n\nThis script is deprecated, use $>./exec_in_devel.sh /bin/bash instead\n"

echo "calling it now:"

./exec_in_devel.sh /bin/bash

