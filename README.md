# Docker Image Development 

This is a collection of scripts that enables a development process using docker images.

It was initiated and is currently developed at the
[Robotics Innovation Center](http://robotik.dfki-bremen.de/en/startpage.html) of the
[German Research Center for Artificial Intelligence (DFKI)](http://www.dfki.de) in Bremen,
together with the [Robotics Group](http://www.informatik.uni-bremen.de/robotik/index_en.php)
of the [University of Bremen](http://www.uni-bremen.de/en.html).

## Motivation

In robot development using several robots, there are sometimes different OS systems and software version used.
In oder to be able to develop for robots running on different OS version (e.g. Ubuntu 16.04 and 18.04) docker is a very useful tool, but not really intended to be used for development.

Also, there is a need in research projects to provide partners with runnable software, using this approach, runnable images can be created and sent to the partners without the need for them to install and set up other dependencies than docker.


These scripts are helping to set up a docker-based development and release workflow.

The goal is to prepare docker _images_ that encapsulate a component's or a project's dependencies so that work is being done in a consistent, reproducible environment, i.e., to prevent that code not only builds or runs on the developer's machine and fails elsewhere.
In order to achieve this, the **devel image** is created to contain all dependencies for the workspace preinstalled. The devel image mounts local directories into the container so they can be modified by editors on the host machine, while they are compiled and run in the container.

Devel images are usually based on **base images**, that encapsulate dependencies shared by many projects.
The build process will automatically try to pull required images from a docker registry.
If the image is already available locally, it doesn't need to be pulled again.

Another goal of this approach is to be able to preserve a working version of a component, a project or a demo and possibly ship it to external partners.
In order to achieve this, the **release image** can be created, which contains the devel image plus the additional workspace files and run scripts required to operate the product.

![process overview](/doc/docker_development_image.png?raw=true "process overview")



## Getting Started

Please read the [usage howto](doc/020_Usage.md)

When you have issues while running the container, please have a look into the [troubleshooting guide](doc/040_Troubleshooting.md) or create a issue in the [original location of the repo](https://github.com/dfki-ric/docker_image_development)

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
