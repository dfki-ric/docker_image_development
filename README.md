# CommonGUI to Go

This is a collection of scripts that facilitate working with docker images and containers. This repo is adapted to quickly retrieve and use a running commonGUI.

**Attention** Changes inside the container do not persist and are gone as soon as a new container is created. If you want any updates to persist, use the devel images with locally mounted directories to develop and generate a new release image from your changes. Please refer to the [usage documentation](doc/020_Usage.md) for further infos.

## Preperation:

##### 1. install docker
Please install Docker according to the [010_Setup_Docker.md](doc/010_Setup_Docker.md) or by executing the [install_docker.bash](tools/install_docker.bash) script.

##### 2. login to registry
The docker development is based on different docker image setup steps. For this repo a release image with an installed commonGUI is available on the internal docker registry. Please login with your DFKI credentials as follows (requires VPN connection):

```bash
    docker login d-reg.hb.dfki.de
```

In order to check for available images you can browse the DFKI [internal registry](https://d-reg.hb.dfki.de/repositories) (Login required).

## Get GUI

```bash
    # create working directory
    mkdir -p ~/docker/commonGUI && cd ~/docker/commonGUI
    # clone repo
    git clone https://git.hb.dfki.de/ndlcom/docker_image-commongui.git .
    # generate container and start commonGUI with CommonConfig
    ./commonGUI.bash
```

##### HINTS:

* For starting with another xml config execute: `./commonGUI.bash <Config>` (xml suffix may be omitted)

* To see, which configs are available execute: `./commonGUI.bash --help`

* In order to enable tab completion: `source autocomplete.me`

* Execute `./stop.bash` in order to stop the container

* Execute `./delete_container.bash` to delete the current container

* If you want to get into the container to look at the workspace and change things manually execute: `./exec.bash`. Keep in mind that changes in the container will vanish as soon as a new container is generated. Refer to the [usage documentation](doc/020_Usage.md) for detailed infos.

* In order to use this repo for development, you can change the DEFAULT_EXECMODE in the settings.bash to devel. Afterwards your container will be created based on the devel image and won't have the workspace included. However the workspace will conveniently be mounted from your host system, which facilitates development on your host system, while at the same time making your workspace independent of the container. Thus regenerating your container won't have an impact on changes in your workspace. In order to setup the workspace on your host, you can easily execute `bash /opt/setup_workspace.bash` from within your container or execute the `extract_directories_from_release_image.bash` script from this repos tools directory to extract the workspace from your currently used release image.

## Documentation

The Documentation is available in the doc folder of this repository.

## Current State

This software is stable and maintained by the authors.

## Bug Reports

To search for bugs or report them, please use the issue tracker at:

https://git.hb.dfki.de/ndlcom/docker_image-commongui/-/issues

Also see the [base image Readme](image_setup/01_base_images/Readme.md).

## Referencing

Please reference the github page: http://github.com/dfki-ric/docker_image_development

## Releases

We use semantic versioning: See [VERSION](VERSION) file

### Semantic Versioning

Semantic versioning is used.

(The major version number will be incremented when the API changes in a backwards incompatible way, the minor
version will be incremented when new functionality is added in a backwards compatible manner, and the patch version is incremented for bugfixes, documentation, etc.)

## License

See [LICENSE](LICENSE) file.

## Maintainer / Authors / Contributers

Maintainer: Steffen Planthaber, Leon Danter

Authors:

* Steffen Planthaber
* Leon Danter

Contributors:

* Elmar Berghöfer
* Fabian Maas
* Tom Creutz
* Raul Dominguez
* Bojan Kocev
* Christian Koch
* Leif Christensen

Copyright 2020, DFKI GmbH / Robotics Innovation Center, University of Bremen / Robotics Research Group
