# Script PowerShell tạo chứng chỉ SSL tự ký cho Windows
$sslDir = Join-Path $PSScriptRoot ""
if (-not (Test-Path $sslDir)) {
    New-Item -ItemType Directory -Path $sslDir -Force | Out-Null
}

$keyPath = Join-Path $sslDir "server.key"
$crtPath = Join-Path $sslDir "server.crt"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
  -keyout $keyPath `
  -out $crtPath `
  -subj "/C=VN/ST=Hanoi/L=Hanoi/O=Security/CN=localhost"

Write-Host "Đã tạo thành công chứng chỉ SSL tự ký tại: $sslDir" -ForegroundColor Green
