#!/usr/bin/env bash
# ==============================================================================
# Kich ban kiem thu tu dong he thong Blog-CMS (Commit 1 & Commit 2)
# Chay tren Linux / WSL / Git Bash
# ==============================================================================

set -o pipefail

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

run_test() {
    local category="$1"
    local test_name="$2"
    shift 2
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    printf "[TEST %02d] [%s] %s ... " "$TOTAL_TESTS" "$category" "$test_name"
    
    local output
    if output=$(eval "$@"); then
        PASSED_TESTS=$((PASSED_TESTS + 1))
        echo -e "\033[32mPASS\033[0m"
        [ -n "$output" ] && echo -e "         -> \033[90m$output\033[0m"
    else
        FAILED_TESTS=$((FAILED_TESTS + 1))
        echo -e "\033[31mFAIL\033[0m"
        [ -n "$output" ] && echo -e "         -> \033[31m$output\033[0m"
    fi
}

echo "======================================================================"
echo "   BAT DAU KIEM THU TU DONG HE THONG BLOG-CMS (COMMIT 1 & COMMIT 2)   "
echo "======================================================================"
echo ""

# ------------------------------------------------------------------------------
# NHOM 1: CONTAINER LIFECYCLE
# ------------------------------------------------------------------------------
run_test "Container" "Tat ca 8 containers deu dang chay" bash -c '
    expected=("cms_nginx" "cms_wordpress" "cms_mysql" "cms_phpmyadmin" "cms_cadvisor" "cms_mysql_exporter" "cms_prometheus" "cms_grafana")
    running=$(docker ps --format "{{.Names}}")
    for c in "${expected[@]}"; do
        if ! echo "$running" | grep -q "^$c$"; then
            echo "Thieu container: $c"
            exit 1
        fi
    done
    echo "8/8 containers dang hoat dong binh thuong"
'

run_test "Container" "MySQL dat trang thai Healthy" bash -c '
    status=$(docker inspect --format "{{.State.Health.Status}}" cms_mysql 2>/dev/null)
    if [ "$status" = "healthy" ]; then
        echo "MySQL Health: healthy"
    else
        echo "MySQL status: $status"
        exit 1
    fi
'

run_test "Container" "Restart policy la unless-stopped" bash -c '
    policies=$(docker inspect --format "{{.HostConfig.RestartPolicy.Name}}" cms_nginx cms_wordpress cms_mysql cms_prometheus cms_grafana)
    for p in $policies; do
        if [ "$p" != "unless-stopped" ]; then
            echo "Container chua dat unless-stopped"
            exit 1
        fi
    done
    echo "Tat ca containers deu co restart policy unless-stopped"
'

# ------------------------------------------------------------------------------
# NHOM 2: AN NINH & PHAN VUNG MANG
# ------------------------------------------------------------------------------
run_test "BaoMat" "[Test bien] CSDL cms_mysql khong publish port ra ngoai Host" bash -c '
    ports=$(docker port cms_mysql 2>/dev/null)
    if [ -z "$ports" ]; then
        echo "CHINH XAC: CSDL MySQL an hoan toan khoi mang ngoai"
    else
        echo "CANH BAO: CSDL dang mo port ra ngoai: $ports"
        exit 1
    fi
'

run_test "BaoMat" "Co lap mang Bridge (Nginx khong nam trong backend_net)" bash -c '
    nets=$(docker inspect --format "{{json .NetworkSettings.Networks}}" cms_nginx)
    if echo "$nets" | grep -q "backend_net"; then
        echo "LOI: Nginx bi gan vao backend_net"
        exit 1
    fi
    echo "Nginx chi ket noi frontend_net, dam bao an toan 2 lop"
'

run_test "BaoMat" "Chuyen huong tu dong HTTP (Port 80) sang HTTPS (Port 443) ma 301" bash -c '
    res=$(curl -s -o /dev/null -w "%{http_code} %{redirect_url}" http://localhost/)
    code=$(echo "$res" | awk "{print \$1}")
    url=$(echo "$res" | awk "{print \$2}")
    if [ "$code" = "301" ] && echo "$url" | grep -q "https://localhost/"; then
        echo "HTTP 80 tra ve ma 301 Redirect -> $url"
    else
        echo "Ket qua bat thuong: $res"
        exit 1
    fi
'

run_test "BaoMat" "Nginx HTTPS (Port 443) phuc vu WordPress thanh cong" bash -c '
    code=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/)
    if [ "$code" = "200" ] || [ "$code" = "302" ]; then
        echo "HTTPS hoat dong tot, ma HTTP tra ve: $code"
    else
        echo "Ma HTTP tra ve bat thuong: $code"
        exit 1
    fi
'

