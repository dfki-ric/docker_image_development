


# if [ $# -lt 2  ] || [ $# -gt 2  ] ;then
#      echo "Incorrect usage. Use: docker-run.sh <param1> <param2>"
#      echo "<param1>: git username"
#      echo "<param2>: git access token or password"
#      exit 1
# fi

#the build context must be .. to access workspace and home folders

DATE=$(date)
TAG=$(date +%Y_%m_%d-%H_%M)
HOST=$(hostname)

IMAGE_BASENAME=d-reg.hb.dfki.de/mare-it/uuv-sim_18.04_release

echo "$USER on $HOST Date: $DATE"
docker build --no-cache --build-arg USER --build-arg HOST --build-arg DATE -f Dockerfile -t $IMAGE_BASENAME:latest ..

echo "tagging $IMAGE_BASENAME:latest as $IMAGE_BASENAME:$TAG"
docker tag d-reg.hb.dfki.de/vrlab/docker_release:latest $IMAGE_BASENAME:$TAG
