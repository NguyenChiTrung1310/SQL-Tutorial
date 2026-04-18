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

SELECT sv.MSSV, sv.TENSV, dbo.fn_AvgDiemDeTai(svdt.MSDT) AS DiemTrungBinhDeTai
FROM SV_DETAI svdt JOIN SINHVIEN sv ON svdt.MSSV = sv.MSSV;