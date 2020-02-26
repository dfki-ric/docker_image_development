


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

IMAGE_BASENAME=d-reg.hb.dfki.de/mare-it/uuv-sim_18.04
export IMAGE_NAME=$IMAGE_BASENAME:devel


echo "$USER on $HOST Date: $DATE"
docker build --no-cache --build-arg IMAGE_NAME --build-arg USER --build-arg HOST --build-arg DATE -f Dockerfile -t $IMAGE_BASENAME:release ..

echo "tagging $IMAGE_BASENAME:release as $IMAGE_BASENAME:release_$TAG"
docker tag $IMAGE_BASENAME:release $IMAGE_BASENAME:release_$TAG

echo
echo "don't forget to push the image if you wish:"
echo "docker push $IMAGE_BASENAME:release"
echo "docker push $IMAGE_BASENAME:release_$TAG"


