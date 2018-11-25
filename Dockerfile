FROM jenkins/jenkins:latest

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
	&& apt-get install -y curl openssl sudo ca-certificates \
	&& echo "%sudo ALL=(ALL) NOPASSWD:$(whereis keytool | awk '{print $2}')" >> /etc/sudoers \
	&& echo "%sudo ALL=(ALL) NOPASSWD:$(whereis update-ca-certificates | awk '{print $2}')" >> /etc/sudoers \
	&& usermod -aG sudo ${user} \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -f /var/cache/apt/*.bin
	
# SSL Setup
ADD jenkins_cert.sh /usr/local/bin/jenkins_cert.sh
RUN chmod +x "/usr/local/bin/jenkins_cert.sh"
ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8443 --httpsCertificate="$CERT_FOLDER/jenkins.pem" --httpsPrivateKey="$CERT_FOLDER/jenkins.key"
EXPOSE 8443

USER ${user}
ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/jenkins_cert.sh"]
