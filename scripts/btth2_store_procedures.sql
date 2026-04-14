USE BTTH2_DB;

-- PHẦN 2:
-- A. STORED PROCEDURES VỚI THAM SỐ VÀO
-- 1. Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH.
-- Trước khi insert dữ liệu cần kiểm tra MSHH đã tồn tại trong table HOCHAM
-- chưa, nếu chưa thì trả về giá trị 0.
CREATE PROC usp_InsertGiaoVien_2A_1
(
    @MSGV int,
    @TENGV nvarchar(30),
    @SODT varchar(10),
    @DIACHI nvarchar(50),
    @MSHH int,
    @NAMHH smalldatetime
)
AS
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM HOCHAM WHERE MSHH = @MSHH)
        BEGIN
            print(N'Mã học hàm không tồn tại!')
            RETURN 0
        END

        INSERT INTO GIAOVIEN (MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)
        VALUES (@MSGV, @TENGV, @DIACHI, @SODT, @MSHH, @NAMHH)

        RETURN 1
    END
GO

-- 2. Tham số vào là MSGV, TENGV, SODT, DIACHI, MSHH, NAMHH.
-- Trước khi insert dữ liệu cần kiểm tra MSGV trong table GIAOVIEN có trùng
-- không, nếu trùng thì trả về giá trị 0.
CREATE PROC usp_InsertGiaoVien_2A_2
(
    @MSGV int,
    @TENGV nvarchar(30),
    @SODT varchar(10),
    @DIACHI nvarchar(50),
    @MSHH int,
    @NAMHH smalldatetime
)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM GIAOVIEN WHERE MSGV = @MSGV)
    BEGIN
        print(N'Mã giáo viên đã tồn tại!')
        RETURN 0
    END

    INSERT INTO GIAOVIEN (MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)
    VALUES (@MSGV, @TENGV, @DIACHI, @SODT, @MSHH, @NAMHH)

    RETURN 1
END
GO















