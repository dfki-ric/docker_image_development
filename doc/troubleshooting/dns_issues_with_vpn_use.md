
# DNS 

Docker uses the DNS settigns of the host at container creation, if your system is not switching networks, DNS works just fine.

In case the host is swiching Networks and the DNS server changes, name resolution may fail in your container after switching (e.g. connecting to a new WIFI of en/disabling VPN Connections).


## Using systemd-resolvd (recommendend)

In most recent versions of systemd-resolvd you can specify 'DNSStubListenerExtra=172.17.0.1' in /etc/systemd/resolved.conf to start a local server and restart the service `sudo systemctl restart systemd-resolved`

Proceed with "provide dns setting to docker"

## Using dnsmasq
In cases where "systemd-resolvd" does not have the option, you can set up dnsmasq to provide DNS name resolution on your host for your containers.

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

Proceed with "provide dns setting to docker"

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
