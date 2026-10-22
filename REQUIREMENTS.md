# YÊU CẦU ĐỀ TÀI & TIÊU CHÍ ĐÁNH GIÁ (ĐỀ 7)
**Môn học:** Triển khai và Quản trị Hệ thống Phần mềm  
**Đề tài 7:** Hệ thống Blog / CMS

---

## 1. MỤC TIÊU & PHẠM VI DỰ ÁN
* **Phần mềm triển khai:** Website Blog hoặc CMS (quản lý bài viết, danh mục, người dùng).
* **Cơ sở dữ liệu:** MySQL + phpMyAdmin.
* **Hình thức triển khai:** Toàn bộ dịch vụ chạy bằng **Docker Compose** (`docker-compose.yml`).
* **Hạ tầng bổ trợ:**
  * **Nginx:** Reverse Proxy, SSL/HTTPS tự ký, Security Headers.
  * **Monitoring:** Prometheus + Grafana giám sát Container, Web Server, Database.
  * **Centralized Logging:** Loki + Promtail, truy vấn log bằng LogQL.
  * **Security Hardening:** Non-root container, Network isolation, Mật khẩu an toàn, Giới hạn quyền và tài nguyên.

---

## 2. TIÊU CHÍ CHẤM ĐIỂM CHI TIẾT (THANG ĐIỂM 10)

| STT | Tiêu chí đánh giá | Nội dung đánh giá | Điểm số |
|:---:|:---|:---|:---:|
| **1** | **Quản lý mã nguồn trên GitHub** | - Tạo tài khoản và đặt tên theo **Mã số sinh viên (MSSV)**.<br>- Repo có đủ mã nguồn + file cấu hình (`docker-compose`, Nginx, Prometheus...).<br>- Đủ **03 commit đúng chuẩn mốc** quy định.<br>- File `README.md` rõ ràng, có hướng dẫn chạy hệ thống. | **1.5đ** |
| **2** | **Triển khai ứng dụng + Database** | - Ứng dụng Blog/CMS hoạt động ổn định, kết nối MySQL thành công.<br>- Giao diện quản trị phpMyAdmin kết nối và quản trị database bình thường. | **1.5đ** |
| **3** | **Nginx Reverse Proxy** | - Cấu hình Reverse Proxy làm cổng đón duy nhất ra bên ngoài.<br>- Truy cập website qua Nginx.<br>- Có HTTPS (SSL tự ký) hoặc cấu hình Security Headers cơ bản. | **1.5đ** |
| **4** | **Hệ thống giám sát (Prometheus + Grafana)** | - Prometheus tự động cào và thu thập metrics.<br>- Grafana kết nối data source Prometheus, có Dashboard giám sát container / web / DB. | **1.5đ** |
| **5** | **Hệ thống log tập trung (Loki)** | - Loki + Promtail thu thập log container & Nginx.<br>- Truy vấn log trên Grafana bằng LogQL (ít nhất 2–3 câu query cơ bản). | **1.5đ** |
| **6** | **Hardening hệ thống** | Áp dụng ít nhất **3 – 4 biện pháp bảo mật**:<br>1. Container non-root.<br>2. Tách mạng nội bộ (Network isolation - không expose bừa bãi cổng DB).<br>3. Mật khẩu mạnh, quản lý qua `.env`.<br>4. Nginx security headers (`X-Frame-Options`, `CSP`, `HSTS`, ...).<br>5. Giới hạn tài nguyên (CPU/RAM limit). | **1.5đ** |
| **7** | **Tổng thể & Trình bày & Báo cáo** | - Hệ thống chạy hoàn chỉnh bằng 1 lệnh `docker compose up -d`.<br>- Báo cáo tổng hợp $\ge$ **10 trang** (bìa chuẩn thực tập, mô tả kiến trúc, kết quả 6 bước có ảnh chụp màn hình minh chứng).<br>- Trả lời vấn đáp tốt, hiểu bài. | **1.0đ** |

---

