USE [Library_System_Management];
GO

-- ============================================================
-- BUOI LUYEN TAP XEN KE SQL - Library System Management
-- Phuong phap: Interleaved Practice
-- Thoi gian: 30-45 phut
-- Schema: Branch | Employees | Books
-- ============================================================

-- ============================================================
-- WARM-UP (5 phut) - Bai 1-3
-- ============================================================

-- Bai 1 | WHERE + ORDER BY
-- Liet ke tat ca sach thuoc the loai 'Classic',
-- sap xep theo gia thue tang dan.
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]
SELECT * FROM Books
WHERE category = 'Classic'
ORDER BY rental_price ASC
-- DAP AN:
-- SELECT book_title, author, rental_price
-- FROM Books]
-- WHERE category = 'Classic'
-- ORDER BY rental_price ASC;
GO

-- Bai 2 | GROUP BY + COUNT
-- Dem so luong sach theo tung the loai.
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]
SELECT category, COUNT(*) AS total_books
FROM Books
GROUP BY category

-- DAP AN:
-- SELECT category, COUNT(*) AS total_books
-- FROM Books]
-- GROUP BY category
-- ORDER BY total_books DESC;
GO

-- Bai 3 | INNER JOIN
-- Hien thi ten nhan vien va dia chi chi nhanh ho lam viec.
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]
SELECT e.emp_name, b.branch_address
FROM Employees e INNER JOIN Branch b ON e.branch_id = b.branch_id;
-- DAP AN:
-- SELECT e.emp_name, e.position, b.branch_address
-- FROM Employees] e
-- INNER JOIN Branch] b ON e.branch_id = b.branch_id;
GO

-- ============================================================
-- CORE - Xen ke cac khai niem (20-25 phut) - Bai 4-11
-- ============================================================

-- Bai 4 | GROUP BY + HAVING
-- Tim cac chi nhanh co hon 2 nhan vien.
-- Goi y: can JOIN Employees vao Branch, sau do dung HAVING
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]
SELECT b.branch_id, b.branch_address, COUNT(e.emp_id) AS total_employees
FROM Branch b JOIN Employees e ON b.branch_id = e.branch_id
GROUP BY b.branch_id, b.branch_address
HAVING COUNT(e.emp_id) > 2

-- DAP AN:
-- SELECT b.branch_id, b.branch_address, COUNT(e.emp_id) AS total_employees
-- FROM Branch] b
-- INNER JOIN Employees] e ON b.branch_id = e.branch_id
-- GROUP BY b.branch_id, b.branch_address
-- HAVING COUNT(e.emp_id) > 2;
GO

-- Bai 5 | Subquery
-- Tim nhan vien co luong cao hon muc luong trung binh cua toan cong ty.
-- Goi y: tinh AVG(salary) trong subquery roi dung voi WHERE
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]
SELECT emp_name, salary
FROM Employees
WHERE salary > (SELECT AVG(salary) FROM Employees)

-- DAP AN:
-- SELECT emp_name, position, salary
-- FROM Employees]
-- WHERE salary > (SELECT AVG(salary) FROM Employees])
-- ORDER BY salary DESC;
GO

-- Bai 6 | JOIN + Aggregate
-- Tinh tong luong va luong trung binh theo tung chi nhanh,
-- kem ten dia chi chi nhanh.
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]
SELECT b.branch_address, SUM(e.salary) AS total_salary, AVG(e.salary) AS avg_salary
FROM Branch b JOIN Employees E on b.branch_id = e.branch_id
GROUP BY b.branch_address
-- DAP AN:
-- SELECT b.branch_address, SUM(e.salary) AS total_salary, AVG(e.salary) AS avg_salary
-- FROM Branch] b
-- INNER JOIN Employees] e ON b.branch_id = e.branch_id
-- GROUP BY b.branch_id, b.branch_address
-- ORDER BY total_salary DESC;
GO

