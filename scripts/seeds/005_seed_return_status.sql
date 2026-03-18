-- Seed: 005_seed_return_status.sql
-- Import dữ liệu từ file CSV vào bảng return_status
--
-- YÊU CẦU: File CSV phải được đặt tại scripts/return_status.csv
-- File CSV không được commit lên GitHub (đã có trong .gitignore)
-- Tải file CSV về và copy vào thư mục scripts/ trước khi chạy lệnh này

BULK INSERT [dbo].[Return_status]
FROM '/scripts/return_status.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\r\n',
    TABLOCK
);
