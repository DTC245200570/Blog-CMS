# ĐỀ TÀI 07: TRIỂN KHAI VÀ QUẢN TRỊ HỆ THỐNG BLOG / CMS

Dự án bài tập lớn môn **Triển khai và Quản trị Hệ thống Phần mềm**.

---

## 📌 1. Giới thiệu tổng quan
Hệ thống cung cấp dịch vụ Blog / CMS quản lý bài viết, danh mục và tác giả, được đóng gói và vận hành hoàn chỉnh trên nền tảng **Docker & Docker Compose**.

### Các thành phần chính:
* **Ứng dụng Web (Blog/CMS):** Node.js Express / MySQL Client.
* **Cơ sở dữ liệu:** MySQL 8.0 & phpMyAdmin.
* **Cổng giao tiếp (Reverse Proxy):** Nginx (kèm SSL HTTPS tự ký và Security Headers).
* **Hệ thống giám sát (Monitoring):** Prometheus + Grafana + Exporters (cAdvisor, mysqld-exporter).
* **Hệ thống log tập trung (Logging):** Loki + Promtail (truy vấn với LogQL).
* **Bảo mật (Hardening):** Non-root container, network isolation, bảo vệ tài nguyên (limits).

---

## 🏗️ 2. Sơ đồ Kiến trúc Mạng & Dịch vụ

```
[ Client / Browser ]
        |
        v (Port 80/443)
+--------------------------------------------------------+
| Nginx Reverse Proxy (SSL + Security Headers)           |
+--------------------------------------------------------+
      | (frontend_net)              | (frontend_net)
      v                             v
+------------------+         +------------------+
|  Web App (CMS)   |         |    phpMyAdmin    |
+------------------+         +------------------+
      | (backend_net)               | (backend_net)
      +---------------> +------------------+ <-----+
                        |  MySQL Database  |
                        +------------------+

================= MẠNG GIÁM SÁT (monitor_net) =================
+-------------+     +------------+     +-------------------+
| Prometheus  | <-- | cAdvisor   |     | mysqld-exporter   |
+-------------+     +------------+     +-------------------+
      |
      v
+-------------+     +------------+     +-------------------+
|   Grafana   | <-- |    Loki    | <-- | Promtail (Agent)  |
+-------------+     +------------+     +-------------------+
```

---

## 🚀 3. Hướng dẫn Khởi chạy Hệ thống

### Bước 1: Sao chép file cấu hình môi trường
```bash
cp .env.example .env
```
*(Chỉnh sửa mật khẩu hoặc thông số cổng trong `.env` nếu cần).*

### Bước 2: Tạo chứng chỉ SSL tự ký cho Nginx (Self-signed Certificate)
```bash
mkdir -p nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/server.key \
  -out nginx/ssl/server.crt \
  -subj "/C=VN/ST=Hanoi/L=Hanoi/O=IT/CN=localhost"
```

### Bước 3: Khởi chạy toàn bộ hệ thống bằng Docker Compose
```bash
docker compose up -d --build
```

### Bước 4: Kiểm tra trạng thái các container
```bash
docker compose ps
```

---

## 🌐 4. Danh sách các Cổng và Đường dẫn Dịch vụ

| Dịch vụ | URL Truy cập | Tài khoản mặc định | Ghi chú |
|:---|:---|:---|:---|
| **Blog / CMS Web** | `https://localhost` | - | Qua Nginx Proxy |
| **phpMyAdmin** | `https://localhost/pma/` | User: `blog_user` / `root` | Quản trị CSDL |
| **Grafana** | `http://localhost:3000` | `admin` / Xem trong `.env` | Dashboard trực quan |
| **Prometheus** | `http://localhost:9090` | - | Thu thập Metrics |
| **Loki** | `http://localhost:3100` | - | Lưu trữ log |

---

## 🛡️ 5. Các biện pháp Hardening Đã Áp Dụng
1. **Network Isolation:** Chia 3 mạng riêng biệt `frontend_net`, `backend_net`, `monitor_net`. Database MySQL không mở port trực tiếp ra máy host.
2. **Non-Root Containers:** App chạy với user có đặc quyền thấp, giảm nguy cơ container escape.
3. **Environment Isolation:** Sử dụng file `.env` tách rời khỏi mã nguồn và git.
4. **Security Headers:** Nginx chặn clickjacking (`X-Frame-Options`), MIME-type sniffing (`X-Content-Type-Options`), và áp dụng CSP.
5. **Resource Limiting:** Hạn chế CPU và RAM tối đa cho từng service phòng chống tấn công DoS.

---

## 📊 6. Truy vấn LogQL mẫu trên Grafana
Vào Grafana $\rightarrow$ **Explore** $\rightarrow$ chọn Data Source **Loki**:
1. Lọc tất cả log của Nginx:
   ```logql
   {job="nginx"}
   ```
2. Lọc log lỗi status $\ge$ 400:
   ```logql
   {job="nginx"} | status >= 400
   ```
3. Đếm tần suất request theo phút:
   ```logql
   rate({job="nginx"}[1m])
   ```
