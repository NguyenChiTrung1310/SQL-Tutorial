USE BTTH2_DB

-- E. CURSOR
-- Tạo một bảng tên là DETAI_DIEM. Cấu trúc bảng như sau:
--     DETAI_DIEM(MSDT, DIEMTB)

-- 1. Viết Cursor tính điểm trung bình cho từng đề tài. Sau đó lưu kết quả vào bảng DETAI_DIEM.
-- 2. Gom các bước xử lý của Cursor ở câu 1 vào một Stored Procedure

CREATE TABLE DETAI_DIEM (
    MSDT CHAR(6) PRIMARY KEY,
    DIEMTB FLOAT
);

CREATE PROCEDURE usp_TinhDiemTB_DeTai
AS
BEGIN
    -- SET NOCOUNT ON giúp tăng hiệu năng bằng cách không gửi thông báo "số dòng bị tác động" về client
    SET NOCOUNT ON;

    -- BƯỚC 1. Chuẩn bị bảng đích (Xóa dữ liệu cũ để tránh trùng lặp Primary Key)
    TRUNCATE TABLE DETAI_DIEM;

    DECLARE @MSDT CHAR(6);
    DECLARE @DiemTB_DeTai FLOAT;

    -- BUƯỚC 2: Khai báo CURSOR lấy danh sách mã đề tài từ bảng DETAI
    DECLARE cur_TinhDiemTB_DeTai CURSOR FOR
        SELECT MSDT FROM DETAI;

    -- BƯỚC 3: Mở CURSOR để bắt đầu làm việc
    OPEN cur_TinhDiemTB_DeTai;

    -- BƯỚC 4: Lấy dòng dữ liệu đầu tiên gán vào biến @MSDT
    FETCH NEXT FROM cur_TinhDiemTB_DeTai INTO @MSDT;
    PRINT N'>> Sau Fetch lần 1, Status = ' + CAST(@@FETCH_STATUS AS NVARCHAR(10));

    -- BƯỚC 5: Kiểm tra xem còn dữ liệu để xử lý tiếp hay không
    WHILE @@FETCH_STATUS = 0
        BEGIN
            -- BƯỚC 6: Thực hiện logic xử lý cho từng dòng
            SET @DiemTB_DeTai = dbo.fn_AvgDiemDeTai(@MSDT);

            INSERT INTO DETAI_DIEM (MSDT, DIEMTB)
            VALUES (@MSDT, @DiemTB_DeTai);

            PRINT N'Đã xử lý xong điểm cho đề tài: ' + @MSDT;

            -- Đọc dòng tiếp theo (QUAN TRỌNG: nếu thiếu dòng này sẽ bị lặp vô tận)
            FETCH NEXT FROM cur_TinhDiemTB_DeTai INTO @MSDT;
            PRINT N'>> Sau Fetch tiếp theo, Status = ' + CAST(@@FETCH_STATUS AS NVARCHAR(10));
        END

    -- BƯỚC 7: Đóng Cursor sau khi hoàn tất vòng lặp
        CLOSE cur_TinhDiemTB_DeTai;

    -- BƯỚC 8: Giải phóng hoàn toàn tài nguyên con trỏ khỏi bộ nhớ
    DEALLOCATE cur_TinhDiemTB_DeTai;
END;
GO

-- 3. Tạo thêm cột XEPLOAI có kiểu là NVARCCHAR(20) trong bảng DETAI_DIEM,
-- viết Cursor cập nhật kết quả xếp loại cho mỗi đề tài như sau:
-- + "Xuất sắc": điểm trung bình từ 9 đến 10.
-- + "Giỏi": điểm trung bình từ 8 đến 9.
-- + "Khá": điểm trung bình từ 7 đến 8.
-- + "Trung bình khá": điểm trung bình từ 6 đến 7.
-- + "Trung bình": điểm trung bình từ 5 đến 6.
-- + "Yếu": điểm trung bình từ 4 đến 5.
-- + "Kém": điểm trung bình dưới 4.
ALTER TABLE DETAI_DIEM
ADD XEPLOAI NVARCHAR(20);

DECLARE @KetQuaXepLoai NVARCHAR(20);
DECLARE @MSDT CHAR(6);
DECLARE @DiemTB_DeTai FLOAT;

DECLARE cur_CapNhatXepLoai CURSOR FOR
    SELECT MSDT, DIEMTB FROM DETAI_DIEM;

OPEN cur_CapNhatXepLoai;

FETCH NEXT FROM cur_CapNhatXepLoai INTO @MSDT, @DiemTB_DeTai;

WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @KetQuaXepLoai = CASE
            WHEN @DiemTB_DeTai >= 9 THEN N'Xuất sắc'
            WHEN @DiemTB_DeTai >= 8 THEN N'Giỏi'
            WHEN @DiemTB_DeTai >= 7 THEN N'Khá'
            WHEN @DiemTB_DeTai >= 6 THEN N'Trung bình khá'
            WHEN @DiemTB_DeTai >= 5 THEN N'Trung bình'
            WHEN @DiemTB_DeTai >= 4 THEN N'Yếu'
            ELSE N'Kém'
        END;

        UPDATE DETAI_DIEM
        SET XEPLOAI = @KetQuaXepLoai
        WHERE MSDT = @MSDT;

        FETCH NEXT FROM cur_CapNhatXepLoai INTO @MSDT, @DiemTB_DeTai;
    END

