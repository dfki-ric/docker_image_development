ARG DEVEL_IMAGE_NAME

FROM ${DEVEL_IMAGE_NAME}

ARG USER
ARG HOST
ARG DATE

LABEL description="This image contains a release of ${DEVEL_IMAGE_NAME}"
LABEL build_info="Build by ${USER} on ${HOST}. Date: ${DATE}"


#do not run the user id setting for mounted folders
RUN sudo touch /initialized_uid

#tell the base image entrypoint that the code was already installed
#wel let the container init the uid so that the user can kill processes in the
#container on the host
RUN sudo touch /initialized_workspace

# create release user 
RUN groupadd release-group
RUN useradd --shell /bin/bash -c "release user" -m -G release-group release

# set user sudoers previlege for start script (w/o password), the /opt/init_user_id.bash script
# is using NUID and NGID environment variables, but ist executed by the user using sudo, so these vars have to be kept
RUN echo "release ALL=(ALL) NOPASSWD: ALL \
    \nDefaults        env_keep += \"NUID\" \
    \nDefaults        env_keep += \"NGID\"" >> /etc/sudoers

# the default /opt/workspace is owned by root, change it
# /opt/startscripts and /home/devel are not affected
# as they are not already existing
RUN sudo chown release:release-group /opt/workspace

#copy all the mounts from folders from dev image
#the build context is "..", so paths in this folder must have this folder name as prefix
#e.g. build_release/entrypoint.sh must be prefixed for files, workspace can be local
COPY --chown=release:release-group workspace /opt/workspace/
COPY --chown=release:release-group startscripts /opt/startscripts/
COPY --chown=release:release-group home /home/devel/
RUN ln -s /home/release/ /home/devel
RUN chown release:release-group /home/devel

#from now on, call RUN as devel user
USER release

#keep the entrypoint from the base image, we are using the startscripts folder to run stuff
