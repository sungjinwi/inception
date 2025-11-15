#!/bin/sh

set -e

# Generate ssl certificate and key
echo "Generating self-signed SSL certificate..."

mkdir -p /etc/nginx/ssl

# CN means CommonName -> certificate Domain name
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/server.key \
    -out /etc/nginx/ssl/server.crt \
    -subj "/C=KR/ST=Gyeongbuk/L=Gyeongsan/O=42Gyeongsan/CN=localhost"

echo "SSL certificate created."
