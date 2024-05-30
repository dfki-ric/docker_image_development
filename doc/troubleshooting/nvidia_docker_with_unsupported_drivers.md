
# Nvidia Docker with unsupported drivers

When nvidia-container-cli is installed, but the driver is incomatible (e.g. because of discontinued support for the graphics card).

```
Error response from daemon: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error running hook #0: error running hook: exit status 1, stdout: , stderr: Auto-detected mode as 'legacy'
nvidia-container-cli: detection error: nvml error: function not found: unknown
```

In this case, you cannot use the hardware 3D acceleration.

When you uninstall nvidia-container-runtime, even using the purge option, there might be leftovers, resultin in another error:

```fork/exec /usr/bin/nvidia-container-runtime: no such file or directory```

In this case you'll need to:
* Edit the `/etc/systemd/system/docker.service.d/override.conf` and remove the letover `--add-runtime=nvidia=/usr/bin/nvidia-container-runtime` part.
* Make sure the `has_gpu_support` value in .container_config.txt is bigger than zero, not '=0' (this is the saved return value when trying to enable gpu support for docker, so '=1' or '=125' works).
* Restart the docker daemon: `sudo systemctl restart docker`
* Delete the old container and create a new one: `./delete_container.bash`, `./exec.bash`
