#!/bin/bash
# Script tao chung chi SSL tu ky (Self-signed Certificate) tren Linux/macOS
mkdir -p nginx/ssl

# Tao khoa RSA 2048-bit va chung chi co thoi han 365 ngay
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt \
  -subj "/C=VN/ST=Hanoi/L=Hanoi/O=HoangLight/CN=localhost"
