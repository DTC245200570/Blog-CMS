# Blog & CMS Deployment

Triển khai hệ thống Blog / CMS (WordPress) sử dụng Docker Compose, Nginx Reverse Proxy (SSL/HTTPS), tích hợp giám sát và quản lý log tập trung.

---

## 1. Kiến trúc hệ thống

```
[ Client / Browser ]
        |
        v (Port 80/443)
+----------------------------------------------------+
| Nginx Reverse Proxy (SSL + Security Headers)       |
+----------------------------------------------------+
      | (frontend_net)              | (frontend_net)
      v                             v
+------------------+         +------------------+
| WordPress (CMS)  |         |    phpMyAdmin    |
+------------------+         +------------------+
      | (backend_net)               | (backend_net)
      +---------------> +------------------+ <-----+
                        |  MySQL Database  |
                        +------------------+

================= Monitoring & Logging =================
+-------------+     +------------+     +-------------------+
| Prometheus  | <-- | cAdvisor   |     | mysqld-exporter   |
+-------------+     +------------+     +-------------------+
      |
      v
+-------------+     +------------+     +-------------------+
|   Grafana   | <-- |    Loki    | <-- | Promtail          |
+-------------+     +------------+     +-------------------+
```

---

## 2. Hướng dẫn cài đặt & chạy

### Bước 1: Tạo file cấu hình môi trường
```bash
# Linux/macOS
cp .env.example .env

# Windows PowerShell
Copy-Item .env.example .env
```
Chỉnh sửa lại tài khoản/mật khẩu trong file `.env` nếu cần.

### Bước 2: Tạo chứng chỉ SSL
- **Windows:**
  ```powershell
  .\nginx\ssl\generate-ssl.ps1
  ```
- **Linux:**
  ```bash
  chmod +x ./nginx/ssl/generate-ssl.sh
  ./nginx/ssl/generate-ssl.sh
  ```

### Bước 3: Khởi chạy hệ thống
```bash
docker compose up -d
```

Kiểm tra trạng thái:
```bash
docker compose ps
```

---

## 3. Danh sách dịch vụ & Cổng truy cập

| Dịch vụ | URL | Tài khoản mặc định | Ghi chú |
|:---|:---|:---|:---|
| **WordPress** | `https://localhost` | Khởi tạo ở lần đầu truy cập | Qua Nginx Proxy |
| **phpMyAdmin** | `https://localhost/pma/` | User: `hoang` hoặc `root` | Quản trị CSDL |
| **Grafana** | `http://localhost:3000` | User: `hoang` (mật khẩu trong `.env`) | Dashboard giám sát |
| **Prometheus** | `http://localhost:9090` | - | Thu thập metrics |
| **Loki** | `http://localhost:3100` | - | Lưu trữ log |

---

## 4. Các cấu hình bảo mật (Hardening)
- **Tách mạng nội bộ:** `frontend_net` dành cho Nginx & Web, `backend_net` dành cho Database. Cổng MySQL (3306) không public ra ngoài host.
- **Nginx Security Headers:** Cấu hình `X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`, `Strict-Transport-Security`, `Referrer-Policy`.
- **Giới hạn tài nguyên:** Đặt giới hạn `cpus` và `memory` cho các container trong `docker-compose.yml`.
- **Tách biệt cấu hình:** Toàn bộ thông tin đăng nhập, mật khẩu đưa vào `.env`, không đưa vào repo git.

---

## 5. Truy vấn LogQL mẫu trên Grafana
Truy cập Grafana > **Explore** > chọn nguồn dữ liệu **Loki**:
- Xem toàn bộ access log Nginx:
  ```logql
  {job="nginx"}
  ```
- Lọc log lỗi status >= 400:
  ```logql
  {job="nginx"} | status >= 400
  ```
- Tần suất request mỗi phút:
  ```logql
  rate({job="nginx"}[1m])
  ```

---

## 6. Kiểm thử tự động
Chạy script kiểm tra hệ thống:
- **Windows (PowerShell):**
  ```powershell
  .\scripts\test-system.ps1
  ```
- **Linux / Git Bash:**
  ```bash
  chmod +x ./scripts/test-system.sh
  ./scripts/test-system.sh
  ```

---

## 7. Lịch sử cập nhật
Xem chi tiết tại [CHANGELOG.md](CHANGELOG.md).
