-- Migration: 001_create_students_table.sql
-- Tạo bảng Students làm ví dụ

CREATE TABLE [dbo].[Students]
(
    [Id]        INT             NOT NULL IDENTITY(1,1) PRIMARY KEY,
    [Name]      NVARCHAR(100)   NOT NULL,
    [Email]     NVARCHAR(255)   NOT NULL UNIQUE,
    [CreatedAt] DATETIME2       NOT NULL DEFAULT GETDATE()
)
