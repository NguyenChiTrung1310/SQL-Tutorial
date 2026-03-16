-- Seed: 002_seed_retail_sales.sql
-- Import dữ liệu từ file CSV vào bảng Retail_Sales
--
-- YÊU CẦU: File CSV phải được đặt tại scripts/SQL - Retail Sales Analysis_utf .csv
-- File CSV không được commit lên GitHub (đã có trong .gitignore)
-- Tải file CSV về và copy vào thư mục scripts/ trước khi chạy lệnh này

BULK INSERT [dbo].[Retail_Sales]
FROM '/scripts/SQL - Retail Sales Analysis_utf .csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
