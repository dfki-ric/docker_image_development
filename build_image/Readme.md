# Build workspace image

The worspace image contains additional dependencies of your specific project.
If the image is in the registry, this step can be omitted

## Workspace Dependencies
You should try to pre-install all workspace dependencies in this steps Dockerfile.
The list_*_osdeps scripts help to determine which workspace-specific packages are required
Add these to the Dockerfile


## Workspace init

When the devel container is started for the first time, the /opt/init_workspace.sh script is executed.
You can use it to inittialize the workspace, but it is executed each time a new image is available.

The best way is to add a /opt/setup_workspace.sh script to the image, and add a useage instruction to the /opt/init_workspace.sh script.

```
RUN echo 'echo -e "\e[32mplease run /opt/setup_workspace.sh to initialize the workspace\e[0m"' >> /opt/init_workspace.sh
```


