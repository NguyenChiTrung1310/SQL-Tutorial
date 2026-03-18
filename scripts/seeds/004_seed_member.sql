-- Seed: 002_seed_member.sql
-- Import dữ liệu từ file CSV vào bảng members
--
-- YÊU CẦU: File CSV phải được đặt tại scripts/members.csv
-- File CSV không được commit lên GitHub (đã có trong .gitignore)
-- Tải file CSV về và copy vào thư mục scripts/ trước khi chạy lệnh này

BULK INSERT [dbo].[Members]
FROM '/scripts/members.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\r\n',
    TABLOCK
);
