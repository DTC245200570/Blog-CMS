# Danh Sách Ảnh Minh Chứng Báo Cáo Đề Tài (Blog-CMS)

Tài liệu này lưu trữ danh sách các hình ảnh chụp màn hình minh chứng kết quả thực hiện qua từng giai đoạn (Commit), giúp đồng bộ và chèn vào báo cáo môn học một cách chính xác.

---

## 📸 Giai đoạn 1: Triển khai hạ tầng Web & Bảo mật (Commit 1)
*Đã chụp 3 ảnh minh chứng:*

| STT | Tên file đề xuất | Nội dung minh chứng | Vị trí chèn trong báo cáo |
| :--- | :--- | :--- | :--- |
| **01** | `hinh1_wordpress_https.png` | Giao diện WordPress qua kết nối bảo mật HTTPS (ổ khóa xanh, chứng chỉ SSL nội bộ) | Phần "Cấu hình Nginx Reverse Proxy & SSL" |
| **02** | `hinh2_phpmyadmin_login.png` | Giao diện phpMyAdmin đăng nhập thành công CSDL MySQL nội bộ | Phần "Quản trị cơ sở dữ liệu phpMyAdmin" |
| **03** | `hinh3_docker_network_security.png` | Danh sách container ban đầu & cấu hình mạng cô lập (`frontend_net`, `backend_net`) | Phần "Kiến trúc mạng Docker & Phân vùng bảo mật" |

---

## 📸 Giai đoạn 2: Giám sát hệ thống với Prometheus & Grafana (Commit 2)
*Cần chụp 4 ảnh minh chứng sau:*

| STT | Tên file đề xuất | Nơi chụp / Thao tác | Nội dung minh chứng |
| :--- | :--- | :--- | :--- |
| **04** | `hinh4_prometheus_targets_up.png` | `http://localhost:9090/targets` | Danh sách cả 3 Targets: **cadvisor**, **mysql**, **prometheus** đều hiển thị màu xanh **UP (1/1)** |
| **05** | `hinh5_prometheus_graph_query.png` | `http://localhost:9090/graph` | Thực thi một câu truy vấn PromQL (vd: `mysql_global_status_threads_connected` hoặc `container_memory_usage_bytes`) hiển thị biểu đồ đồ thị |
| **06** | `hinh6_grafana_datasource.png` | `http://localhost:3000/datasources` | Data source **Prometheus** được tự động cấu hình (Provisioning) và kết nối thành công |
| **07** | `hinh7_grafana_dashboard.png` | `http://localhost:3000/dashboards` | Bảng điều khiển (Dashboard) trên Grafana hiển thị trực quan các biểu đồ CPU, RAM hoặc MySQL metrics |

---

## 📸 Giai đoạn 3: Thu thập Log tập trung với Loki & Promtail (Commit 3 - Sắp tới)
*(Dự kiến khi thực hiện Commit 3)*

| STT | Tên file đề xuất | Nơi chụp / Thao tác | Nội dung minh chứng |
| :--- | :--- | :--- | :--- |
| **08** | `hinh8_grafana_explore_loki.png` | `http://localhost:3000/explore` (chọn nguồn Loki) | Truy vấn LogQL xem log truy cập Web và mã trạng thái HTTP (200, 404, 500) |
| **09** | `hinh9_docker_ps_full_stack.png` | Terminal: `docker ps` | Toàn bộ 9/9 container của hệ thống hoạt động ổn định và đầy đủ |

---

> **Mẹo:** Bạn hãy lưu các file ảnh chụp vào một thư mục (ví dụ `docs/images/` hoặc thư mục riêng trong máy) với đúng tên file ở cột **"Tên file đề xuất"**. Khi hoàn thiện báo cáo, AI sẽ căn cứ đúng các tên file này để soạn văn bản và vị trí minh chứng cho bạn.
