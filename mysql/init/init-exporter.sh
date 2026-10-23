#!/bin/bash
set -euo pipefail

# Kiem tra bien bat buoc truoc khi khoi tao
if [ -z "${MYSQL_EXPORTER_PASSWORD:-}" ]; then
    echo "[init-exporter] LOI: MYSQL_EXPORTER_PASSWORD chua duoc khai bao. Dung khoi tao tai khoan exporter." >&2
    exit 1
fi

case "$MYSQL_EXPORTER_PASSWORD" in
    *\'*|*\\*)
        echo "[init-exporter] LOI: MYSQL_EXPORTER_PASSWORD khong duoc chua ky tu nhay don (') hoac dau gach cheo (\\)." >&2
        exit 1
        ;;
esac

EXPORTER_USER="${MYSQL_EXPORTER_USER:-exporter}"
case "$EXPORTER_USER" in
    *[!a-zA-Z0-9_]*|"")
        echo "[init-exporter] LOI: MYSQL_EXPORTER_USER chua ky tu khong hop le hoac bi bo trong." >&2
        exit 1
        ;;
esac

mysql -u root -p"${MYSQL_ROOT_PASSWORD}" <<-EOSQL
    CREATE USER IF NOT EXISTS '${EXPORTER_USER}'@'%' IDENTIFIED BY '${MYSQL_EXPORTER_PASSWORD}' WITH MAX_USER_CONNECTIONS 3;
    GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO '${EXPORTER_USER}'@'%';
    FLUSH PRIVILEGES;
EOSQL

echo "[init-exporter] Khoi tao thanh cong tai khoan ${EXPORTER_USER} voi quyen doc chi so toi thieu."
