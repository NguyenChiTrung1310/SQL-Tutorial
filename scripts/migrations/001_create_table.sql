CREATE TABLE [dbo].[Retail_Sales]
(
    [transactions_id]        INT PRIMARY KEY,
    [sale_date]           DATE,
    [sale_time]           TIME,
    [customer_id]         INT,
    [gender]              VARCHAR(15),
    [age]                 INT,
    [category]              VARCHAR(15),
    [quantity]            INT,
    [price_per_unit]       FLOAT,
    [cogs]                 FLOAT,
    [total_sale]                 FLOAT,
)
GO

SELECT * FROM [dbo].[Retail_Sales]
GO
