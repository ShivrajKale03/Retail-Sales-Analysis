-- Use Proper Database
use retailproj;

show tables;

select * from retail;


select count(*) from retail;

/* Basic Analysis */
-- Q1 Find the total revenue (sum of Quantity * UnitPrice) generated from
-- all invoices
SELECT 
	round(sum(Quantity*UnitPrice), 2) as Total_Revenue
FROM 
	retail;
    
-- Q2 Count the number of unique products (StockCode) sold.
SELECT 
	count(distinct Stockcode) as Unique_Product
FROM 
	retail;
    
-- Q3 Identify the total number of invoices in the dataset.
SELECT 
	count(distinct InvoiceNo) as Total_Invoice
FROM
	retail;

-- Q4 Find the total quantity of products sold for each StockCode and sort
-- them in descending order.
SELECT 
	StockCode,
	SUM(Quantity) as Total_Quantity
FROM
	retail
GROUP BY StockCode
ORDER BY Total_Quantity DESC;

-- Q5 Count the number of transactions (distinct InvoiceNo) per customer
-- (CustomerID)
SELECT 
	CustomerID,
    count(DISTINCT InvoiceNo) as Total_Transaction
FROM
	retail
GROUP BY CustomerID
ORDER BY Total_Transaction DESC;

/* Customer Analysis */
-- Q1 Identify the top 5 customers who have generated the highest revenue.
SELECT 
	CustomerID,
    round(sum(Quantity*UnitPrice), 2) as Revenue
FROM 
	retail
group by CustomerID
order by Revenue desc
limit 5;
	
-- Q2. Find the average number of products purchased per customer.
SELECT 
	CustomerID,
    round(avg(Quantity)) as Avg_QTY
FROM 
	retail
GROUP BY CustomerID
ORDER BY Avg_QTY DESC;

-- Q3. Retrieve all transactions made by the customer who has purchased the
-- most products in total.
SELECT 
	CustomerID,
    sum(Quantity) as Total_Quantity
from 
	retail
group by CustomerID
order by Total_Quantity desc
limit 1;

SELECT * FROM retail
WHERE CustomerID = (
		select CustomerID
        from retail
        group by CustomerID
        order by sum(Quantity) desc
        limit 1
);

-- Q4. Identify the country with the highest number of unique customers.
select 
	Country,
    count(distinct CustomerId) as Total_Customer
from retail
group by Country
order by Total_Customer desc
limit 1;

-- Q5. Find the customer who made the maximum number of transactions.
select 
	CustomerID,
    count(distinct InvoiceNo) as Total_Transaction
from
	retail
group by  CustomerID 
order by  Total_Transaction desc
limit 1;
    
/* Product Based Analysis */
-- Q1. List the top 5 most frequently purchased products (based on total
-- quantity sold).
select 
	Stockcode,
	sum(Quantity) as Total_qty
from 
	retail
group by Stockcode
order by Total_qty desc
limit 5;

-- Q2. Find the product that generated the highest revenue
select 
	StockCode,
    round(sum(Quantity*UnitPrice), 2) as Total_Revenue
from 
	retail
group by StockCode
order by Total_Revenue desc;

-- Q3. Identify products that have been sold in exactly 10 or more different
-- invoices.
select 
	StockCode,
    count(distinct InvoiceNo) as Transactions
from 
	retail
group by StockCode
Having Transactions >= 10
order by Transactions;

-- Q4. Count how many times each product has been sold and list those that
-- have been purchased more than 5 times.
select 
	StockCode,
    count(distinct InvoiceNo) as Transactions
from retail
group by StockCode
having Transactions > 5
order by Transactions;

-- Q5. Retrieve all distinct product descriptions purchased by a specific
-- customer (CustomerID = 17850).
select 
	distinct description,
    CustomerID
from retail
where CustomerID = 17850;

-- Q5A. Retrieve all distinct product descriptions purchased by a specific
-- customer (CustomerID = 17850) do not show returned descriptions
Select
	distinct Description,
    CustomerID,
    Quantity
from retail
where CustomerID = 17850 and Quantity > 0;

/*  Time-Based Analysis */
-- Q1. Find the total revenue generated per month.
select 
	 date_format(InvoiceDate, "%Y-%m") as Invoice_Month,
     round(sum(Quantity * UnitPrice), 2) as Total_Revenue
from 
	retail
group by Invoice_Month
order by Invoice_Month;

select 
	year(InvoiceDate) as Invoice_Year,
    date_format(InvoiceDate, "%M") as Invoice_Month,
	round(sum(Quantity * UnitPrice), 2) as Total_Revenue
from retail
group by Invoice_Year, Invoice_Month
order By Invoice_Year;

-- Q2. Identify the hour of the day when the highest number of transactions
-- occurred.
Select
	hour(InvoiceDate) as Invoice_hour,
    count(distinct InvoiceNo) as Transactions
from retail
group by Invoice_hour
order by Transactions desc
limit 1;

-- EXTRA - Show the hour of the day where most transactions occured each day
WITH hour_date_trns AS (
		SELECT
			DATE(InvoiceDate) AS invoice_date,
            HOUR(InvoiceDate) AS Invoice_Hour,
            COUNT(DISTINCT InvoiceNo) AS Transactions,
            DENSE_RANK() OVER(
				PARTITION BY DATE(InvoiceDate)
                ORDER BY  COUNT(DISTINCT InvoiceNo) DESC
                ) AS RNK
		FROM retail
        GROUP BY invoice_date, Invoice_Hour
)
SELECT * FROM hour_date_trns
WHERE RNK = 1; 

-- Q3. Count the number of invoices generated per day.
select 
	date(InvoiceDate) as Invoice_date,
	count(distinct InvoiceNo) as Transactions
from retail
group by Invoice_date
order by Transactions desc;

-- Q4. Identify the date when the highest number of products were sold.
SELECT 
	DATE(InvoiceDate) AS Invoice_Date,
    SUM(Quantity) AS Total_Quantity
FROM retail
GROUP BY Invoice_Date
ORDER BY Total_Quantity DESC
LIMIT 1;

-- Q5. Find the number of transactions that happened before 12 PM vs. after
-- 12PM
SELECT 
	'Before 12 PM ' AS Time_Period,
    COUNT(DISTINCT InvoiceNo) AS Transactions
FROM retail
WHERE HOUR(InvoiceDate) < 12
UNION
SELECT 
	'After 12 PM ' AS Time_Period,
    COUNT(DISTINCT InvoiceNo) AS Transactions
FROM retail
WHERE HOUR(InvoiceDate) >= 12;

/* EXTRA - Show top 3 customer by Total revenuefro each month */
WITH Top_Cust_Month AS (
	SELECT 
		DATE_FORMAT(InvoiceDate, '%Y-%m') AS inv_month,
        CustomerID,
        ROUND(SUM(Quantity * UnitPrice), 2) AS Total_Revenue,
        DENSE_RANK() OVER(
			PARTITION BY DATE_FORMAT(InvoiceDate, '%Y-%m')
            ORDER BY  SUM(Quantity * UnitPrice) DESC
        ) AS RNK
	FROM retail
    GROUP BY inv_month, CustomerID
)
SELECT * FROM Top_Cust_Month
WHERE RNK <= 3;

