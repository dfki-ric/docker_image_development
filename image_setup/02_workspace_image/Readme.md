# Build workspace image

_WARNING: Before you can set up the workspace image, the base image has to be pushed._

Workspace images contain pre-installed libraries of specific projects (not shared as commonly as the ones installed in the base_images)

You need to adapt the Dockerfile to the needs of your project:

* If the image is already in your registry, this step can be omitted

The following steps are explained in detail in the next sections.

* Add workspace dependencies of your project to the image (add the install to the Dockerfile)
* Add workspace initialization scripts/howto


## Workspace Dependencies

* You should try to pre-install all workspace dependencies using this Dockerfile.
* The list_*_osdeps scripts help to determine which workspace-specific packages are required
* Add these dependencies to be installed by the Dockerfile

## Workspace Initialization

When the devel container is started for the first time, the /opt/init_workspace.sh script is executed.
You can use it to initialize the workspace, but it is executed each time a new image is available.

The best way is to add a /opt/setup_workspace.sh script to the image, and add a usage instruction to the /opt/init_workspace.sh script.

```
RUN echo 'echo -e "\n\e[32mplease run /opt/setup_workspace.sh to initialize the workspace\e[0m\n"' >> /opt/init_workspace.sh
```


## Suggested Workflow

<table border="0">
 <tr>
    <td>0.</td>
    <td>edit image names, tags & registry</td>
    <td> => </td>
    <td> edit ../../settings.bash </td>
 </tr>
 <tr>
    <td>1.</td>
    <td>describe the steps to setup your workspace<br></br> (e.g. using buildconf)</td>
    <td> => </td>
    <td> edit setup_workspace.bash </td>
 </tr>
 <tr>
    <td>2.</td>
    <td>build image</td>
    <td> => </td>
    <td> bash build.sh </td>
 </tr>
  <tr>
    <td>3.</td>
    <td>start container</td>
    <td> => </td>
    <td> bash ./exec_in_devel /bin/bash </td>
 </tr>
 <tr>
    <td>4.</td>
    <td>setup workspace</td>
    <td> => </td>
    <td> either manually or using bash /opt/setup_workspace.bash</td>
 </tr>
 <tr>
    <td>5.</td>
    <td>list osdeps</td>
    <td> => </td>
    <td> ROS:<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - add list_ros_osdeps.rb to your mounted workspace<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - source setup.bash and execute ruby list_ros_osdeps.rb<br></br>
         ROCK:<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - add list_rock_osdeps.* to your mounted workspace<br></br>
         &nbsp;&nbsp;&nbsp;&nbsp; - source yuor env.sh and execute bash add list_rock_osdeps.bash<br></br>
         </td>
 </tr>
 <tr>
    <td>6.</td>
    <td>add osdeps to Dockerfile</td>
    <td> => </td>
    <td>copy/paste output from previous step into your Dockerfile</td>
 </tr>
 <tr>
    <td>7.</td>
    <td>rebuild your image to include osdeps</td>
    <td> => </td>
    <td> bash build.sh </td>
 </tr>
</table>

