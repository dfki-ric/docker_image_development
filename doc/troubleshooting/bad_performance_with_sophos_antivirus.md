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