# Docker Image Development 

This is a collection of scripts that enables a development process using docker images.

**Requisite:** Please install Docker according to the [README_Docker.md](README_Docker.md)!

The docker development is based on different docker image setup steps, some of which can be omitted when a local registry is set up and the required image is already available.

In order to check for available images you can browse the DFKI [internal registry](https://d-reg.hb.dfki.de/repositories) (Login required).

# Running

* Clone this repository
* Login to the docker registry containing the images (if not on dockerhub and registry available)
  * See [README_Docker.md](README_Docker.md)

## For the lazy

0. Install docker, login to registry to pull existing image (see above)

1. Clone repo

2. Execute `./commonGUI.bash` to start CommonGUI with CommonConfig

3. Done.

HINTS:

* For starting with another xml config execute: ./commonGUI.bash CommonGUI <Config>

* To see, which configs are available execute: ./commonGUI.bash CommonGUI

* In order to get tab completion for commonGUI.bash source autocomplete.me

## In general

In order to initialize, run or attach to containers you will be using the `./exec.bash` script.
You can use either base, devel or release as argument in order to determine which image you want to base your container on.
Per default the exec.bash script will drop into a /bin/bash shell with the default mode set in the settings.bash if no other arguments are given.

The goal is to prepare docker _images_ that encapsulate a component's or a project's dependencies so that work is being done in a consistent, reproducible environment, i.e., to prevent that code not only builds or runs on the developer's machine and fails elsewhere.
In order to achieve this, the **devel image** is created to contain all dependencies for the workspace preinstalled. The devel image mounts local directories into the container so they can be modified by editors on the host machine, while they are compiled and run in the container.

Devel images are usually based on **base images**, that encapsulate dependencies shared by many projects.
The build process will automatically try to pull required images from a docker registry.
If the image is already available locally, it doesn't need to be pulled again.

Another goal of this approach is to be able to preserve a working version of a component, a project or a demo and possibly ship it to external partners.
In order to achieve this, the **release image** can be created, which contains the devel image plus the additional workspace files and run scripts required to operate the product.

## When a release image is available:

* call `$> ./exec.bash release STARTSCRIPT`
  * STARTSCRIPT here is a script from the image, with a high probability of also being in the startscritps folder of this repo
  * The image will be pulled automatically
* Optional: call `$> source autocomplete.me` to have code completion after ./exec.bash
  * This will use the completion with the scripts in this repo, new scripts might nor be available inside the image
    * Possibly reset this repo to the date of the release image to improve this situation

## When no release image is available:

## Getting Started

Please read the [usage howto](doc/020_Usage.md)

## Requirements / Dependencies

You need docker installed and usable for your user.
If 3D accelleration is needed, nvidia-docker can be utilized.

Please read the [docker howto](doc/010_Setup_Docker.md)

## Installation

Just fork/clone this repository.

A fork can be used to store your settings and share them with the developers of your project.

## Documentation

The Documentation is available in the doc folder of this repository.

## Current State

This software is stable and maintained by the authors.

## Bug Reports

To search for bugs or report them, please use GitHubs issue tracker at:

http://github.com/dfki-ric/docker_image_development

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

Maintainer: Steffen Planthaber

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
