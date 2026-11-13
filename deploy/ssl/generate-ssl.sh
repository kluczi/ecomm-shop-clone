#!/usr/bin/env bash
SSL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$SSL_DIR"

echo "Generowanie certyfikatu SSL dla localhost..."
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$SSL_DIR/localhost.key" \
    -out "$SSL_DIR/localhost.crt" \
    -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

echo "Certyfikat zapisany w: $SSL_DIR/localhost.crt oraz $SSL_DIR/localhost.key"
