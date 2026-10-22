#!/bin/bash
# Script tự động tạo chứng chỉ SSL tự ký cho môi trường Dev/Local
mkdir -p nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt \
  -subj "/C=VN/ST=Hanoi/L=Hanoi/O=Security/CN=localhost"
echo "Da tao xong chung chi SSL tai nginx/ssl/"
