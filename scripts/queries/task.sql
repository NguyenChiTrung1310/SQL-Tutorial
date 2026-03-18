USE [Library_System_Management];
GO
-- Project TASK

-- ### 2. CRUD Operations

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

-- Task 2: Update an Existing Member's Address


-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT b.book_title, b.author, i.issued_id, i.issued_book_isbn, i.issued_emp_id
FROM [dbo].[Books] b
JOIN [dbo].[Issued_status] i ON b.isbn = i.issued_book_isbn
WHERE i.issued_emp_id = 'E101'
GO

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.