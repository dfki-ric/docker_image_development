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

# DNS 

Docker uses the DNS settigns of the host at container creation, if your system is not switching networks, DNS works just fine.

In case the host is swiching Networks and the DNS server changes, name resolution may fail in your container after switching (e.g. connecting to a new WIFI of en/disabling VPN Connections).

In this case, and if your host uses the "systemd-resolvd" (ubutnu > 18.04) you can set up dnsmasq to provide DNS name resolution on your host for your containers.

## Install dnsmasq

* sudo apt install dnsmasq
* add the following content in the /etc/dnsmasq.d/docker.conf file
  ```
  interface=docker0
  bind-dynamic
  listen-address=172.17.0.1
  cache-size=0
  no-dhcp-interface=docker0
  ```
  * setting the cache size is important, as dnsmasq should only forward to systemd-resolvd
    * otherwise you'll have to restart dnsmasq after switching networks
* delete /etc/dnsmasq.d/ubuntu-fan as it sets bind-interfaces which is incompatible with bind-dynamic
* restart dnsmasq
  * sudo systemctl restart dnsmasq
* start dnsmasq on boot
  * sudo systemctl enable dnsmasq


## provide dns setting to docker

As this DNS though dnsmasq and systemd-resolvd ist host-specific, you shouldn't add it to the settings.bash of this repo at all.

* edit/create /etc/docker/daemon.json
* add the DNS setting for your host
  * ```
    {
        "dns": ["172.17.0.1"]
    }
    ```
  * if there are other entries, make them "," seperated
* restart docker
  * sudo systemctl restart docker

**For these changes to take effect, you have to re-create your containers** (just call the delete_container.bash script)


# Sophos Antivirus

When the host uses Sophos Antivirus, you may have a bad performance while compiling in the container.

This is described in the [Sophos Support Site](https://support.sophos.com/support/s/article/KB-000039332?language=en_US),
which suggests to use "Fanotify" for on access scanning, which is unable to scan inside docker containers and thus solves the performance issues.

To set the descibed Fanotify option, you can use these commands [described here](https://community.sophos.com/on-premise-endpoint/f/sophos-anti-virus-for-linux-basic/121795/docker-builds-are-five-times-slower-when-the-antivirus-is-running):

```bash
sudo /opt/sophos-av/bin/savconfig set disableTalpa true
sudo /opt/sophos-av/bin/savconfig set disableFanotify false
sudo /opt/sophos-av/bin/savconfig set preferFanotify true
```


Alternatively you can consider to disable the AV daemons temporarily:

```bash
sudo systemctl stop sav-protect
sudo systemctl stop sav-rms
```

Afterwards you can restart again:

```bash
sudo systemctl start sav-protect
sudo systemctl start sav-rms
```

