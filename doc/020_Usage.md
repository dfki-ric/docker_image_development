# Docker Development 

## Preparation

Please install Docker according to the [docker readme](010_Setup_Docker.md).

## General Usage

### Run or Attach to the Docker Container

In order to initialize, run or attach to containers you will be using the `./exec.bash` script.
You can use either `base`, `devel` or `release` as argument in order to determine which image shall be instantiated in your container (or leave out the argument and use the default mode specified in `settings.bash`):

    $ ./exec.bash <mode>

Normally the exec.bash script will drop into a /bin/bash shell with the default mode set in the settings.bash if no other arguments are given.
Each subsequent call to `./exec.bash` is opening a new console attached to the same running container.

If the requested image is not yet available locally, it will be pulled from the docker registry. Docker hub is the default registry. For certain images or other registries you might need to login at this point (`docker login <registry>`).


### Run Commands or Start Scripts in the Docker Container

You can directly run commands in the Docker container. Especially for release this is useful as you only need to run one command on the host computer to execute an application inside the container.

Example:

    $ ./exec.bash <command>

`command` can be any (shell) command found on the client's PATH.
Here, you can also optionally specify the execmode to specify whether you want to run the command with the base, devel or release image.
You can (and probably should) define start scripts to execute one or many applications from the image's workspace.
All scripts from the startscripts folder are automatically added to the PATH in the container.

You can activate some autocomplete hints on the host machine by sourcing `$ source autocomplete.me`.
This adds all scripts of the startscripts folder to the auto completion feature using TAB after `./exec.bash`.
However, if the image was created with a different version of this cloned repository, the startscripts that are available in the container might differ.
In this case autocompletion might not work correctly. A possible workaround is to reset this repo or at least the startscripts directory, to the date when the release image was created.


### Container Management

When you exit (detach from) the container shell, the container keeps running in the background. You can inspect which containers are running at the time via `docker ps` and stop containers via `stop.bash [base|devel|release|CD]`. In order to regenerate a fresh container from an image, you can delete the old one by executing `delete_container.bash <execmode>`. The next call to `./exec.bash` will generate and start a new container.

IMPORTANT: In order to apply new settings (like 3d acceleration), the container and saved settings have to be reset: `delete_container.bash <execmode>`

### Container Configuration (docker compose)

`./exec.bash` creates the container via docker compose. The container is defined by the `workspace` service in `docker-compose.exec.bash.yml`, which uses variables set by `./exec.bash` (image name, container name, user id, ...). Depending on the exec mode and the options in `settings.bash` (x server, gpu, ccache, ssh agent, icecc, docker in container), the files in `.docker_scripts/compose/` are added.

Project specific run parameters (open ports, additional mounts, host network, privileged mode, ...) can be set as docker run arguments in `ADDITIONAL_DOCKER_RUN_ARGS` of `settings.bash`, they are translated to docker compose (e.g. `--net=host` becomes `network_mode: host`) and added to the configuration.
Arguments that cannot be translated are reported by `./exec.bash`, these can be added to the `workspace` service in `docker-compose.exec.bash.yml` directly:

```yaml
services:
  workspace:
    ...
    network_mode: host
    dns_search: mydomain
    ports:
      - "7890:7890"
    volumes:
      - /path/on/host:/path/in/container
```

Additional services (e.g. a database) can also be added to `docker-compose.exec.bash.yml`, they are started, stopped and deleted together with the container.

`./exec.bash` detects changes of the configuration and offers to renew the container. To print the complete configuration, run `VERBOSE=true ./exec.bash`.

#### Standalone Compose File

`./tools/generate_standalone_compose.bash [execmode]` generates `docker-compose.yml`, which contains the complete configuration of the exec mode with all variables resolved. It can be used to run the container without the scripts of this repository (e.g. a release image on a target system), see the comments in the generated file for usage.

`./exec.bash` keeps this file up to date: if it does not exist, it is generated for the `DEFAULT_EXECMODE`, and it is regenerated (for the exec mode it was generated for) when `settings.bash`, `docker-compose.exec.bash.yml` or the scripts change. Manual changes to the generated file will be lost, a `docker-compose.yml` that was not generated by the script is not touched.

The generated file uses the same compose project and container name as `./exec.bash`, so `docker compose ps`, `logs`, `exec`, `stop`, `start` etc. in this folder work on the container of `./exec.bash`.
CAUTION: `docker compose up` recreates an existing container if its configuration differs (e.g. another `DISPLAY`, or it was created with `VERBOSE=true`), changes inside the container are lost. Use `docker compose start` for an existing container.

### Advanced

For more advanced topics, see the [advanced topics readme](030_Advanced_Topics.md).

# Image setup

In case you don't have a registry or your registry does not contain the image, you can build those yourself: 

## Base Images

Base images contain the basic dependencies for several projects.

If you need to create them, please look at the [base image readme](041_Base_Image.md).

## Devel Images

Devel images should contain project specific dependencies.

If you are a developer using docker_development, please have a look at the [devel image readme](042_Devel_Image.md).

## Frozen Images

Frozen images are ready to run images including the whole workspace (a frozen workspace).

If you are a developer using docker_development, please have a look at the [frozen image readme](043_Frozen_Image.md).


## Release Images

Release images are minimized and ready to run, also with docker compose etc.

Please have a look at the [release image readme](044_Release_Image.md).

## Exported Images

Release Images can be exported as .tar.gz file and a run sripts .tar.gz file which can be imported an run on another PC.

See [export image readme](45_Export_Image.md).

