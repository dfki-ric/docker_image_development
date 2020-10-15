## Preparation

You need to install Docker and (optional) Nvidia hardware graphics acceleration for Docker. See separate Readme_Docker.md file.

## Load Image Into Docker

Load the provided Docker image, to enable containers to run the functionality this package provides:

    docker load < <provided image.tar.gz file>

## Run Provided Commands in Docker Container

Unpack the provided scripts archive.

Run commands:

 * `./exec.bash` : Attach a new shell (bash) to the container
 * `./exec.bash hello_world` : An example entry for a custom start script
 * TODO: provide project-specific documentation for users of the package

You can activate autocompletion hints for `./exec.bash` scripts arguments by running

    $ source autocomplete.me
    $ ./exec.bash [double-tap tab key]


