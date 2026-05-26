FROM ubuntu:22.04

# add alone will overwrite subfolders which would delete libs already in the image
# so er unpack first and then move each file on its own
ADD dependencies.tar /opt/dependencies
#create target folders and move file one by one
RUN cd /opt/dependencies && \
    find -type f -exec dirname {} \; | xargs printf -- '/%s ' | xargs mkdir -v -p && \
    find -type f -exec mv {} /{} \;

# you can set env vars here
#ENV LD_LIBRARY_PATH=/opt/workspace/install/lib/

# add custom files here
# TIP: you can also mount e.g. config files using -v
# docker run --rm -ti -v $(pwd)/ps3_local.yml:/config.yml d-reg.hb.dfki.de/developmentimage/rrc_gamepad_client_20.04:release /bin/bash
#ENV DEBIAN_FRONTEND=noninteractive
# needed to run qt5 applications
#RUN apt-get update && apt-get install -y libxcb-xinerama0 libqt5widgets5 libqt5webengine5 
#RUN apt-get update && apt-get install -y libqt5webengine5


#these scripts must be runnable by users, not only root
ADD --chmod=755 entrypoint.bash /opt/entrypoint.bash
ENTRYPOINT ["/opt/entrypoint.bash"]

# add default command (content of "run" set in entrypoint.bash)
CMD ["run"]
