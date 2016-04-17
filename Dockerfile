FROM jenkins:latest
USER root
# update
RUN apt-get update && apt-get upgrade -y
# generate ssl cert
RUN apt-get install -y openssl \
        && mkdir -p /var/lib/jenkins \
        && openssl genrsa -out "/var/lib/jenkins/jenkins.key" \
        && openssl req -new -key "/var/lib/jenkins/jenkins.key" -out "/var/lib/jenkins/jenkins.csr" -subj "/C=US/ST=Example/L=Example/O=Example Company Inc./CN=www.example.com" \
        && openssl x509 -req -days 3560 -in "/var/lib/jenkins/jenkins.csr" -signkey "/var/lib/jenkins/jenkins.key" -out "/var/lib/jenkins/jenkins.pem" \
        && rm "/var/lib/jenkins/jenkins.csr" \
        && chown jenkins /var/lib/jenkins/jenkins.pem /var/lib/jenkins/jenkins.key
ENV JENKINS_OPTS --httpPort=-1 --httpsPort=8443 --httpsCertificate=/var/lib/jenkins/jenkins.pem --httpsPrivateKey=/var/lib/jenkins/jenkins.key
EXPOSE 8443
# install maven
ENV MAVEN_VERSION 3.3.9
RUN curl -fsSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
        && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
        && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
ENV MAVEN_HOME=/usr/share/maven
USER jenkins
