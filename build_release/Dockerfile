From d-reg.hb.dfki.de/mare-it/uuv-sim_18.04:latest

ARG USER
ARG HOST
ARG DATE

LABEL description="This image contains the vrlab client display"
LABEL build_info "Build by ${USER} on ${HOST}. Date: ${DATE}"


#tell the base image entrypoint that the code was already installed
#wel let the container init the uid so that the user can kill processes in the
#container on the host
RUN touch /initialized_workspace




#copy all the mounts from folders from dev image
#the build context is "..", so paths in this folder must habe this folder name as prefix
#e.g. build_release/entrypoint.sh must be prefixed for files, workspace can be local
COPY --chown=devel:devel workspace /opt/workspace
COPY --chown=devel:devel startscripts /opt/startscripts
COPY --chown=devel:devel home /home/devel


#from now on, call RUN as devel user
USER devel

#install potentially missing osdeps
#RUN . ./env.sh && autoproj osdeps



#keep the entrypoint from the base image, we are using the startscripts folder to run stuff
