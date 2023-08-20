-- Average order value
SELECT AVG(Quantity * Price) AS AvgOrderValue
FROM `your-project.sales_dataset.sales_data`;

-- Monthly sales trends
SELECT EXTRACT(MONTH FROM Date) AS Month,
       SUM(Quantity * Price) AS MonthlySales
FROM `your-project.sales_dataset.sales_data`
GROUP BY Month
ORDER BY Month;

-- Top customers by spending
SELECT Customer, SUM(Quantity * Price) AS TotalSpending
FROM `your-project.sales_dataset.sales_data`
GROUP BY Customer
ORDER BY TotalSpending DESC
LIMIT 10;

-- Sales distribution by product category
SELECT Category, SUM(Quantity * Price) AS TotalSales
FROM `your-project.sales_dataset.sales_data`
GROUP BY Category
ORDER BY TotalSales DESC;

-- Revenue by year and quarter
SELECT EXTRACT(YEAR FROM Date) AS Year,
       EXTRACT(QUARTER FROM Date) AS Quarter,
       SUM(Quantity * Price) AS QuarterlyRevenue
FROM `your-project.sales_dataset.sales_data`
GROUP BY Year, Quarter
ORDER BY Year, Quarter;

-- Average items per order
SELECT AVG(Quantity) AS AvgItemsPerOrder
FROM `your-project.sales_dataset.sales_data`;

-- Customer loyalty analysis
WITH CustomerPurchases AS (
  SELECT Customer, COUNT(DISTINCT OrderID) AS NumOrders
  FROM `your-project.sales_dataset.sales_data`
  GROUP BY Customer
)
SELECT CASE
         WHEN NumOrders = 1 THEN 'New'
         WHEN NumOrders <= 3 THEN 'Regular'
         ELSE 'Loyal'
       END AS CustomerType,
       COUNT(*) AS Count
FROM CustomerPurchases
GROUP BY CustomerType;

-- Monthly growth rate
SELECT Month,
       (SUM(Quantity * Price) - LAG(SUM(Quantity * Price)) OVER (ORDER BY Month)) /
       LAG(SUM(Quantity * Price)) OVER (ORDER BY Month) * 100 AS MonthlyGrowthRate
FROM (
  SELECT EXTRACT(YEAR_MONTH FROM Date) AS Month,
         SUM(Quantity * Price) AS MonthlySales
  FROM `your-project.sales_dataset.sales_data`
  GROUP BY Month
)
ORDER BY Month;

-- Average purchase frequency
SELECT AVG(DaysBetweenOrders) AS AvgPurchaseFrequency
FROM (
  SELECT Customer,
         DATE_DIFF(MIN(Date), LAG(Date) OVER (PARTITION BY Customer ORDER BY Date), DAY) AS DaysBetweenOrders
  FROM `your-project.sales_dataset.sales_data`
  GROUP BY Customer, Date
)
WHERE DaysBetweenOrders IS NOT NULL;

-- Churn rate analysis
WITH CustomerLastOrder AS (
  SELECT Customer, MAX(Date) AS LastOrderDate
  FROM `your-project.sales_dataset.sales_data`
  GROUP BY Customer
)
SELECT CASE
         WHEN DATE_DIFF(CURRENT_DATE(), LastOrderDate, DAY) <= 30 THEN 'Active'
         WHEN DATE_DIFF(CURRENT_DATE(), LastOrderDate, DAY) <= 60 THEN 'Churning'
         ELSE 'Churned'
       END AS ChurnStatus,
       COUNT(*) AS Count
FROM CustomerLastOrder
GROUP BY ChurnStatus;