-- Bai 7 | WHERE + Subquery long nhau
-- Liet ke cac sach co gia thue cao hon gia thue trung binh
-- cua the loai 'History'.
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]
WITH HistoryAvg AS (
  SELECT AVG(rental_price) AS avg_price
  FROM Books
  WHERE category = 'HISTORY'
)

SELECT book_title, category, rental_price, (SELECT avg_price FROM HistoryAvg) AS avg_history_price
FROM Books
WHERE category = 'HISTORY' AND rental_price > (SELECT avg_price FROM HistoryAvg)
GROUP BY book_title, category, rental_price

-- DAP AN:
-- SELECT book_title, category, rental_price
-- FROM Books]
-- WHERE rental_price > (
--     SELECT AVG(rental_price)
--     FROM Books]
--     WHERE category = 'History'
-- )
-- ORDER BY rental_price DESC;
GO

-- Bai 8 | CASE WHEN
-- Phan loai nhan vien theo muc luong:
--   'Low'  = duoi 45,000
--   'Mid'  = tu 45,000 den 60,000
--   'High' = tren 60,000
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]
SELECT emp_name, salary,
CASE
  WHEN salary < 45000 THEN 'Low'
  WHEN salary BETWEEN 45000 AND 60000 THEN 'Mid'
  ELSE 'High'
END AS salary_level
FROM Employees

-- DAP AN:
-- SELECT emp_name, salary,
--     CASE
--         WHEN salary < 45000 THEN 'Low'
--         WHEN salary BETWEEN 45000 AND 60000 THEN 'Mid'
--         ELSE 'High'
--     END AS salary_level
-- FROM Employees]
-- ORDER BY salary DESC;
GO

-- Bai 9 | GROUP BY + HAVING + WHERE
-- Tim the loai sach co hon 3 cuon dang san sang cho thue (status = 'yes').
-- Goi y: WHERE truoc, GROUP BY sau, roi HAVING
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]

-- DAP AN:
-- SELECT category, COUNT(*) AS available_books
-- FROM Books]
-- WHERE status = 'yes'
-- GROUP BY category
-- HAVING COUNT(*) > 3
-- ORDER BY available_books DESC;
GO

-- Bai 10 | LEFT JOIN
-- Hien thi TAT CA chi nhanh ke ca chi nhanh khong co nhan vien nao.
-- Goi y: khac Bai 3 - dung LEFT JOIN thay vi INNER JOIN
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]

-- DAP AN:
-- SELECT b.branch_id, b.branch_address, COUNT(e.emp_id) AS employee_count
-- FROM Branch] b
-- LEFT JOIN Employees] e ON b.branch_id = e.branch_id
-- GROUP BY b.branch_id, b.branch_address
-- ORDER BY employee_count DESC;
GO

-- Bai 11 | Subquery trong FROM (Derived Table)
-- Tinh luong trung binh theo tung chuc vu,
-- sau do chi lay nhung chuc vu co luong trung binh > 50,000.
-- Goi y: khong dung HAVING duoc - phai boc vao subquery
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]

-- DAP AN:
-- SELECT position, avg_salary
-- FROM (
--     SELECT position, AVG(salary) AS avg_salary
--     FROM Employees]
--     GROUP BY position
-- ) AS salary_summary
-- WHERE avg_salary > 50000
-- ORDER BY avg_salary DESC;
GO

-- ============================================================
-- CHALLENGE (8-10 phut) - Bai 12-15
-- ============================================================

-- Bai 12 | Window Function: RANK()
-- Xep hang nhan vien theo luong trong tung chi nhanh
-- (luong cao nhat = rank 1).
-- Goi y: RANK() OVER(PARTITION BY ... ORDER BY ...)
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]

-- DAP AN:
-- SELECT emp_name, branch_id, salary,
--     RANK() OVER(PARTITION BY branch_id ORDER BY salary DESC) AS salary_rank
-- FROM Employees]
-- ORDER BY branch_id, salary_rank;
GO

-- Bai 13 | CTE
-- Dung CTE de tim nhan vien co luong cao nhat o moi chi nhanh.
-- Goi y: WITH ... AS (...) -> SELECT WHERE rnk = 1
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]

