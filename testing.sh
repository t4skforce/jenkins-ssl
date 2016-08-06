#!/bin/sh

docker kill jenkins_ssl
docker rm jenkins_ssl
docker rmi jenkins_ssl
docker build -t jenkins_ssl . && \
docker run --name jenkins_ssl -d -p 8443:8443 --restart=always jenkins_ssl && \
docker logs -f jenkins_ssl