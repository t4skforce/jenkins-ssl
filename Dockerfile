FROM jenkins/jenkins:latest

ARG BUILD_DATE="2023-03-10T01:28:04Z"
ENV JENKINS_HOME /var/jenkins_home
ENV CERT_FOLDER "$JENKINS_HOME/.ssl"
ENV ROOT_CA ""
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000

USER root
# update
RUN apt-get update && apt-get upgrade -y \
	&& apt-get install -y curl openssl ca-certificates ca-certificates-java \
	&& update-ca-certificates \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -f /var/cache/apt/*.bin

# SSL Setup
ADD jenkins_cert.sh /usr/local/bin/jenkins_cert.sh
ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8443 --httpsCertificate="$CERT_FOLDER/jenkins.pem" --httpsPrivateKey="$CERT_FOLDER/jenkins.key"
EXPOSE 8443

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins_cert.sh"]
