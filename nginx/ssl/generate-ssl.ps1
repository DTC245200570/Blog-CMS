# Script tao chung chi SSL tu ky (Self-signed Certificate) tren Windows
$sslDir = Join-Path $PSScriptRoot ""
if (-not (Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir -Force | Out-Null
}

$keyPath = Join-Path $sslDir "server.key"
$crtPath = Join-Path $sslDir "server.crt"

# SAN giup trinh duyet xac thuc duoc hostname localhost va IP loopback
openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
  -keyout $keyPath `
  -out $crtPath `
  -subj "/C=VN/ST=Hanoi/L=Hanoi/O=BlogCMS/CN=localhost" `
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"
