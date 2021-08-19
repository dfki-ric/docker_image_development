
#/!bin/bash

. ../../settings.bash

CD_IMAGE_NAME=${RELEASE_REGISTRY:+${RELEASE_REGISTRY}/}$WORKSPACE_CD_IMAGE
docker push $CD_IMAGE_NAME
