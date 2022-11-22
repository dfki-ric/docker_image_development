ARG DEVEL_IMAGE_NAME

FROM ${DEVEL_IMAGE_NAME}

ARG USER
ARG HOST
ARG DATE

LABEL description="This image contains a release of ${DEVEL_IMAGE_NAME}"
LABEL build_info="Build by ${USER} on ${HOST}. Date: ${DATE}"


#do not run the user id setting for mounted folders
RUN sudo touch /initialized_container

#tell the base image entrypoint that the code was already installed
#wel let the container init the uid so that the user can kill processes in the
#container on the host
RUN sudo touch /initialized_workspace

# the default /opt/workspace is owned by root, change it
# /opt/startscripts and /home/dockeruser are not affected
# as they are not already existing
RUN sudo chown dockeruser:dockeruser-group /opt/workspace

#copy all the mounts from folders from dev image
#the build context is "..", so paths in this folder must have this folder name as prefix
#e.g. build_release/entrypoint.sh must be prefixed for files, workspace can be local
COPY --chown=dockeruser:dockeruser-group workspace /opt/workspace/
COPY --chown=dockeruser:dockeruser-group startscripts /opt/startscripts/
COPY --chown=dockeruser:dockeruser-group home /home/dockeruser/

#keep the entrypoint from the base image, we are using the startscripts folder to run stuff
