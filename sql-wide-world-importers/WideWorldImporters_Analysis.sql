/* =====================================================================
   Wide World Importers: revenue, customers and churn risk
   Author:   Kristin Labsker
   Database: WideWorldImporters (Microsoft SQL Server sample database)
   Tools:    T-SQL, CTEs, window functions, ROLLUP, PIVOT, STRING_AGG
   ===================================================================== */

/* Question 1: Yearly revenue, annualized by active months, and year-over-year growth rate */
----------------------------------------

GO

WITH tab1 
AS
(SELECT YEAR(si.InvoiceDate) AS "Invoice Year"
      ,SUM(ol.UnitPrice * ol.Quantity) AS IncomePerYear
      ,COUNT(DISTINCT MONTH(si.InvoiceDate)) AS NumberOfDistinctMonth
FROM sales.Invoices si JOIN sales.OrderLines ol
ON si.OrderID= ol.OrderID
GROUP BY YEAR(si.InvoiceDate)
),
tab2
AS
(SELECT tab1.*
      ,(IncomePerYear/NumberOfDistinctMonth)*12 AS YearlyLinearIncome
FROM tab1 ),
tab3
AS
(SELECT tab2.*
             ,LAG(YearlyLinearIncome,1)OVER(ORDER BY tab2.[Invoice Year]) AS ShortL
FROM tab2 
)
SELECT [Invoice Year]
      ,FORMAT(IncomePerYear,'#,#.00') AS IncomePerYear
      ,FORMAT(NumberOfDistinctMonth,'#,#.00')AS NumberOfDistinctMonth
      ,CAST((YearlyLinearIncome- ShortL)/ShortL*100 AS NUMERIC(3,2))AS GrowthRate
from tab3



/* Question 2: Top 5 customers by revenue in every quarter */
----------------------------------------

GO

WITH tbl
AS
(SELECT YEAR(si.InvoiceDate) AS TheYear
       ,DATEPART(Q,si.InvoiceDate) AS TheQuarter
       ,sc.CustomerName
       ,SUM(ol.UnitPrice * ol.Quantity) AS IncomePerYear
FROM sales.Customers sc JOIN sales.Invoices si
ON sc.CustomerID = si.CustomerID
JOIN sales.OrderLines ol
ON ol.OrderID = si.OrderID
GROUP BY YEAR(si.InvoiceDate) 
        ,DATEPART(Q,si.InvoiceDate) 
        ,sc.CustomerName),
tbl2
AS
(SELECT*
       ,DENSE_RANK()OVER(PARTITION BY TheYear,TheQuarter ORDER BY IncomePerYear DESC) AS DNR
FROM tbl)
SELECT*
FROM tbl2
WHERE DNR<=5
ORDER BY TheYear
        ,TheQuarter
        ,DNR 


/* Question 3: Top 10 products by total sales value */
----------------------------------------

GO
 
 SELECT TOP 10
       sti.StockItemID, sti.StockItemName
      ,SUM(sil.Quantity*sil.UnitPrice) AS TotalProfit 
 FROM warehouse.StockItems sti JOIN sales.InvoiceLines sil
 ON sti.StockItemID = sil.StockItemID
 GROUP BY sti.StockItemID, sti.StockItemName
 ORDER BY TotalProfit DESC



/* Question 4: Products ranked by nominal profit (retail price minus unit price) */
----------------------------------------

 GO

 WITH tbl 
 AS
(SELECT sti.StockItemID
      ,sti.StockItemName
      ,sti.UnitPrice
      ,sti.RecommendedRetailPrice
      ,(sti.RecommendedRetailPrice - sti.UnitPrice) AS NominalProductProfit
FROM Warehouse.StockItems sti)
SELECT*
      ,DENSE_RANK()OVER(ORDER BY NominalProductProfit DESC) AS DNR
FROM tbl



/* Question 5: Each supplier with the list of products it supplies */
----------------------------------------

 GO

 SELECT CONCAT_WS(' - ',ps.SupplierID,ps.SupplierName) AS SupplierDetails
       ,STRING_AGG(CONCAT(sti.StockItemID ,'  ', sti.StockItemName),' /, ')
       WITHIN GROUP (ORDER BY ps.SupplierID) AS ProductDetails
 FROM Purchasing.Suppliers ps JOIN Warehouse.StockItems sti
 ON ps.SupplierID = sti.SupplierID
 GROUP BY ps.SupplierID,ps.SupplierName
 


/* Question 6: Top 5 customers by spend, with city, country, continent and region */
----------------------------------------

  GO

  WITH tbl
  AS
 (SELECT cus.CustomerID
        ,cit.CityName
        ,coun.CountryName
        ,coun.Continent
        ,coun.Region
        ,SUM(sil.ExtendedPrice) AS Total
 FROM sales.Customers cus JOIN Application.Cities cit  
 ON cit.CityID = cus.PostalCityID
 JOIN Application.StateProvinces asp 
 ON asp.StateProvinceID = cit.StateProvinceID
 JOIN Application.Countries coun 
 ON coun.CountryID = asp.CountryID
 JOIN sales.Invoices si 
 ON si.CustomerID = cus.CustomerID
 JOIN sales.InvoiceLines sil 
 ON sil.InvoiceID = si.InvoiceID
 GROUP BY cus.CustomerID
        ,cit.CityName
        ,coun.CountryName
        ,coun.Continent
        ,coun.Region)
  SELECT TOP 5 
             tbl.CustomerID
            ,tbl.CityName
            ,tbl.CountryName
            ,tbl.Continent
            ,tbl.Region
            ,FORMAT(tbl.Total ,'#,#.00') AS TotalExpendedPrice
         
  FROM tbl
  ORDER BY Total DESC
  


