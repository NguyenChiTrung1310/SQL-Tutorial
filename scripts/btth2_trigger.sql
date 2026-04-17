USE BTTH2_DB;

-- PHẦN 2:
-- C. TRIGGER
-- 1. Tạo Trigger thỏa mãn điều kiện khi xóa một đề tài sẽ xóa các thông tin liên quan.
CREATE TRIGGER trg_DeleteDeTai
ON DETAI
INSTEAD OF DELETE
AS
    BEGIN
        DELETE FROM SV_DETAI WHERE MSDT IN (SELECT MSDT FROM DELETED);
        DELETE FROM GV_HDDT WHERE MSDT IN (SELECT MSDT FROM DELETED);
        DELETE FROM GV_PBDT WHERE MSDT IN (SELECT MSDT FROM DELETED);
        DELETE FROM GV_UVDT WHERE MSDT IN (SELECT MSDT FROM DELETED);
        DELETE FROM HOIDONG_DT WHERE MSDT IN (SELECT MSDT FROM DELETED);

        DELETE FROM DETAI WHERE MSDT IN (SELECT MSDT FROM DELETED);
    END
GO

-- 2. Khi đổi MSGV thì cập nhật các bảng liên quan
CREATE TRIGGER trg_UpdateMSGV
ON GIAOVIEN
INSTEAD OF UPDATE
AS
    BEGIN
        IF UPDATE(MSGV)
        BEGIN
            DECLARE @OldMSGV INT, @NewMSGV INT;

            SELECT @OldMSGV = MSGV FROM DELETED;
            SELECT @NewMSGV = MSGV FROM INSERTED;

            -- 1) Tạo bản ghi giáo viên mới trước để FK ở bảng con hợp lệ
            INSERT INTO GIAOVIEN (MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH)
            SELECT MSGV, TENGV, DIACHI, SODT, MSHH, NAMHH
            FROM INSERTED;

            -- 2) Đổi MSGV ở các bảng con từ old -> new
            UPDATE GV_HV_CN SET MSGV = @NewMSGV WHERE MSGV = @OldMSGV;
            UPDATE GV_HDDT SET MSGV = @NewMSGV WHERE MSGV = @OldMSGV;
            UPDATE GV_PBDT SET MSGV = @NewMSGV WHERE MSGV = @OldMSGV;
            UPDATE GV_UVDT SET MSGV = @NewMSGV WHERE MSGV = @OldMSGV;
            UPDATE HOIDONG SET MSGV = @NewMSGV WHERE MSGV = @OldMSGV;
            UPDATE HOIDONG_GV SET MSGV = @NewMSGV WHERE MSGV = @OldMSGV;

            -- 3) Xóa bản ghi giáo viên cũ
            DELETE FROM GIAOVIEN WHERE MSGV = @OldMSGV;
        END
    END
GO

-- 3. Tạo Trigger thỏa mãn ràng buộc là một hội đồng không quá 10 đề tài. Dùng
-- “Group by” có được không? Giải thích.
CREATE TRIGGER trg_HoiDongDT_Max10DeTai
ON HOIDONG_DT
FOR INSERT
AS
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM HOIDONG_DT
            WHERE MSHD IN (SELECT DISTINCT MSHD FROM INSERTED)
            GROUP BY MSHD
            HAVING COUNT(MSDT) > 10
        )
            BEGIN
                RAISERROR(N'Lỗi: Một hội đồng không được quản lý quá 10 đề tài!', 16, 1);
                ROLLBACK TRANSACTION;
            END
    END
GO

-- 4. Tạo Trigger thỏa mãn ràng buộc là một đề tài không quá 2 sinh viên. Dùng
-- “Group by” có được không? Giải thích.
CREATE TRIGGER trg_SVDeTai_Max2SV
ON SV_DETAI
FOR INSERT
AS
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM SV_DETAI
            WHERE MSDT IN (SELECT DISTINCT MSDT FROM INSERTED)
            GROUP BY MSDT
            HAVING COUNT(MSSV) > 2
        )
        BEGIN
            RAISERROR(N'Lỗi: Một đề tài không quá 2 sinh viên!', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
GO