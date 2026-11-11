#!/bin/sh
set -e

if [ ! -f /etc/nginx/ssl/localhost.crt ] || [ ! -f /etc/nginx/ssl/localhost.key ]; then
    mkdir -p /etc/nginx/ssl
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/localhost.key \
        -out /etc/nginx/ssl/localhost.crt \
        -subj "/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
    echo "==> Certyfikat SSL wygenerowany pomyslnie."
fi

exec nginx -g "daemon off;"
