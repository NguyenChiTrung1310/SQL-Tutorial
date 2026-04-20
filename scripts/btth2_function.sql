USE BTTH2_DB;

-- PHẦN 2:
-- D. FUNCTION
-- 1. Viết hàm tính điểm trung bình của một đề tài. Giá trị trả về là điểm trung
-- bình ứng với mã số đề tài nhập vào.
CREATE FUNCTION fn_AvgDiemDeTai(
    @MSDT char(6)
)
    RETURNS FLOAT
AS
    BEGIN
        DECLARE @DiemTrungBinh FLOAT;

        SELECT @DiemTrungBinh = CAST(AVG(DIEM) AS DECIMAL(5, 2))
        FROM (
            SELECT DIEM FROM GV_HDDT WHERE MSDT = @MSDT
              UNION ALL
              SELECT DIEM FROM GV_PBDT WHERE MSDT = @MSDT
              UNION ALL
              SELECT DIEM FROM GV_UVDT WHERE MSDT = @MSDT
        ) AS TongDiemDT

        RETURN ISNULL(@DiemTrungBinh, 0);
    END
GO

-- 2. Trả về kết quả của đề tài theo MSDT nhập vào. Kết quả là DAT nếu như
-- điểm trung bình từ 5 trở lên, và KHONGDAT nếu như điểm trung bình dưới 5.
CREATE FUNCTION fn_KetQuaDeTai(
    @MSDT char(6)
)
    RETURNS VARCHAR(10)
AS
    BEGIN
        IF dbo.fn_AvgDiemDeTai(@MSDT) >= 5
            RETURN 'DAT';

        RETURN 'KHONGDAT';
    END
GO