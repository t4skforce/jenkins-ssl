FROM jenkins:latest

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
	&& apt-get install -y curl openssl \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -f /var/cache/apt/*.bin
	
# SSL Setup
ADD jenkins_cert.sh /usr/local/bin/jenkins_cert.sh
RUN chmod +x "/usr/local/bin/jenkins_cert.sh" \
	&& chown ${uid}:${gid} /etc/ssl/certs/java/cacerts
ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8443 --httpsCertificate="$CERT_FOLDER/jenkins.pem" --httpsPrivateKey="$CERT_FOLDER/jenkins.key"
EXPOSE 8443

USER ${user}
ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
