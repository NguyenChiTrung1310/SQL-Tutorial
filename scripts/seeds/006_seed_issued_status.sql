-- Seed: 006_seed_issued_status.sql
-- Import dữ liệu từ file CSV vào bảng Issued_status
--
-- YÊU CẦU: File CSV phải được đặt tại scripts/issued_status.csv
-- File CSV không được commit lên GitHub (đã có trong .gitignore)
-- Tải file CSV về và copy vào thư mục scripts/ trước khi chạy lệnh này

-- Workaround: FORMAT='CSV' + FIELDQUOTE không hoạt động trên SQL Server Linux (Docker)
-- Dùng staging table + TRIM + REPLACE để xử lý quoted CSV đúng chuẩn RFC 4180
CREATE TABLE #staging_issued_status (
    issued_id     VARCHAR(10),
    issued_member_id VARCHAR(10),
    issued_book_name VARCHAR(80),
    issued_date   DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id VARCHAR(10)
);

BULK INSERT #staging_issued_status
FROM '/scripts/issued_status.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = '","',
    ROWTERMINATOR   = '"\r\n',
    TABLOCK
);

INSERT INTO [dbo].[Issued_status] (issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
SELECT
    REPLACE(TRIM('"' FROM issued_id),          '""', '"'),
    REPLACE(TRIM('"' FROM issued_member_id),   '""', '"'),
    REPLACE(TRIM('"' FROM issued_book_name),   '""', '"'),
    CAST(REPLACE(TRIM('"' FROM CAST(issued_date AS VARCHAR(20))), '""', '"') AS DATE),
    REPLACE(TRIM('"' FROM issued_book_isbn),   '""', '"'),
    REPLACE(TRIM('"' FROM issued_emp_id),      '""', '"')
FROM #staging_issued_status;

DROP TABLE #staging_issued_status;
