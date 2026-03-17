-- Seed: 001_seed_data.sql
-- Import dữ liệu từ file CSV vào bảng Branch
--
-- YÊU CẦU: File CSV phải được đặt tại scripts/branch.csv
-- File CSV không được commit lên GitHub (đã có trong .gitignore)
-- Tải file CSV về và copy vào thư mục scripts/ trước khi chạy lệnh này

BULK INSERT [dbo].[Branch]
FROM '/scripts/branch.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
