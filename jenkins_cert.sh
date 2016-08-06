#!/bin/bash
set -e
if [ ! -f "$CERT_FOLDER/jenkins.pem" ] || [ ! -f "$CERT_FOLDER/jenkins.key" ]; then
		mkdir -p "$CERT_FOLDER" \
        && openssl genrsa -out "$CERT_FOLDER/jenkins.key" 4096 \
        && openssl req -new -key "$CERT_FOLDER/jenkins.key" -out "$CERT_FOLDER/jenkins.csr" -subj "/C=US/ST=Example/L=Example/O=Example Company Inc./CN=www.example.com" \
        && openssl x509 -req -days 3560 -in "$CERT_FOLDER/jenkins.csr" -signkey "$CERT_FOLDER/jenkins.key" -out "$CERT_FOLDER/jenkins.pem" \
        && rm "$CERT_FOLDER/jenkins.csr" 
fi
/usr/local/bin/jenkins.sh