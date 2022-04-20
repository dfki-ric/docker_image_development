# helper tool to delete tags from a docker registy
# Need to run garbage collection afterwards in oder to free disk space https://docs.docker.com/registry/garbage-collection/
# $> docker exec registry bin/registry garbage-collect --dry-run /etc/docker/registry/config.yml

#https://stackoverflow.com/questions/25436742/how-to-delete-images-from-a-private-docker-registry
if [ $# -ne 4 ]; then
 echo "illegal number of parameters"
 echo use: RegistryUsername registryURL imagename tag
 exit 1
fi

USER=$1
REGISTRY=$2
NAME=$3
TAG=$4
read -rsp 'registry password:' PASSWD 

echo

# get digest value:
DIGEST=$(curl -v --silent -u ${USER}:${PASSWD} -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' -X GET https://${REGISTRY}/v2/${NAME}/manifests/${TAG} 2>&1 | grep docker-content-digest | awk '{print ($3)}')

echo deleting $DIGEST

#actually delete
curl -v -u ${USER}:${PASSWD} -H 'Accept: application/vnd.docker.distribution.manifest.v2+json' -X DELETE https://${REGISTRY}/v2/${NAME}/manifests/${DIGEST/$'\r'/}

