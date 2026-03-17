-- Seed: 003_seed_book.sql
-- Import dữ liệu từ file CSV vào bảng Books
--
-- YÊU CẦU: File CSV phải được đặt tại scripts/books.csv
-- File CSV không được commit lên GitHub (đã có trong .gitignore)
-- Tải file CSV về và copy vào thư mục scripts/ trước khi chạy lệnh này

-- Workaround: FORMAT='CSV' + FIELDQUOTE không hoạt động trên SQL Server Linux (Docker)
-- Dùng staging table + TRIM + REPLACE để xử lý quoted CSV đúng chuẩn RFC 4180
CREATE TABLE #staging_books (
    isbn          VARCHAR(52),
    book_title    VARCHAR(82),
    category      VARCHAR(32),
    rental_price  VARCHAR(20),
    status        VARCHAR(12),
    author        VARCHAR(32),
    publisher     VARCHAR(32)
);

BULK INSERT #staging_books
FROM '/scripts/books.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = '","',
    ROWTERMINATOR   = '"\r\n',
    TABLOCK
);

INSERT INTO [dbo].[Books] (isbn, book_title, category, rental_price, status, author, publisher)
SELECT
    REPLACE(TRIM('"' FROM isbn),              '""', '"'),
    REPLACE(TRIM('"' FROM book_title),        '""', '"'),
    REPLACE(TRIM('"' FROM category),          '""', '"'),
    CAST(REPLACE(TRIM('"' FROM rental_price), '""', '"') AS DECIMAL(10, 2)),
    REPLACE(TRIM('"' FROM status),            '""', '"'),
    REPLACE(TRIM('"' FROM author),            '""', '"'),
    REPLACE(TRIM('"' FROM publisher),         '""', '"')
FROM #staging_books;

DROP TABLE #staging_books;