-- DAP AN:
-- WITH RankedEmployees AS (
--     SELECT emp_name, branch_id, salary, position,
--         RANK() OVER(PARTITION BY branch_id ORDER BY salary DESC) AS rnk
--     FROM Employees]
-- )
-- SELECT emp_name, branch_id, salary, position
-- FROM RankedEmployees
-- WHERE rnk = 1
-- ORDER BY branch_id;
GO

-- Bai 14 | CASE WHEN + GROUP BY
-- Thong ke so luong sach theo nhom gia:
--   'Budget'   = <= 5.00
--   'Standard' = 5.01 - 7.50
--   'Premium'  = > 7.50
-- Kem so luong va gia trung binh moi nhom.
-- Goi y: dung CASE WHEN ca trong SELECT lan GROUP BY
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]

-- DAP AN:
-- SELECT
--     CASE
--         WHEN rental_price <= 5.00 THEN 'Budget'
--         WHEN rental_price <= 7.50 THEN 'Standard'
--         ELSE 'Premium'
--     END AS price_tier,
--     COUNT(*) AS total_books,
--     AVG(rental_price) AS avg_price
-- FROM Books]
-- GROUP BY
--     CASE
--         WHEN rental_price <= 5.00 THEN 'Budget'
--         WHEN rental_price <= 7.50 THEN 'Standard'
--         ELSE 'Premium'
--     END
-- ORDER BY avg_price;
GO

-- Bai 15 | CTE + JOIN (Boss level - tong hop tat ca)
-- Tim tat ca chi nhanh kem tong luong nhan vien va ten quan ly.
-- Goi y: CTE tinh tong luong -> JOIN voi Branch -> JOIN voi Employees (lay manager)
-- ------------------------------------------------------------
-- [VIET QUERY O DAY]

-- DAP AN:
-- WITH BranchSalary AS (
--     SELECT branch_id, SUM(salary) AS total_salary
--     FROM Employees]
--     GROUP BY branch_id
-- )
-- SELECT b.branch_address, bs.total_salary, e.emp_name AS manager_name
-- FROM BranchSalary bs
-- INNER JOIN Branch] b ON bs.branch_id = b.branch_id
-- INNER JOIN Employees] e ON b.manager_id = e.emp_id
-- ORDER BY bs.total_salary DESC;
GO

-- ============================================================
-- QUY TRINH SUA LOI (Error Correction Procedure)
-- ============================================================
--
-- Buoc 1 - Doc thong bao loi:
--   "Invalid column name"          -> Sai ten cot hoac chua dat alias dung
--   "Invalid object name"          -> Sai ten bang, chua USE dung database
--   "not recognized built-in"      -> Dung ham MySQL/PostgreSQL (EXTRACT, LIMIT...)
--   "Column is invalid in select"  -> Cot trong SELECT phai co trong GROUP BY
--   "Ambiguous column name"        -> 2 bang co cung ten cot, them prefix table.column
--   "Conversion failed"            -> Ep kieu sai (VD: CAST VARCHAR sang INT)
--
-- Buoc 2 - Kiem tra cau truc:
--   1. USE dung database chua?
--   2. Ten bang/cot co khop schema khong?
--   3. Moi cot trong SELECT co trong GROUP BY khong? (tru aggregate)
--   4. JOIN ON dung cot noi khong?
--   5. Subquery co tra ve dung 1 gia tri khi dung voi = khong?
--
-- Buoc 3 - Debug tung phan:
--   Cat query thanh tung phan nho, chay rieng de xac dinh doan loi.
--   Vi du: chay subquery doc lap truoc, sau do ghep vao query chinh.
--
-- Buoc 4 - SQL Server vs MySQL/PostgreSQL:
--   EXTRACT(YEAR FROM col)  ->  YEAR(col)
--   LIMIT n                 ->  TOP n
--   IFNULL(a, b)            ->  ISNULL(a, b)
--   GROUP BY 1, 2           ->  GROUP BY column_name
--   NOW()                   ->  GETDATE()
-- ============================================================
