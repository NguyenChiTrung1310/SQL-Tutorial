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
ALTER TABLE GV_HV_CN
ADD CONSTRAINT FK_GV_HV_CN_GIAOVIEN_MSGV
FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV)
ON UPDATE CASCADE;
GO

ALTER TABLE GV_HDDT
ADD CONSTRAINT FK_GV_HDDT_GIAOVIEN_MSGV
FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV)
ON UPDATE CASCADE;
GO

ALTER TABLE GV_PBDT
ADD CONSTRAINT FK_GV_PBDT_GIAOVIEN_MSGV
FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV)
ON UPDATE CASCADE;
GO

ALTER TABLE GV_UVDT
ADD CONSTRAINT FK_GV_UVDT_GIAOVIEN_MSGV
FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV)
ON UPDATE CASCADE;
GO

ALTER TABLE HOIDONG
ADD CONSTRAINT FK_HOIDONG_GIAOVIEN_MSGV
FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV)
ON UPDATE CASCADE;
GO

ALTER TABLE HOIDONG_GV
ADD CONSTRAINT FK_HOIDONG_GV_GIAOVIEN_MSGV
FOREIGN KEY (MSGV) REFERENCES GIAOVIEN(MSGV)
ON UPDATE CASCADE;
GO

CREATE TRIGGER trg_UpdateMSGV
ON GIAOVIEN
FOR UPDATE
AS
    BEGIN
        IF UPDATE(MSGV)
        BEGIN
            UPDATE GV_HV_CN
            SET MSGV = i.MSGV
            FROM GV_HV_CN t JOIN DELETED d ON t.MSGV = d.MSGV
                            JOIN INSERTED i ON 1=1;

            UPDATE GV_HDDT
            SET MSGV = i.MSGV
            FROM GV_HDDT t JOIN DELETED d ON t.MSGV = d.MSGV
                           JOIN INSERTED i ON 1=1;

            UPDATE GV_PBDT
            SET MSGV = i.MSGV
            FROM GV_PBDT t JOIN DELETED d ON t.MSGV = d.MSGV
                           JOIN INSERTED i ON 1=1;

            UPDATE GV_UVDT
            SET MSGV = i.MSGV
            FROM GV_UVDT t JOIN DELETED d ON t.MSGV = d.MSGV
                           JOIN INSERTED i ON 1=1;

            UPDATE HOIDONG
            SET MSGV = i.MSGV
            FROM HOIDONG t JOIN DELETED d ON t.MSGV = d.MSGV
                           JOIN INSERTED i ON 1=1;

            UPDATE HOIDONG_GV
            SET MSGV = i.MSGV
            FROM HOIDONG_GV t JOIN DELETED d ON t.MSGV = d.MSGV
                              JOIN INSERTED i ON 1=1;
        END
    END
GO

-- 3. Tạo Trigger thỏa mãn ràng buộc là một hội đồng không quá 10 đề tài. Dùng
-- “Group by” có được không? Giải thích.
CREATE TRIGGER trg_HoiDongDT_Max10DeTai
ON HOIDONG_DT
FOR INSERT, UPDATE
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
FOR INSERT, UPDATE
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

-- 5. Tạo Trigger thỏa mãn ràng buộc là một giáo viên muốn có học hàm PGS phải là tiến sĩ.
CREATE TRIGGER trg_GiaoVien_PGS_PhaiLaTienSi
ON GIAOVIEN
FOR INSERT, UPDATE
AS
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM INSERTED i
            WHERE i.MSHH = 1
            AND NOT EXISTS (
                SELECT 1
                FROM GV_HV_CN gvhv
                JOIN HOCVI hv ON gvhv.MSHV = hv.MSHV
                WHERE gvhv.MSGV = i.MSGV
                AND hv.TENHV LIKE N'%Tiến sĩ%'
            )
        )
        BEGIN
            RAISERROR(N'Giáo viên muốn có học hàm PGS phải có học vị Tiến sĩ!', 16, 1);
            ROLLBACK TRANSACTION;
        END
    END
GO