/* Question 7: Monthly sales with yearly subtotals and a running total */
----------------------------------------


GO

WITH tbl
AS 
(SELECT YEAR(si.InvoiceDate) AS InvoiceYear
        ,CAST(MONTH(si.InvoiceDate) AS VARCHAR(15)) AS InvoiceMonth
        ,MONTH(si.InvoiceDate) AS mn
        ,SUM(sil.Quantity*sil.UnitPrice) AS MonthlyTotal
FROM Sales.Invoices si JOIN Sales.InvoiceLines sil 
ON si.InvoiceID = sil.InvoiceID
GROUP BY ROLLUP(YEAR(si.InvoiceDate),MONTH(si.InvoiceDate))
HAVING YEAR(si.InvoiceDate) IS NOT NULL)
SELECT InvoiceYear
      ,ISNULL(InvoiceMonth,'Grand Total') AS InvoiceMonth
      ,FORMAT(MonthlyTotal,'#,#.00') AS MonthlyTotal
      ,FORMAT(SUM(MonthlyTotal) OVER(PARTITION BY InvoiceYear ORDER BY ISNULL(mn,13)),'#,#.00') AS CumulativeTotal
FROM tbl
ORDER BY InvoiceYear,ISNULL(mn,13)



/* Question 8: Number of orders per month, by year (2013-2016) */
----------------------------------------
GO

SELECT OrderMonth, [2013],[2014],[2015],[2016]
FROM (SELECT o.OrderID, MONTH(o.OrderDate) AS OrderMonth ,YEAR(o.OrderDate) AS yy
      FROM Sales.Orders o ) T
PIVOT(COUNT(orderID) FOR T.yy IN ([2013],[2014],[2015],[2016])) AS pvt
ORDER BY OrderMonth



/* Question 9: Potential churn: days since last order compared with the customer's average gap */
----------------------------------------

GO

WITH tbl
AS
(SELECT c.CustomerID,c.CustomerName, o.OrderDate
      ,LAG(o.OrderDate,1)OVER(PARTITION BY c.CustomerID ORDER BY OrderDate) AS PreviousOrderDate
FROM sales.Orders o JOIN sales.Customers c
ON o.CustomerID = c.CustomerID),
tbl2
AS
(SELECT*
      ,DATEDIFF(dd,tbl.PreviousOrderDate,tbl.OrderDate) AS DaysApart
FROM tbl),
tbl3
AS
(SELECT tbl2.CustomerID,tbl2.CustomerName,tbl2.OrderDate,tbl2.PreviousOrderDate
      ,AVG(tbl2.DaysApart)OVER(PARTITION BY tbl2.CustomerID) AS AvgDaysBetweenOrders
      ,MAX(tbl2.OrderDate)OVER(PARTITION BY tbl2.CustomerID) AS LastCustOrderDate
      ,MAX(tbl2.OrderDate)OVER() AS LastOrderDateAll
FROM tbl2),
tbl4
AS
(SELECT*
     ,DATEDIFF(dd,LastCustOrderDate,LastOrderDateAll) DaysSinceLastOrder
FROM tbl3)
SELECT*
     ,CASE WHEN DaysSinceLastOrder>(AvgDaysBetweenOrders*2) THEN 'Potential Churn'
           ELSE 'Active'
      END AS CustomerStatus
FROM tbl4



/* Question 10: Customer distribution by category, counting each chain as one customer */
----------------------------------------

GO

WITH tbl
AS
(SELECT cat.CustomerCategoryName, cus.CustomerID
      ,CASE WHEN cus.CustomerName LIKE 'Wingtip%' THEN 'wingtip'
            WHEN CustomerName LIKE 'Tailspin%' THEN 'tailspin'
            ELSE  cus.CustomerName 
      END AS UniC
FROM Sales.CustomerCategories cat JOIN sales.Customers cus
ON cat.CustomerCategoryID = cus.CustomerCategoryID),
tbl2
AS
(SELECT tbl.CustomerCategoryName
     ,COUNT(DISTINCT tbl.UniC) AS CustomerCOUNT
     ,SUM(COUNT(DISTINCT tbl.UniC))OVER() AS TotalCustCount
FROM tbl
GROUP BY tbl.CustomerCategoryName)
SELECT*
     ,CONCAT(FORMAT((tbl2.CustomerCOUNT * 100.0) / tbl2.TotalCustCount,'#.00'),'%') AS DistributionFactor
FROM tbl2
ORDER BY tbl2.CustomerCategoryName



/*
The highest business risk lies in the Novelty Shop category.
This category contains the company's two largest customers: Wingtip Toys and Tailspin Toys.
Together, they account for 459 branches out of a total of 663 stores across all customer
categories (69.23%).
When each chain is counted as a single customer, the Novelty Shop category represents
22.43% of all customers across the 5 categories.
The company is significantly and heavily dependent on these two customers in the
Novelty Shop category. The loss of even one of these chains would cause a drop of tens
of percent in the company's overall customer base.
*/




