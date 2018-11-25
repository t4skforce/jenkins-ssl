#!/bin/bash
set -e
# generate ca if it doesn't exist
if [ ! -f "$CERT_FOLDER/jenkins.pem" ] || [ ! -f "$CERT_FOLDER/jenkins.key" ]; then
	mkdir -p "$CERT_FOLDER" \
        && openssl genrsa -out "$CERT_FOLDER/jenkins.key" 4096 \
        && openssl req -new -key "$CERT_FOLDER/jenkins.key" -out "$CERT_FOLDER/jenkins.csr" -subj "/C=US/ST=Example/L=Example/O=Example Company Inc./CN=www.example.com" \
        && openssl x509 -req -days 3560 -in "$CERT_FOLDER/jenkins.csr" -signkey "$CERT_FOLDER/jenkins.key" -out "$CERT_FOLDER/jenkins.pem" \
        && rm "$CERT_FOLDER/jenkins.csr" 
fi
# install custom root ca if configured
if [ ! -z "$ROOT_CA" ]
	if [ -f "${ROOT_CA}" ]; then
		if ! keytool -list -keystore /etc/ssl/certs/java/cacerts -storepass changeit -noprompt -alias localrootca | grep 'localrootca' > /dev/null; then
			keytool -keystore /etc/ssl/certs/java/cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias localrootca -file ${ROOT_CA}
			echo "CA '${ROOT_CA}' installed successfully."
		else
			echo "CA '${ROOT_CA}' is already installed"
		fi
	else
		echo "file '${ROOT_CA}' does not exist!"
	fi
fi
/usr/local/bin/jenkins.sh
