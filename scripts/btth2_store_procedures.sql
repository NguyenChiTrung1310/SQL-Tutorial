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

        SELECT @CountGV AS SoGVThoaHocVi
        return @CountGV
    END
GO

-- 2. Đưa vào MSDT cho biết: Điểm trung bình của đề tài, nếu không tìm thấy trả về 0
CREATE PROC usp_GetDiemTrungBinhByMSDT
(
    @MSDT char(6)
)
AS
    BEGIN
        DECLARE @DiemTB FLOAT;

        IF NOT EXISTS (SELECT 1 FROM DETAI WHERE MSDT = @MSDT)
            BEGIN
                print(N'Mã số đề tài không tồn tại!')
                RETURN 0
            END

        SELECT @DiemTB = CAST(AVG(DIEM) AS DECIMAL(5,2))
        FROM (
                 SELECT DIEM FROM GV_HDDT WHERE MSDT = @MSDT
                 UNION ALL
                 SELECT DIEM FROM GV_PBDT WHERE MSDT = @MSDT
                 UNION ALL
                 SELECT DIEM FROM GV_UVDT WHERE MSDT = @MSDT
             ) AS DiemDeTai;

        IF @DiemTB IS NULL
            SET @DiemTB = 0;

        SELECT @DiemTB AS DiemTrungBinhCuaDeTai;
        RETURN 1;
    END
GO

-- 3. Đưa vào TENGV trả ra: SDT của giáo viên đó, nếu không tìm thấy trả về 0.
-- Nếu trùng tên thì có báo lỗi không? Tại sao? Làm sao để hiện thông báo có bao
-- nhiêu giáo viên trùng tên và trả về các SDT.
CREATE PROC usp_GetSDTByTenGV
(
    @TENGV nvarchar(30)
)
AS
    DECLARE @CountGV INT;
    BEGIN
        SELECT @CountGV = COUNT(*)
        FROM GIAOVIEN
        WHERE LOWER(TRIM(TENGV)) = LOWER(TRIM(@TENGV));

        IF @CountGV < 1
            BEGIN
                print(N'Không tìm thấy giáo viên nào!')
                RETURN 0
            END

        IF @CountGV > 1
            BEGIN
                print CONCAT(N'Có ', @CountGV, N' giáo viên trùng tên!')
            END

        SELECT MSGV, TENGV, SODT
        FROM GIAOVIEN
        WHERE LOWER(TRIM(TENGV)) = LOWER(TRIM(@TENGV));

        RETURN 1
    END
GO

-- 4. Đưa vào MSHD cho biết: Điểm trung bình các đề tài của hội đồng đó.
CREATE PROC usp_GetDiemTrungBinhDeTaiByMSHD
(
    @MSHD int
)
AS
    BEGIN
        DECLARE @DiemTB FLOAT;

        IF NOT EXISTS (SELECT 1 FROM HOIDONG WHERE MSHD = @MSHD)
            BEGIN
                print(N'Mã hội đồng không tồn tại!')
                RETURN 0
            END

        SELECT @DiemTB = CAST(AVG(DIEM) AS DECIMAL(5,2))
        FROM (
                 SELECT DIEM FROM GV_HDDT WHERE MSDT IN (SELECT MSDT FROM HOIDONG_DT WHERE MSHD = @MSHD)
                 UNION ALL
                 SELECT DIEM FROM GV_PBDT WHERE MSDT IN (SELECT MSDT FROM HOIDONG_DT WHERE MSHD = @MSHD)
                 UNION ALL
                 SELECT DIEM FROM GV_UVDT WHERE MSDT IN (SELECT MSDT FROM HOIDONG_DT WHERE MSHD = @MSHD)
             ) AS DiemDeTai;

        IF @DiemTB IS NULL
            SET @DiemTB = 0;

        SELECT @DiemTB AS DiemTrungBinhCuacCacDeTaiCuaHoiDong;
        RETURN 1;
    END
GO