## 3. CÁC MỐC COMMIT GITHUB BẮT BUỘC
Giảng viên kiểm tra lịch sử commit để chấm điểm (Tiêu chí 1), do đó phải thực hiện commit đúng các mốc sau:

* **Mốc 1 (Commit 1):**
  * *Nội dung:* Triển khai Nginx làm Reverse Proxy trỏ về Web App Blog/CMS và phpMyAdmin (có cấu hình HTTPS tự ký hoặc Security Headers).
  * *Gợi ý message:* `Commit 1: Setup Web App, MySQL, phpMyAdmin and Nginx reverse proxy with SSL`
* **Mốc 2 (Commit 2):**
  * *Nội dung:* Tích hợp Prometheus và Grafana để giám sát container, web server và database.
  * *Gợi ý message:* `Commit 2: Integrate Prometheus and Grafana for system and database monitoring`
* **Mốc 3 (Commit 3):**
  * *Nội dung:* Triển khai hệ thống log tập trung Loki + Promtail và áp dụng các biện pháp Hardening bảo mật hệ thống.
  * *Gợi ý message:* `Commit 3: Setup Loki and Promtail log aggregation and apply security hardening`

---

## 4. BẢNG CHECKLIST CÁC BIỆN PHÁP HARDENING
Cần minh chứng trong báo cáo ít nhất 3–4 mục:
- [ ] **Network Isolation:** Phân chia các bridge networks riêng biệt (`frontend_net`, `backend_net`, `monitor_net`). MySQL không được public `ports: 3306` ra máy chủ host.
- [ ] **Non-root Container:** Dockerfile định nghĩa user riêng (`USER node` hoặc user ID > 1000) để chạy ứng dụng thay vì root.
- [ ] **Quản lý mật khẩu an toàn:** Không gán cứng password trong `docker-compose.yml`, dùng file `.env` tách biệt.
- [ ] **Nginx Security Headers:** Cấu hình `X-Content-Type-Options`, `X-Frame-Options`, `X-XSS-Protection`, `Referrer-Policy`.
- [ ] **Resource Limits:** Thiết lập giới hạn `cpus` và `memory` (ví dụ: `limits.memory: 512M`) trong `docker-compose.yml`.

---

## 5. CÁC CÂU TRUY VẤN LOGQL CẦN DEMO
Lưu lại sẵn để chạy trên Grafana Explore và chụp màn hình đưa vào báo cáo:
1. **Lọc log Nginx truy cập theo method:**
   ```logql
   {job="nginx"} |= "GET"
   ```
2. **Lọc các request phát sinh lỗi (status code >= 400):**
   ```logql
   {job="nginx"} | json | status >= 400
   ```
   *(hoặc pattern matching: `{job="nginx"} |~ "HTTP/1\\.[01]\" [45][0-9]{2}"`)*
3. **Đo đếm tần suất truy cập web server (Requests per second/minute):**
   ```logql
   rate({job="nginx"}[1m])
   ```

---

## 6. YÊU CẦU BÁO CÁO TỔNG HỢP ($\ge$ 10 TRANG)
1. **Trang bìa:** Mẫu chuẩn báo cáo thực tập (Tên trường, khoa, tên môn học, MSSV, Họ tên sinh viên, Đề tài số 7, giảng viên hướng dẫn).
2. **Chương 1: Tổng quan đề tài & Kiến trúc hệ thống** (Sơ đồ các container kết nối với nhau).
3. **Chương 2: Cài đặt ứng dụng Blog/CMS & MySQL qua Docker Compose**.
4. **Chương 3: Cấu hình Nginx Reverse Proxy & Chứng chỉ SSL**.
5. **Chương 4: Giám sát tài nguyên với Prometheus & Grafana** (Kèm hình ảnh Dashboards).
6. **Chương 5: Quản trị Log tập trung với Loki & Promtail** (Kèm hình ảnh kết quả 3 câu LogQL).
7. **Chương 6: Triển khai các giải pháp Hardening bảo mật**.
8. **Chương 7: Hướng dẫn vận hành & Kết luận**.
