
if [ $# -lt 1  ] || [ $# -gt 1  ] ;then
     echo "Incorrect usage. Use: docker-run.sh <param1>"
     echo "<param1>: Give the name of the container you are about to reuse"
     exit 1
fi

docker exec -ti $1 /bin/bash