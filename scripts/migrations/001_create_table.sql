CREATE TABLE [dbo].[Branch]
(
    [branch_id] VARCHAR(10) PRIMARY KEY,
    [manager_id] VARCHAR(10),
    [branch_address] VARCHAR(30),
    [contact_no] VARCHAR(15)
)
GO

CREATE TABLE [dbo].[Employees]
(
    [emp_id] VARCHAR(10) PRIMARY KEY,
    [emp_name] VARCHAR(30),
    [position] VARCHAR(30),
    [salary] DECIMAL(10, 2),
    [branch_id] VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES [dbo].[Branch](branch_id)
)
GO

CREATE TABLE [dbo].[Books]
(
    [isbn] VARCHAR(50) PRIMARY KEY,
    [book_title] VARCHAR(80),
    [category] VARCHAR(30),
    [rental_price] DECIMAL(10, 2),
    [status] VARCHAR(10),
    [author] VARCHAR(30),  
    [publisher] VARCHAR(30)
)
GO