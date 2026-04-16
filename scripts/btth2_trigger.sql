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
