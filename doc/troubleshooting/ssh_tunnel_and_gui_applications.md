
# ssh -X tunnel and mounted X server

When you have a server accessed by ssh and run GUI Applications you may encounter some issues.

When using `export DOCKER_XSERVER_TYPE=mount` AND the initial container was created via ssh -X AND --net=host was used, the tunnel initially works, but only as long as the initial ssh connection stays open, after it is closed, no further applications are visible.

There are two solutions: Using "Xpra" or "Handle DISPLAY variables and xserver permissions".

## Xpra

[Xpra is an open-source multi-platform persistent remote display server and client](https://xpra.org/)

When using xpra, you'll need to expose the xpra port you set in the settigns of use --net=host.

To use xpra permanently `export DOCKER_XSERVER_TYPE=xpra` can be set, but this will also be the case in local copies of the workspace, where mounting the xserver is more comforable than remembering to start the xpra client. 

In this case `export DOCKER_XSERVER_TYPE=auto` can be set in the settings.bash, this will auto-detect if you are logged in via ssh and use "xpra", but "mount" otherwise.

## Handle DISPLAY variables and xserver permissions

Normally the DISPLAY variable is static on a local system. But with an X tunnel, each ssh connection receives its own DISPLAY number, which is automatically set for the shell, but not for the docker container you can enter via ./exec.bash. This normally has the DISPLAY number of the shell that initially created the container (first call to ./exec.bash).

To make xtunnel via ssh work with a mounted xserver, use this two settings together:

`export DOCKER_XSERVER_TYPE=mount`

AND

`export USE_XSERVER_VIA_SSH=true`

Normally, docker only allows setting environment variables when creating a container, this option will make the exec script run an extra shell on exec, which has the correct DISPLAY environment variable set.

This DISPLAY env var, includes the hostname "localhost", which is the docker host, in order for the container to reach the host via "localhost" the --net=host flag is added to the run args.

Also the USE_XSERVER_VIA_SSH option enables copying the ~/.Xauthority file to the containers home/dockeruser directory on each call of `./exec.bash` in order to ensure the container has the correct credentials available to write to the hosts xserver. 



