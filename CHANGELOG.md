# Changelog

## [Unreleased]
### Todo (Commit 3)
- Cấu hình Loki + Promtail để thu thập log Nginx.
- Viết query LogQL mẫu và dashboard log trên Grafana.

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
