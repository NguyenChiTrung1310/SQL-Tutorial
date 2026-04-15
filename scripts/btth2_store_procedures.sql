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

-- 3. Giống (1) và (2) kiểm tra xem MSGV có trùng không? MSHH có tồn tại chưa? Nếu MSGV trùng thì trả về 0.
-- Nếu MSHH chưa tồn tại trả về 1, ngược lại cho insert dữ liệu.
CREATE PROC usp_InsertGiaoVien_2A_3
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

        IF NOT EXISTS (SELECT 1 FROM HOCHAM WHERE MSHH = @MSHH)
        BEGIN
            print(N'Mã học hàm không tồn tại!')
            RETURN 1
        END

        INSERT INTO GIAOVIEN (MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)
        VALUES (@MSGV, @TENGV, @DIACHI, @SODT, @MSHH, @NAMHH)

        RETURN 2
    END
GO

-- 4. Đưa vào MSDT cũ, TENDT mới. Hãy cập nhật tên đề tài mới với mã đề tài cũ không đổi
-- nếu không tìm thấy trả về 0, ngược lại cập nhật và trả về 1.
CREATE PROC usp_UpdateTenDeTai
(
    @MSDT char(6),
    @TENDTMOI nvarchar(30)
)
AS
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM DETAI WHERE @MSDT = MSDT)
        BEGIN
            print(N'Mã đề tài không tồn tại!')
            RETURN 0
        END

        UPDATE DETAI
        SET TENDT = @TENDTMOI
        WHERE MSDT = @MSDT

        RETURN 1
    END
GO

-- 5. Tham số đưa vào MSSV, TENSV mới, DIACHI mới. Hãy cập nhật sinh viên trên với MSSV không đổi,
-- nếu không tìm thấy trả về 0, ngược lại cập nhật và trả về 1.
CREATE PROC usp_UpdateThongTinSinhVien
(
  @MSSV char(8),
  @TENSVMOI nvarchar(30),
  @DIACHIMOI nchar(50)
)
AS
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM SINHVIEN WHERE MSSV = @MSSV)
        BEGIN
            print(N'Mã sinh viên không tồn tại!')
            RETURN 0
        END

        UPDATE SINHVIEN
        SET TENSV = @TENSVMOI, DIACHI = @DIACHIMOI
        WHERE MSSV = @MSSV

        RETURN 1
    END
GO

-- B. STORED PROCEDURES VỚI THAM SỐ VÀO VÀ RA
-- 1. Đưa vào TENHV trả ra: Số GV thỏa học vị, nếu không tìm thấy trả về 0.
CREATE PROC usp_CountGiaoVienByHocVi
(
    @TENHV nvarchar(20)
)
AS
    BEGIN
        DECLARE @MSHV INT;
        DECLARE @CountGV int;

        SELECT @MSHV = MSHV
        FROM HOCVI
        WHERE LOWER(TRIM(TENHV)) = LOWER(TRIM(@TENHV));

        IF @MSHV IS NULL
            BEGIN
                print(N'Tên học vị không tồn tại!')
                RETURN 0;
            END

        SELECT @CountGV = COUNT(DISTINCT MSGV)
        FROM GV_HV_CN
        WHERE MSHV = @MSHV

        PRINT CONCAT(N'Số GV thỏa học vị là ', @CountGV);
        return @CountGV
    END
GO
















