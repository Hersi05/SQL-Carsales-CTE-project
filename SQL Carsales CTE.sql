--- Here are some MySQL Common Table Expressions (CTEs) based on the car sales data

 --- Q1 Top Revenue-Generating Dealers
--- Use a CTE to first calculate total revenue by dealer, then rank them.

WITH Dealer_Revenue AS (
    SELECT Dealer_Name, Dealer_City, 
           SUM(Price) AS Total_Revenue
    FROM carsales
    GROUP BY Dealer_Name, Dealer_City
)
SELECT Dealer_Name, Dealer_City, Total_Revenue,
       RANK() OVER (ORDER BY Total_Revenue DESC) AS Revenue_Rank
FROM Dealer_Revenue
ORDER BY Revenue_Rank
LIMIT 10;

--- Q2 Income Segmentation for Each Car Brand
--- Segment customers into income brackets for each car brand
WITH Income_Segmentation AS (
    SELECT Company, Customer_Name, Annual_Income,
           CASE
               WHEN Annual_Income < 20000 THEN 'Low Income'
               WHEN Annual_Income BETWEEN 20000 AND 75000 THEN 'Middle Income'
               WHEN Annual_Income BETWEEN 75000 AND 150000 THEN 'Upper-Middle Income'
               ELSE 'High Income'
           END AS Income_Bracket
    FROM carsales
)
SELECT Company, Income_Bracket, COUNT(*) AS Customer_Count
FROM Income_Segmentation
GROUP BY Company, Income_Bracket
ORDER BY Company, Customer_Count DESC;


--- Q3 Monthly Sales Growth Rate
--- Calculate the month-over-month growth rate in sales and revenue
WITH Monthly_Sales AS (
    SELECT DATE_FORMAT(Date, '%Y-%m') AS Month,
           COUNT(*) AS Sales_Count,
           SUM(Price) AS Total_Revenue
    FROM carsales
    GROUP BY Month
)
SELECT Month, Sales_Count, Total_Revenue,
       LAG(Sales_Count) OVER (ORDER BY Month) AS Previous_Sales,
       LAG(Total_Revenue) OVER (ORDER BY Month) AS Previous_Revenue,
       ROUND((Sales_Count - LAG(Sales_Count) OVER (ORDER BY Month)) / LAG(Sales_Count) OVER (ORDER BY Month) * 100, 2) AS Sales_Growth_Rate,
       ROUND((Total_Revenue - LAG(Total_Revenue) OVER (ORDER BY Month)) / LAG(Total_Revenue) OVER (ORDER BY Month) * 100, 2) AS Revenue_Growth_Rate
FROM Monthly_Sales;


--- Q4 Top Models Sold in Each City
--- Find the top-selling models in each city
WITH City_Model_Sales AS (
    SELECT Dealer_City, Model, Company,
           COUNT(*) AS Sales_Count,
           RANK() OVER (PARTITION BY Dealer_City ORDER BY COUNT(*) DESC) AS Model_Rank
    FROM carsales
    GROUP BY Dealer_City, Model, Company
)
SELECT Dealer_City, Model, Company, Sales_Count
FROM City_Model_Sales
WHERE Model_Rank = 1
ORDER BY Dealer_City;


--- Q5 Customer Repeat Purchases by Dealer
--- Identify customers who have purchased from the same dealer more than once
WITH Customer_Purchases AS (
    SELECT Dealer_Name, Dealer_City, Customer_Name,
           COUNT(*) AS Purchase_Count
    FROM carsales
    GROUP BY Dealer_Name, Dealer_City, Customer_Name
)
SELECT Dealer_Name, Dealer_City, Customer_Name, Purchase_Count
FROM Customer_Purchases
WHERE Purchase_Count > 1
ORDER BY Purchase_Count DESC;


--- Q6 Average Car Price by Brand and Income Bracket
--- Calculate the average car price each income bracket spends on different brands
WITH Income_Bracket AS (
    SELECT Company, Model, Price,
           CASE
               WHEN Annual_Income < 20000 THEN 'Low Income'
               WHEN Annual_Income BETWEEN 20000 AND 75000 THEN 'Middle Income'
               WHEN Annual_Income BETWEEN 75000 AND 150000 THEN 'Upper-Middle Income'
               ELSE 'High Income'
           END AS Income_Bracket
    FROM carsales
)
SELECT Company, Income_Bracket, round(AVG(Price), 2) AS Average_Price
FROM Income_Bracket
GROUP BY Company, Income_Bracket
ORDER BY Company, Income_Bracket;


--- Q7 Most Expensive Sales by Model, Filtered by Top 10% Prices
--- Isolate the top 10% of highest-priced car sales for each model
WITH Price_Ranked AS (
    SELECT Company, Model, Price,
           NTILE(10) OVER (PARTITION BY Model ORDER BY Price DESC) AS Price_Tier
    FROM carsales
)
SELECT Company, Model, Price
FROM Price_Ranked
WHERE Price_Tier = 1
ORDER BY Price DESC;







