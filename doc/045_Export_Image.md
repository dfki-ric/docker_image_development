## Export Release Archive

If you want to deploy images somewhere you don't have access to the docker registry, you can export the image to a .tar.gz file containing the image and the relevant workspace files.

__WARNING: If the release image contains sensitive data (e.g., source code, private keys etc.) everyone who is provided access to the exported image will also gain access to these files. If you don't want this, you re-create the release image in a way such that it doesn't contain this data (c.f., the suggestions given [here](doc/043_Release_Image.md)).__

To specify files and directories that shall be excluded from the exported release image, you can use the .dockerignore file located in the root of this repo (requires rebuild of the release image!). For syntax and usage refer to the respective [subsection](https://docs.docker.com/engine/reference/builder/#dockerignore-file) of the docker documentation and be sure to check your release image before distributing it.


Steps:

* Expand the `Readme_scripts.md` with further usage instructions (e.g. outline of available startscripts and their usage).
* Run the `build.bash` script. It creates two .tar.gz files: One containing the image and the other containing the scripts and the readme file.

Then you can distribute the archive files, extract them at the remote location, setup the Docker environment there, and finally run the scripts from the image. 


## Run From an Exported Release Archive

The export creates two archive files (.tar.gz). One contains the image, and one contains scripts required to make proper use of the image.

There should be a readme file in the scripts archive file, containing the required usage instructions.

The basic workflow is in principle:
* Distribute the archive files,
* extract the one containing the script on the host where they shall be deployed,
* setup the Docker environment there,
* load the release image from the archive with: `docker load < docker_image_archive.tar.gz`
* then run the scripts from the image as explained in the workspace-specific instructions.
