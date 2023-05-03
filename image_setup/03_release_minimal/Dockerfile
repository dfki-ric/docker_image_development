#ARG RELEASE_IMAGE_NAME
ARG DISTRO_IMAGE
#ARG DEPENDENCIES_FOLDER
ARG EXECUTABLE
ARG EXECUTABLE_PARAMS=""

FROM ${DISTRO_IMAGE}

# add alone will overwrite subfolders which would delete libs already in the image
# so er unpack first and then move each file on its own
ADD dependencies.tar /opt/dependencies
#create target folders and move file one by one
RUN cd /opt/dependencies && \
    find -type f -exec dirname {} \; | xargs printf -- '/%s ' | xargs mkdir -v -p && \
    find -type f -exec mv {} /{} \;

ENV LD_LIBRARY_PATH=/opt/workspace/install/lib/

# add custom files here


# TIP: you can also mount e.g. config files using -v
# docker run --rm -ti -v $(pwd)/ps3_local.yml:/config.yml d-reg.hb.dfki.de/developmentimage/rrc_gamepad_client_20.04:release /bin/bash
#ENV DEBIAN_FRONTEND=noninteractive
#RUN apt-get update && apt-get install -y libqt5webengine5
#RUN apt-get update && apt-get install -y libxcb-xinerama0 libqt5widgets5 libqt5webengine5


ADD entrypoint.bash /opt/entrypoint.bash
#these scripts must be runnable by users, not only root
RUN chmod 755 /opt/entrypoint.bash
ENTRYPOINT ["/opt/entrypoint.bash"]


# add default command
#use ENV VAR to forward to cmd
# ENV EXECUTABLE_ENVVAR="${EXECUTABLE}"
# ENV EXECUTABLE_PARAMS_ENVVAR="${EXECUTABLE_PARAMS}"
#CMD [./rrc_gamepad_client config.yml]
#needs bach for variable 
CMD ["run"]
