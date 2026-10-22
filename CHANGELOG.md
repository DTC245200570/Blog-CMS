# Changelog

## [1.2.0] - 2026-10-12
### Added (Commit 3)
- Triển khai cụm Centralized Logging với Loki và Promtail thu thập log Nginx.
- Cấu hình Promtail tail file JSON access log và error log từ volume dùng chung `nginx_logs`.
- Cấu hình Grafana tự động nạp Data Source Loki qua provisioning (`grafana/provisioning/datasources/loki.yml`).
- Bổ sung và kiểm thử thành công 3 câu truy vấn LogQL bắt buộc (`|= "GET"`, `| json | status >= 400`, `rate({job="nginx"}[1m])`).
- Áp dụng các biện pháp Hardening bảo mật:
  - Network Isolation: Phân tách 3 bridge networks độc lập (`frontend_net`, `backend_net`, `monitor_net`), đóng cổng database MySQL 3306 với host.
  - Non-root Container: Loki (UID 10001) và Prometheus (nobody) chạy dưới user không có đặc quyền.
  - Resource Limits: Giới hạn CPU và Memory cụ thể cho toàn bộ 10 containers.
  - Nginx Security Headers: `X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`, `Referrer-Policy`, `Strict-Transport-Security`.
  - Quản lý mật khẩu an toàn: Phân tách toàn bộ credentials vào file `.env`.
- Mở rộng kịch bản kiểm thử tự động lên 21 ca test (Pass 21/21) trên cả PowerShell (`scripts/test-system.ps1`) và Bash Shell (`scripts/test-system.sh`).

---

## [1.1.0] - 2026-10-07
### Added (Commit 2)
- Thêm Prometheus scrape metrics định kỳ (`prometheus.yml`).
- Thêm cAdvisor lấy metrics CPU, RAM, Network container.
- Thêm mysqld-exporter kết nối MySQL lấy database metrics.
- Cấu hình Grafana tự động nhận Prometheus qua provisioning.
- Thêm mạng `monitor_net` riêng cho cụm monitoring.
- Thêm script test tự động hệ thống (`scripts/test-system.ps1`, `scripts/test-system.sh`).

---

## [1.0.0] - 2026-10-07
### Added (Commit 1)
- Khởi tạo stack WordPress, MySQL 8.0 và phpMyAdmin.
- Tách 2 mạng `frontend_net` và `backend_net`, đóng port 3306 ra ngoài host.
- Cấu hình Nginx reverse proxy, tự redirect HTTP sang HTTPS (443).
- Thêm script tạo self-signed SSL nội bộ.
- Cấu hình security headers trên Nginx (`X-Frame-Options`, `HSTS`, `nosniff`...).
- Quản lý cấu hình qua `.env`.
