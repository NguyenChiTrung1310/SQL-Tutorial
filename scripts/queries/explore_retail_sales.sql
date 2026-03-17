USE [Project1_Aspiring_Data_Analysts];
GO

SELECT COUNT(DISTINCT category) FROM [dbo].[Retail_Sales]
GO

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT * FROM [dbo].[Retail_Sales]
WHERE sale_date = '2022-11-05'
GO

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
SELECT * FROM [dbo].[Retail_Sales]
WHERE category = 'Clothing'
AND quantity = 2
AND sale_date < '2022-12-01' AND sale_date >= '2022-11-01'
GO

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT category, SUM(total_sale) AS Total_Sales
FROM [dbo].[Retail_Sales]
GROUP BY category
GO

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT category, AVG(age) as average_age
FROM [dbo].[Retail_Sales]
WHERE category = 'Beauty'
GROUP BY category
GO

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM [dbo].[Retail_Sales]
WHERE total_sale >= 1000
GO

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT category, gender, COUNT(transactions_id) AS total_transactions
FROM [dbo].[Retail_Sales]
GROUP BY category, gender
GO

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT year, month, avg_sale 
FROM (
SELECT
    YEAR(sale_date) as year,
    MONTH(sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM [dbo].[Retail_Sales]
GROUP BY YEAR(sale_date), MONTH(sale_date)
) as t1
WHERE rank = 1
ORDER BY year, avg_sale DESC

/* Hướng tư duy giải Q.7
Đọc đề và xác định Output mong muốn
"Tính doanh thu trung bình theo từng tháng. Tìm tháng bán chạy nhất trong mỗi năm."

Output cần có: year | month | avg_sale — chỉ lấy 1 tháng tốt nhất mỗi năm.

* Bước 1 — Tách bài toán thành 2 phần nhỏ

  Bài toán lớn
  ├── Phần 1: Tính avg_sale theo từng tháng/năm  ← đơn giản
  └── Phần 2: Tìm tháng cao nhất trong mỗi năm  ← phức tạp hơn
Khi bài toán có 2 bước như vậy → nghĩ ngay đến subquery hoặc CTE.

* Bước 2 — Giải Phần 1 trước (đơn giản)
Câu hỏi: "Làm sao nhóm dữ liệu theo tháng và năm?"

<code> //////////////////
GROUP BY YEAR(sale_date), MONTH(sale_date)
<code> //////////////////

Câu hỏi: "Tính gì trong mỗi nhóm?"

<code> //////////////////
AVG(total_sale)
<code> //////////////////

→ Phần 1 xong, có bảng kết quả trung gian với year, month, avg_sale.

* Bước 3 — Giải Phần 2: "Tốt nhất trong mỗi năm"
Đây là từ khóa quan trọng: "trong mỗi năm" → gợi ý cần so sánh trong phạm vi từng năm, không phải toàn bộ bảng.

Có 2 cách tiếp cận:

Cách A — Window Function RANK() (dùng khi cần thứ hạng)

Suy nghĩ: "Tôi cần xếp hạng các tháng, nhưng reset thứ hạng theo từng năm"
→ PARTITION BY year (reset theo năm) + ORDER BY avg_sale DESC (cao nhất = rank 1)
→ Lọc WHERE rank = 1
Cách B — Subquery với MAX() (đơn giản hơn)

Suy nghĩ: "Tôi chỉ cần lấy tháng có avg_sale = max của năm đó"
→ WHERE avg_sale = (SELECT MAX(avg_sale) ... WHERE year = năm đó)
Bước 4 — Chọn cách nào?
RANK()	MAX() Subquery
Khi có tie (2 tháng bằng nhau)	Lấy cả 2	Lấy cả 2
Code dễ mở rộng (top 3 tháng?)	Chỉ đổi rank <= 3	Phức tạp hơn
Performance	Tốt hơn với data lớn	Kém hơn
→ RANK() là lựa chọn tốt hơn cho bài toán dạng "top N trong mỗi nhóm".

Tóm tắt quy trình tư duy

1. Xác định output cuối cùng cần gì
2. Chia bài toán thành các bước nhỏ
3. Nhận diện từ khóa: 
   - "theo từng nhóm" → GROUP BY
   - "trong mỗi [X]" → PARTITION BY
   - "tốt nhất / top N" → RANK() + filter`
4. Giải từng bước, bước sau dùng kết quả bước trước (subquery/CTE)
*/

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT TOP 5 customer_id, SUM(total_sale) AS total_sales
FROM [dbo].[Retail_Sales]
GROUP BY customer_id
ORDER BY total_sales DESC
GO

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM [dbo].[Retail_Sales]
GROUP BY category
ORDER BY unique_customers DESC
GO

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
WITH Shift_Calculation AS (
SELECT 
    *,
    CASE 
        WHEN sale_time < '12:00:00' THEN 'Morning'
        WHEN sale_time >= '12:00:00' AND sale_time < '17:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
FROM [dbo].[Retail_Sales]
)

SELECT shift, COUNT(transactions_id) AS number_of_orders
FROM Shift_Calculation
GROUP BY shift
GO