CLOSE cur_CapNhatXepLoai;

DEALLOCATE  cur_CapNhatXepLoai;
GO

-- THÊM 1 SỐ CÂU HỎI THỰC TẾ DO GEMINI TẠO RA, ĐỂ LUYỆN TẬP THÊM

-- YÊU CẦU 1:
-- a. Thêm cột DANHSACH_SV kiểu NVARCHAR(MAX) vào bảng DETAI_DIEM.
-- b. Viết một Cursor duy trì việc duyệt qua từng đề tài. Với mỗi đề tài, hãy tìm
-- tên của tất cả sinh viên tham gia đề tài đó (từ bảng SINHVIEN và SV_DETAI),
-- nối chúng thành một chuỗi cách nhau bởi dấu phẩy (Ví dụ: "Nguyễn Văn A, Trần Thị B").
-- c. Cập nhật chuỗi này vào cột DANHSACH_SV tương ứng.

ALTER TABLE DETAI_DIEM
ADD DANHSACH_SV NVARCHAR(MAX)

DECLARE @MSDT CHAR(6);
DECLARE @TenSV NVARCHAR(50);
DECLARE @ds_SV NVARCHAR(MAX);

DECLARE cur_DeTai CURSOR FOR
    SELECT MSDT FROM DETAI_DIEM;

OPEN cur_DeTai;

FETCH NEXT FROM cur_DeTai INTO @MSDT;

WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ds_SV = '';

        DECLARE cur_DsSinhVienTheoDeTai CURSOR FOR
            SELECT sv.TENSV
            FROM SINHVIEN sv
            JOIN SV_DETAI svdt ON sv.MSSV = svdt.MSSV
            WHERE svdt.MSDT = @MSDT;

        OPEN cur_DsSinhVienTheoDeTai;

        FETCH NEXT FROM cur_DsSinhVienTheoDeTai into @TenSV;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @ds_SV = ''
                SET @ds_SV = @TenSV
            ELSE
                SET @ds_SV = @ds_SV + ', ' + @TenSV;

            FETCH NEXT FROM cur_DsSinhVienTheoDeTai into @TenSV;
        END

        CLOSE cur_DsSinhVienTheoDeTai;
        DEALLOCATE  cur_DsSinhVienTheoDeTai;

        UPDATE DETAI_DIEM
        SET DANHSACH_SV = @ds_SV
        WHERE MSDT = @MSDT

        FETCH NEXT FROM cur_DeTai INTO @MSDT;
    END

CLOSE cur_DeTai;
DEALLOCATE  cur_DeTai;
GO

-- YÊU CẦU 2:
-- Tạo một bảng tên là NGAN_SACH_DT(MSDT, KINH_PHI).Viết một Cursor duyệt qua danh sách đề tài.
-- Quy tắc cấp kinh phí như sau:
-- + Đề tài có điểm trung bình (lấy từ hàm fn_AvgDiemDeTai) >= 9.0: Cấp 10,000,000 VNĐ.
-- + Đề tài có điểm trung bình từ 7.0 đến dưới 9.0: Cấp 7,000,000 VNĐ.
-- + Đề tài có điểm trung bình từ 5.0 đến dưới 7.0: Cấp 5,000,000 VNĐ.
-- + Các đề tài còn lại: Không cấp kinh phí (ghi 0).
-- + Nếu đề tài đó có Giáo viên hướng dẫn là "Giáo sư" (MSHH = 2), hãy thưởng thêm 2,000,000 VNĐ vào kinh phí của đề tài đó.

CREATE TABLE NGAN_SACH_DT (
    MSDT char(6) PRIMARY KEY,
    KINH_PHI MONEY
)
TRUNCATE TABLE NGAN_SACH_DT;

DECLARE @MSDT CHAR(6);
DECLARE @DiemTB_DeTai FLOAT;
DECLARE @KINH_PHI MONEY;

DECLARE cur_NganSach_DT CURSOR FOR
    SELECT MSDT FROM DETAI;

OPEN cur_NganSach_DT;

FETCH NEXT FROM cur_NganSach_DT INTO @MSDT

WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DiemTB_DeTai = dbo.fn_AvgDiemDeTai (@MSDT);

        SET @KINH_PHI = CASE
            WHEN @DiemTB_DeTai >=9 THEN 10000000
            WHEN @DiemTB_DeTai >=7 THEN 7000000
            WHEN @DiemTB_DeTai >=5 THEN 5000000
            ELSE 0
        END;

        IF EXISTS (
            SELECT 1
            FROM (
                SELECT MSGV FROM GV_UVDT WHERE MSDT = @MSDT
                UNION
                SELECT MSGV FROM GV_PBDT WHERE MSDT = @MSDT
                UNION
                SELECT MSGV FROM GV_HDDT WHERE MSDT = @MSDT
            ) AS GV_DETAI JOIN GIAOVIEN gv ON GV_DETAI.MSGV = gv.MSGV
            WHERE gv.MSHH = 2
        )
        BEGIN
            SET @KINH_PHI = @KINH_PHI + 2000000;
        END

        INSERT INTO NGAN_SACH_DT (MSDT, KINH_PHI) VALUES (@MSDT, @KINH_PHI);

        FETCH NEXT FROM cur_NganSach_DT INTO @MSDT
    END

CLOSE cur_NganSach_DT;
DEALLOCATE cur_NganSach_DT;
GO













