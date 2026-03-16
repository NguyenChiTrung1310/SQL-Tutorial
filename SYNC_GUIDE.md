# Hướng dẫn đồng bộ Database giữa nhiều thiết bị

## Nguyên lý hoạt động

Project này dùng **migration + seed pattern** để đồng bộ database qua GitHub.
Thay vì sync binary data của Docker volume, ta sync **các file SQL text** định nghĩa schema và data mẫu.

```
GitHub Repository
├── scripts/migrations/   ← định nghĩa cấu trúc bảng (CREATE TABLE, ALTER TABLE,...)
└── scripts/seeds/        ← dữ liệu mẫu cố định (INSERT mẫu để học SQL)
```

Mỗi khi chạy `make up` hoặc `make migrate`, script `run_migrations.sh` sẽ:
1. Đọc tất cả file trong `migrations/` và `seeds/` theo thứ tự số
2. Bỏ qua file đã chạy (tra bảng `__migrations_history`)
3. Chỉ chạy file **mới** chưa có trong history

---

## Thiết lập lần đầu trên thiết bị mới

### Yêu cầu cài đặt

| Công cụ | Cài đặt | Kiểm tra |
| ------- | ------- | -------- |
| Docker Desktop | [docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop/) | `docker --version` |
| Git | Có sẵn trên macOS | `git --version` |
| Make | Có sẵn trên macOS | `make --version` |

### Các bước thiết lập

**Bước 1:** Clone project từ GitHub

```bash
git clone <repository-url>
cd "SQL Tutorial"
```

**Bước 2:** Tạo file `.env` từ file mẫu

```bash
cp .env.example .env
```

**Bước 3:** Mở file `.env` và đặt mật khẩu

```bash
# .env
SQL_PASSWORD=<mật_khẩu_của_bạn>
DB_NAME=sql_tutorial
```

> Dùng cùng một mật khẩu trên tất cả thiết bị để tránh nhầm lẫn.
> File `.env` không được commit lên GitHub (đã có trong `.gitignore`).

**Bước 4:** Khởi động Docker Desktop, sau đó chạy

```bash
make up
```

Lệnh này sẽ tự động:

- Pull image SQL Server về máy (lần đầu mất vài phút)
- Khởi động container
- Tạo database
- Chạy toàn bộ migration + seed

**Bước 5:** Kiểm tra kết quả

```bash
make history
```

Output mẫu cho thấy đã chạy thành công:

```
Id  FileName                          AppliedAt
--- --------------------------------- -----------------------
1   001_create_students_table.sql     2026-03-16 10:00:00
2   seed:001_seed_students.sql        2026-03-16 10:00:01
```

**Bước 6 (tuỳ chọn):** Kết nối bằng SQL client

Dùng [Azure Data Studio](https://azure.microsoft.com/en-us/products/data-studio) hoặc DBeaver để kết nối:

```
Server:   localhost,1433
Login:    sa
Password: <mật_khẩu_trong_.env>
```

---

## Thứ tự làm việc chuẩn

### MacBook 1 — Khi bạn thêm bảng hoặc data mẫu mới

**Bước 1:** Tạo file migration hoặc seed mới

```
scripts/
├── migrations/
│   ├── 001_create_students_table.sql   ← đã có
│   └── 002_create_courses_table.sql    ← bạn tạo mới
└── seeds/
    ├── 001_seed_students.sql           ← đã có
    └── 002_seed_courses.sql            ← bạn tạo mới (nếu cần)
```

> Quy tắc đặt tên: `NNN_mo_ta_ngan.sql` — số thứ tự 3 chữ số tăng dần.

**Bước 2:** Chạy migration để kiểm tra trước khi push

```bash
make migrate
```

**Bước 3:** Push lên GitHub

```bash
git add scripts/
git commit -m "add: migration 002 create courses table"
git push
```

---

### MacBook 2 — Khi chuyển sang máy khác

**Bước 1:** Pull code mới nhất từ GitHub

```bash
git pull
```

**Bước 2a:** Nếu Docker **đang chạy** — chỉ cần migrate thêm

```bash
make migrate
```

Script sẽ tự động bỏ qua các migration cũ đã chạy, chỉ chạy file mới.

**Bước 2b:** Nếu Docker **chưa chạy** — khởi động và migrate cùng lúc

```bash
make up
```

---

## Hiểu rõ giới hạn

| Nội dung | Sync được không? | Lý do |
|----------|-----------------|-------|
| Cấu trúc bảng (`CREATE TABLE`, `ALTER TABLE`) | ✅ Có | Nằm trong file migration |
| Dữ liệu mẫu cố định (seed) | ✅ Có | Nằm trong file seed |
| Data bạn INSERT thủ công trong quá trình dùng | ❌ Không | Nằm trong Docker volume cục bộ |
| Kết quả bài tập, query thực hành | ❌ Không | Chỉ lưu trong memory của session |

**Ví dụ thực tế:**
- MacBook 1 chạy `INSERT INTO Students VALUES ('test', 'test@email.com')` thủ công → record đó **không sang MacBook 2**
- MacBook 1 thêm file `seeds/002_seed_courses.sql` rồi commit → MacBook 2 pull về và `make migrate` sẽ **có đầy đủ dữ liệu**

---

## Khi nào dùng migration, khi nào dùng seed?

| Mục đích | Dùng gì | Thư mục |
|----------|---------|---------|
| Tạo / sửa cấu trúc bảng | Migration | `scripts/migrations/` |
| Thêm data mẫu dùng để học, demo | Seed | `scripts/seeds/` |
| Data bạn INSERT khi thực hành | Không cần lưu file | — |

---

## Quy trình xử lý vấn đề thường gặp

### Hai máy bị lệch schema

Triệu chứng: MacBook 2 báo lỗi "column does not exist" hoặc "table not found".

```bash
# Xem migration history trên máy hiện tại
make history

# Nếu thiếu migration, chạy lại
make migrate
```

### Muốn reset hoàn toàn và bắt đầu lại từ đầu

```bash
# XÓA TOÀN BỘ data và chạy lại từ migration đầu tiên
make reset
```

> **Cảnh báo:** `make reset` xóa Docker volume, mất hết data thủ công đã insert. Phù hợp khi học — không dùng cho môi trường production.

### Muốn thêm data mẫu mới để cả 2 máy đều có

1. Tạo file `scripts/seeds/NNN_ten_file.sql` với các câu `INSERT`
2. Chạy `make migrate` để test
3. Commit và push lên GitHub
4. Máy kia `git pull` + `make migrate`

---

## Checklist khi chuyển máy

```
[ ] git pull                    — lấy code + migration mới nhất
[ ] cp .env.example .env        — (chỉ lần đầu) tạo file env
[ ] Điền SQL_PASSWORD vào .env  — (chỉ lần đầu)
[ ] make up                     — khởi động Docker + tự migrate
[ ] make history                — kiểm tra migration đã chạy đủ chưa
```
