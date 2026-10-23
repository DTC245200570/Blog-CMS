#!/bin/bash
# Script tao chung chi SSL tu ky (Self-signed Certificate) tren Linux/macOS
mkdir -p nginx/ssl

# SAN giup trinh duyet xac thuc duoc hostname localhost va IP loopback
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt \
  -subj "/C=VN/ST=Hanoi/L=Hanoi/O=BlogCMS/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
