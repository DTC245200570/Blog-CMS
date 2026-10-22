# Script kiem thu he thong Blog-CMS (Commit 1 & Commit 2)
$ErrorActionPreference = "Continue"

$totalTests = 0
$passedTests = 0
$failedTests = 0

function Run-Test {
    param (
        [string]$Category,
        [string]$TestName,
        [scriptblock]$TestBlock
    )
    $script:totalTests++
    Write-Host ("[TEST {0:D2}] [{1}] {2} ... " -f $script:totalTests, $Category, $TestName) -NoNewline
    try {
        $result = & $TestBlock
        if ($result.Passed) {
            $script:passedTests++
            Write-Host "PASS" -ForegroundColor Green
            if ($result.Message) {
                Write-Host ("         -> {0}" -f $result.Message) -ForegroundColor DarkGray
            }
        } else {
            $script:failedTests++
            Write-Host "FAIL" -ForegroundColor Red
            Write-Host ("         -> LOI: {0}" -f $result.Message) -ForegroundColor Red
        }
    } catch {
        $script:failedTests++
        Write-Host "FAIL (Exception)" -ForegroundColor Red
        Write-Host ("         -> Exception: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "   BAT DAU KIEM THU TU DONG HE THONG BLOG-CMS (COMMIT 1 & COMMIT 2)   " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

# ------------------------------------------------------------------------------
# NHOM 1: KIEM THU TRANG THAI CONTAINER & TAI NGUYEN
# ------------------------------------------------------------------------------

Run-Test -Category "Container" -TestName "Tat ca 8 containers deu dang chay (Up/Running)" -TestBlock {
    $expected = @("cms_nginx", "cms_wordpress", "cms_mysql", "cms_phpmyadmin", "cms_cadvisor", "cms_mysql_exporter", "cms_prometheus", "cms_grafana")
    $running = (docker ps --format "{{.Names}}") -split "`r?`n"
    $missing = $expected | Where-Object { $_ -notin $running }
    if ($missing.Count -eq 0) {
        return @{ Passed = $true; Message = "8/8 containers deu dang hoat dong binh thuong" }
    } else {
        return @{ Passed = $false; Message = ("Thieu container: {0}" -f ($missing -join ", ")) }
    }
}

Run-Test -Category "Container" -TestName "MySQL dat trang thai Healthy qua Healthcheck" -TestBlock {
    $health = docker inspect --format "{{.State.Health.Status}}" cms_mysql 2>$null
    if ($health -eq "healthy") {
        return @{ Passed = $true; Message = "MySQL container Health status: healthy" }
    } else {
        return @{ Passed = $false; Message = "MySQL container status hien tai: $health" }
    }
}

Run-Test -Category "Container" -TestName "Chinh sach tu phuc hoi (Restart Policy = unless-stopped)" -TestBlock {
    $policies = docker inspect --format "{{.HostConfig.RestartPolicy.Name}}" cms_nginx cms_wordpress cms_mysql cms_prometheus cms_grafana
    $invalid = $policies | Where-Object { $_ -notmatch "unless-stopped" }
    if ($invalid.Count -eq 0) {
        return @{ Passed = $true; Message = "Tat ca core containers deu co restart policy unless-stopped" }
    } else {
        return @{ Passed = $false; Message = "Co container chua dat unless-stopped" }
    }
}

# ------------------------------------------------------------------------------
# NHOM 2: KIEM THU AN NINH & PHAN VUNG MANG (COMMIT 1 - BOUNDARY TESTS)
# ------------------------------------------------------------------------------

Run-Test -Category "BaoMat" -TestName "[Test bien] CSDL cms_mysql khong publish port ra ngoai Host" -TestBlock {
    $ports = docker port cms_mysql 2>$null
    $portJson = docker inspect --format "{{json .NetworkSettings.Ports}}" cms_mysql
    if ([string]::IsNullOrWhiteSpace($ports) -and $portJson -match '"3306/tcp":null') {
        return @{ Passed = $true; Message = "CHINH XAC: CSDL MySQL duoc an hoan toan (khong co port forwarding ra Host)" }
    } else {
        return @{ Passed = $false; Message = ("CANH BAO: cms_mysql dang mo port ra ngoai: {0}" -f $ports) }
    }
}

Run-Test -Category "BaoMat" -TestName "Co lap mang Bridge (Nginx khong nam trong backend_net)" -TestBlock {
    $nginxNets = docker inspect --format "{{json .NetworkSettings.Networks}}" cms_nginx
    if ($nginxNets -match "backend_net") {
        return @{ Passed = $false; Message = "LOI: Nginx bi gan truc tiep vao backend_net" }
    } else {
        return @{ Passed = $true; Message = "Nginx chi ket noi frontend_net, dam bao mo hinh 2 lop an toan" }
    }
}

Run-Test -Category "BaoMat" -TestName "Chuyen huong tu dong HTTP (Port 80) sang HTTPS (Port 443) ma 301" -TestBlock {
    try {
        $req = [System.Net.HttpWebRequest]::Create("http://localhost/")
        $req.AllowAutoRedirect = $false
        $req.Timeout = 5000
        $res = $req.GetResponse()
        $statusCode = [int]$res.StatusCode
        $location = $res.Headers["Location"]
        $res.Close()
    } catch [System.Net.WebException] {
        $res = $_.Exception.Response
        if ($res) {
            $statusCode = [int]$res.StatusCode
            $location = $res.Headers["Location"]
            $res.Close()
        } else {
            return @{ Passed = $false; Message = $_.Exception.Message }
        }
    }
    if ($statusCode -eq 301 -and $location -match "https://localhost/") {
        return @{ Passed = $true; Message = ("HTTP 80 tra ve ma 301 Redirect -> {0}" -f $location) }
    } else {
        return @{ Passed = $false; Message = ("Ma tra ve: {0}, Location: {1}" -f $statusCode, $location) }
    }
}

Run-Test -Category "BaoMat" -TestName "Nginx HTTPS (Port 443) phuc vu WordPress thanh cong" -TestBlock {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    try {
        $req = [System.Net.HttpWebRequest]::Create("https://localhost/")
        $req.Timeout = 5000
        $res = $req.GetResponse()
        $statusCode = [int]$res.StatusCode
        $res.Close()
        if ($statusCode -eq 200 -or $statusCode -eq 302) {
            return @{ Passed = $true; Message = ("HTTPS hoat dong tot, ma HTTP tra ve: {0}" -f $statusCode) }
        } else {
            return @{ Passed = $false; Message = ("Ma HTTP tra ve bat thuong: {0}" -f $statusCode) }
        }
    } catch {
        return @{ Passed = $false; Message = $_.Exception.Message }
    }
}

Run-Test -Category "BaoMat" -TestName "Kiem tra 5 HTTP Security Headers thiet lap tren Nginx" -TestBlock {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    $req = [System.Net.HttpWebRequest]::Create("https://localhost/")
    $req.Timeout = 5000
    $res = $req.GetResponse()
    
    $headers = @(
        "X-Frame-Options",
        "X-Content-Type-Options",
        "X-XSS-Protection",
        "Referrer-Policy",
        "Strict-Transport-Security"
    )
    $missingHeaders = @()
    foreach ($h in $headers) {
        if (-not $res.Headers[$h]) {
            $missingHeaders += $h
        }
    }
    $res.Close()
    if ($missingHeaders.Count -eq 0) {
        return @{ Passed = $true; Message = "Day du 5 headers: X-Frame-Options, X-Content-Type-Options, XSS, HSTS, Referrer" }
    } else {
        return @{ Passed = $false; Message = ("Thieu headers: {0}" -f ($missingHeaders -join ", ")) }
    }
}

Run-Test -Category "BaoMat" -TestName "Truy cap phpMyAdmin qua Reverse Proxy Path (/pma/)" -TestBlock {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    try {
        $req = [System.Net.HttpWebRequest]::Create("https://localhost/pma/")
        $req.Timeout = 5000
        $res = $req.GetResponse()
        $statusCode = [int]$res.StatusCode
        $res.Close()
        if ($statusCode -eq 200) {
            return @{ Passed = $true; Message = "phpMyAdmin dinh tuyen qua Nginx an toan (ma 200)" }
        } else {
            return @{ Passed = $false; Message = ("Ma tra ve: {0}" -f $statusCode) }
        }
    } catch {
        return @{ Passed = $false; Message = $_.Exception.Message }
    }
}

Run-Test -Category "BaoMat" -TestName "[Test bien] Truy van URL khong ton tai tra ve loi 404 sach se" -TestBlock {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
    try {
        $req = [System.Net.HttpWebRequest]::Create("https://localhost/path-not-found-boundary-test-404")
        $req.Timeout = 5000
        $res = $req.GetResponse()
        $statusCode = [int]$res.StatusCode
        $res.Close()
        return @{ Passed = $false; Message = ("Mong doi ma 404 nhung nhan duoc: {0}" -f $statusCode) }
    } catch [System.Net.WebException] {
        $res = $_.Exception.Response
        if ($res) {
            $statusCode = [int]$res.StatusCode
            $res.Close()
            if ($statusCode -eq 404) {
                return @{ Passed = $true; Message = "Xu ly loi bien 404 sach se, khong lo thong tin backend" }
            } else {
                return @{ Passed = $false; Message = ("Nhan ma loi khac 404: {0}" -f $statusCode) }
            }
        }
        return @{ Passed = $false; Message = $_.Exception.Message }
    }
}

# ------------------------------------------------------------------------------
# NHOM 3: KIEM THU GIAM SAT OBSERVABILITY (COMMIT 2)
# ------------------------------------------------------------------------------

Run-Test -Category "GiamSat" -TestName "Prometheus Server Healthcheck (/-/healthy)" -TestBlock {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:9090/-/healthy" -TimeoutSec 5
        if ($response -match "Prometheus Server is Healthy") {
            return @{ Passed = $true; Message = "Prometheus Server hoat dong on dinh (Healthy)" }
        } else {
            return @{ Passed = $false; Message = ("Noi dung tra ve: {0}" -f $response) }
        }
    } catch {
        return @{ Passed = $false; Message = $_.Exception.Message }
    }
}

Run-Test -Category "GiamSat" -TestName "Prometheus Targets: Ca 3/3 targets deu dat trang thai UP" -TestBlock {
    try {
        $json = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/targets" -TimeoutSec 5
        $targets = $json.data.activeTargets
        $upTargets = $targets | Where-Object { $_.health -eq "up" }
        $downTargets = $targets | Where-Object { $_.health -ne "up" }
        
        if ($downTargets.Count -eq 0 -and $upTargets.Count -ge 3) {
            $jobs = ($upTargets | ForEach-Object { ("{0} (UP)" -f $_.labels.job) }) -join ', '
            return @{ Passed = $true; Message = ("3/3 targets deu UP: {0}" -f $jobs) }
        } else {
            $downDetails = ($downTargets | ForEach-Object { ("{0}: {1}" -f $_.labels.job, $_.lastError) }) -join '; '
            return @{ Passed = $false; Message = ("Co target DOWN: {0}" -f $downDetails) }
        }
    } catch {
        return @{ Passed = $false; Message = $_.Exception.Message }
    }
}

Run-Test -Category "GiamSat" -TestName "Prometheus Time Series DB (Query API PromQL 'up')" -TestBlock {
    try {
        $queryResult = Invoke-RestMethod -Uri "http://localhost:9090/api/v1/query?query=up" -TimeoutSec 5
        $metrics = $queryResult.data.result
        $allUp = $true
        foreach ($m in $metrics) {
            $val = $m.value[1]
            if ($val -ne "1") { $allUp = $false }
        }
        if ($metrics.Count -ge 3 -and $allUp) {
            return @{ Passed = $true; Message = ("TSDB luu tru chi so on dinh, ca {0} targets deu tra ve 1" -f $metrics.Count) }
        } else {
            return @{ Passed = $false; Message = "Ket qua PromQL chua dat 100% UP" }
        }
    } catch {
        return @{ Passed = $false; Message = $_.Exception.Message }
    }
}

Run-Test -Category "GiamSat" -TestName "Grafana Server Healthcheck (/api/health)" -TestBlock {
    try {
        $grafanaHealth = Invoke-RestMethod -Uri "http://localhost:3000/api/health" -TimeoutSec 5
        if ($grafanaHealth.database -eq "ok") {
            return @{ Passed = $true; Message = ("Grafana hoat dong tot (database: ok, version: {0})" -f $grafanaHealth.version) }
        } else {
            return @{ Passed = $false; Message = "Grafana database status khong phai ok" }
        }
    } catch {
        return @{ Passed = $false; Message = $_.Exception.Message }
    }
}

Run-Test -Category "GiamSat" -TestName "Grafana Auto-Provisioning: Tu dong nap Data Source Prometheus" -TestBlock {
    try {
        $pair = "hoang:hoang"
        $encoded = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($pair))
        $datasources = Invoke-RestMethod -Uri "http://localhost:3000/api/datasources" -Headers @{Authorization="Basic $encoded"} -TimeoutSec 5
        $promDs = $datasources | Where-Object { $_.type -eq "prometheus" }
        if ($promDs -and $promDs.isDefault -eq $true) {
            return @{ Passed = $true; Message = ("Data Source Prometheus tu dong nap san sang (Url: {0}, isDefault: True)" -f $promDs.url) }
        } else {
            return @{ Passed = $false; Message = "Chua tim thay default Prometheus Data Source trong Grafana" }
        }
    } catch {
        return @{ Passed = $false; Message = $_.Exception.Message }
    }
}

# ------------------------------------------------------------------------------
# TONG KET KET QUA KIEM THU
# ------------------------------------------------------------------------------
Write-Host ""
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "                       TONG KET KET QUA TEST                          " -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host (" Tong so ca kiem thu : {0}" -f $totalTests)
Write-Host (" So ca pass          : {0}" -f $passedTests) -ForegroundColor Green
if ($failedTests -gt 0) {
    Write-Host (" So ca fail          : {0}" -f $failedTests) -ForegroundColor Red
} else {
    Write-Host (" So ca fail          : 0") -ForegroundColor Green
    Write-Host ""
    Write-Host "Ket qua: Tat ca cac test case deu PASSED." -ForegroundColor Green
}
Write-Host "======================================================================" -ForegroundColor Cyan
