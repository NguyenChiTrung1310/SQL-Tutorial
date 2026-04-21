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