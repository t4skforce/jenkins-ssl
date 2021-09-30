# jenkins-ssl
Docker Container - Jenkins HTTPS secured Web-UI, Oracle Java 8, Maven.
[GitHub repo](https://github.com/t4skforce/jenkins-ssl)

[![](https://img.shields.io/docker/automated/t4skforce/jenkins-ssl.svg)](https://cloud.docker.com/repository/docker/t4skforce/jenkins-ssl) [![docker-build-push](https://github.com/t4skforce/jenkins-ssl/actions/workflows/main.yml/badge.svg)](https://github.com/t4skforce/jenkins-ssl/actions/workflows/main.yml) [![](https://images.microbadger.com/badges/version/t4skforce/jenkins-ssl.svg)](http://microbadger.com/images/t4skforce/jenkins-ssl "Get your own version badge on microbadger.com") [![](https://img.shields.io/docker/pulls/t4skforce/jenkins-ssl.svg)](https://cloud.docker.com/repository/docker/t4skforce/jenkins-ssl) [![](https://img.shields.io/docker/stars/t4skforce/jenkins-ssl.svg)](https://cloud.docker.com/repository/docker/t4skforce/jenkins-ssl) [![](https://img.shields.io/github/last-commit/t4skforce/jenkins-ssl.svg)](https://github.com/t4skforce/jenkins-ssl) [![](https://img.shields.io/maintenance/yes/2021.svg)](https://github.com/t4skforce/jenkins-ssl) [![](https://img.shields.io/github/issues-raw/t4skforce/jenkins-ssl.svg)](https://github.com/t4skforce/jenkins-ssl/issues) [![](https://img.shields.io/github/issues-pr-raw/t4skforce/jenkins-ssl.svg)](https://github.com/t4skforce/jenkins-ssl/pulls)

# About the Container

This build is based on [jenkins/jenkins:latest](https://github.com/jenkinsci/docker) with added features:
* HTTPS Secured WEB-UI (4096bit - RSA)
* OpenJDK 8u72

# How to use this image
`docker run --name jenkins-master -p 443:8443 -p 50000:50000 t4skforce/jenkins-ssl:latest`
This will store the workspace in `/var/jenkins_home`. All Jenkins data lives in there - including plugins and configuration. You will probably want to make that a persistent volume (recommended):

`docker run --name jenkins-master -p 443:8443 -p 50000:50000 -v /your/home:/var/jenkins_home t4skforce/jenkins-ssl:latest`
This will store the jenkins data in `/your/home` on the host. Ensure that `/your/home` is accessible by the jenkins user in container (jenkins user - uid 1000) or use `-u some_other_user` parameter with `docker run`.

You can also use a volume container:

`docker run --name myjenkins -p 443:8443 -p 50000:50000 -v /var/jenkins_home  t4skforce/jenkins-ssl:latest`

Then jenkins-master container has the volume (please do read about docker volume handling to find out more).

# Opening Web-UI
[https://yourservernameorip/](https://127.0.0.1/)

# Upgrade
```bash
# download updates
docker pull t4skforce/jenkins-ssl:latest
# stop current running image
docker stop jenkins-master
# remove container
docker rm jenkins-master
# start with new base image
docker run --name jenkins-master -d -p 443:8443 -p 50000:50000 -v /your/home:/var/jenkins_home t4skforce/jenkins-ssl:latest
```

# Autostart
To enable Jankins to start at system-startup we need to create a systemd service file `vim /lib/systemd/system/jenkins.service`:

```ini
[Unit]
Description=Jenkins-Server
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a jenkins-master
ExecStop=/usr/bin/docker stop -t 2 jenkins-master

[Install]
WantedBy=multi-user.target
```

To start the service manually call `systemctl start jenkins`. For retreaving the current service status call `systemctl status jenkins`

```bash
root@jenkins:~# systemctl status jenkins
● jenkins.service - Jenkins-Server
   Loaded: loaded (/lib/systemd/system/jenkins.service; enabled)
   Active: active (running) since Sun 2016-04-17 11:42:57 BST; 2s ago
 Main PID: 2642 (docker)
   CGroup: /system.slice/jenkins.service
           └─2642 /usr/bin/docker start -a jenkins-master
```

And last but not least we need to enable our newly created service via issuing `systemctl enable jenkins`:
```bash
root@jenkins:~# systemctl enable jenkins
Created symlink from /etc/systemd/system/multi-user.target.wants/jenkins.service to /lib/systemd/system/jenkins.service.
```

# Auto Upgrade
Combine all the above and autoupgrade the container at defined times. This requires you to at least setup [Autostart](#autostart).

First we need to generate your upgrade shell script `vim /root/jenkins_upgrade.sh`:

```bash
#!/bin/bash

# Jenkins home directory on Server to save all the stuff
JENKINS_HOME="/your/home"

# download updates
docker pull t4skforce/jenkins-ssl:latest
# stop current running image
docker stop jenkins-master
# remove container
docker rm jenkins-master
# start with new base image
docker run --name jenkins-master -d -p 443:8443 -p 50000:50000 -v ${JENKINS_HOME}:/var/jenkins_home t4skforce/jenkins-ssl:latest t4skforce/jenkins-ssl:latest
# stop container
docker stop jenkins-master
# start via service
systemctl start jenkins
```

Next we need to make this file executable `chmod +x /root/jenkins_upgrade.sh`, and test if the upgrade script works by calling the shell-script and checking the service status afterwards:
```bash
root@jenkins:~# /root/jenkins_upgrade.sh
root@jenkins:~# systemctl status jenkins
● jenkins.service - Jenkins-Server
   Loaded: loaded (/lib/systemd/system/jenkins.service; enabled)
   Active: active (running) since Sun 2016-04-17 11:42:57 BST; 2s ago
 Main PID: 2642 (docker)
   CGroup: /system.slice/jenkins.service
           └─2642 /usr/bin/docker start -a jenkins-master
```

Now we need to set the trigger for the upgrade. In this example we just setup a weekly upgrade via crontab scheduled for Sunday at midnight. We add `0 0 * * 7 root /root/jenkins_upgrade.sh` to `/etc/crontab`. The resulting file looks like:

```bash
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.

SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# m h dom mon dow user  command
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
# Jenkins Docker Container Upgrade
0  0    * * 7   root    /root/jenkins_upgrade.sh
#
```

# Further Information

For further information on configuring the Image please refer to [jenkins/jenkins:latest](https://github.com/jenkinsci/docker)