run_test "BaoMat" "Kiem tra 5 HTTP Security Headers tren Nginx" bash -c '
    headers=$(curl -k -s -I https://localhost/)
    missing=""
    for h in "X-Frame-Options" "X-Content-Type-Options" "X-XSS-Protection" "Referrer-Policy" "Strict-Transport-Security"; do
        if ! echo "$headers" | grep -qi "^$h:"; then
            missing="$missing $h"
        fi
    done
    if [ -z "$missing" ]; then
        echo "Day du 5 headers: X-Frame-Options, X-Content-Type-Options, XSS, HSTS, Referrer"
    else
        echo "Thieu headers:$missing"
        exit 1
    fi
'

run_test "BaoMat" "Truy cap phpMyAdmin qua Reverse Proxy (/pma/)" bash -c '
    code=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/pma/)
    if [ "$code" = "200" ]; then
        echo "phpMyAdmin dinh tuyen qua Nginx an toan (ma 200)"
    else
        echo "Ma HTTP tra ve: $code"
        exit 1
    fi
'

run_test "BaoMat" "[Test bien] Truy van URL khong ton tai tra ve loi 404 sach se" bash -c '
    code=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost/path-not-found-boundary-test-404)
    if [ "$code" = "404" ]; then
        echo "Xu ly loi bien 404 sach se, khong lo thong tin backend"
    else
        echo "Nhan ma loi khac 404: $code"
        exit 1
    fi
'

# ------------------------------------------------------------------------------
# NHOM 3: OBSERVABILITY & MONITORING
# ------------------------------------------------------------------------------
run_test "GiamSat" "Prometheus Server Healthcheck (/-/healthy)" bash -c '
    res=$(curl -s http://localhost:9090/-/healthy)
    if echo "$res" | grep -q "Prometheus Server is Healthy"; then
        echo "Prometheus Server hoat dong on dinh (Healthy)"
    else
        echo "Phan hoi bat thuong: $res"
        exit 1
    fi
'

run_test "GiamSat" "Prometheus Targets: Ca 3/3 targets deu dat UP" bash -c '
    json=$(curl -s http://localhost:9090/api/v1/targets)
    if echo "$json" | grep -q "\"job\":\"cadvisor\"" && \
       echo "$json" | grep -q "\"job\":\"mysql\"" && \
       echo "$json" | grep -q "\"job\":\"prometheus\"" && \
       ! echo "$json" | grep -q "\"health\":\"down\""; then
        echo "3/3 targets deu UP: cadvisor, mysql, prometheus"
    else
        echo "Co target chua dat trang thai UP"
        exit 1
    fi
'

run_test "GiamSat" "Prometheus Time Series DB (Query API PromQL \"up\")" bash -c '
    json=$(curl -s "http://localhost:9090/api/v1/query?query=up")
    count=$(echo "$json" | grep -o "\"value\":\[[0-9.]*,\"1\"\]" | wc -l)
    if [ "$count" -ge 3 ]; then
        echo "TSDB luu tru chi so on dinh, $count targets deu tra ve 1"
    else
        echo "Ket qua PromQL chua dat 100% UP: $count targets dat 1"
        exit 1
    fi
'

run_test "GiamSat" "Grafana Server Healthcheck (/api/health)" bash -c '
    res=$(curl -s http://localhost:3000/api/health)
    if echo "$res" | grep -q "\"database\":\"ok\""; then
        echo "Grafana hoat dong tot (database: ok)"
    else
        echo "Grafana database chua san sang"
        exit 1
    fi
'

run_test "GiamSat" "Grafana Auto-Provisioning: Nap Data Source Prometheus" bash -c '
    res=$(curl -s -u hoang:hoang http://localhost:3000/api/datasources)
    if echo "$res" | grep -q "\"type\":\"prometheus\"" && echo "$res" | grep -q "\"isDefault\":true"; then
        echo "Data Source Prometheus tu dong nap san sang (isDefault: True)"
    else
        echo "Chua tim thay default Prometheus Data Source trong Grafana"
        exit 1
    fi
'

echo ""
echo "======================================================================"
echo "                       TONG KET KET QUA TEST                          "
echo "======================================================================"
echo " Tong so ca kiem thu : $TOTAL_TESTS"
echo -e " So ca pass          : \033[32m$PASSED_TESTS\033[0m"
if [ "$FAILED_TESTS" -gt 0 ]; then
    echo -e " So ca fail          : \033[31m$FAILED_TESTS\033[0m"
else
    echo -e " So ca fail          : \033[32m0\033[0m"
    echo ""
    echo -e "\033[32mKet qua: Tat ca cac test case deu PASSED.\033[0m"
fi
echo "======================================================================"
