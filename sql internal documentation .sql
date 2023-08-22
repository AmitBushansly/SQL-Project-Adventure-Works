--Internal Documentation
-- Creating a data panel

SELECT   
soh.SalesOrderID
,soh.OrderDate
		,year(soh.OrderDate) as year
		,DATEPART (QUARTER,soh.OrderDate) as QUARTER
		,MONTH(soh.OrderDate) as MONTH 
		,soh.SalesPersonID
		,sp.TerritoryID
		,soh.TotalDue
		,sod.ProductID
		,sod.OrderQty
		,p.StandardCost 
		,sod.LineTotal
		,sod.UnitPriceDiscount
		,p.[Name]
		
into  project
FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
	FULL OUTER join Sales.SalesPerson sp on soh.SalesPersonID=BusinessEntityID

SELECT * from project

--Checking seasonality at a monthly level	
	select [YEAR],[MONTH],
	
			sum ((LineTotal)-(StandardCost*OrderQty)) as profit
	from project
	group by  year,MONTH
	order by year,MONTH 

-- Checking seasonality at a quarterly level	
	select [YEAR],QUARTER,
	
			sum ((LineTotal)-(StandardCost*OrderQty)) as profit
	from project
	group by  year,QUARTER
	order by year,QUARTER

	--Monthly profit
	select MONTH, sum ((LineTotal)-(StandardCost*OrderQty)) as profit
	from project
	group by MONTH
	order by profit desc
	--Yearly profit
	select YEAR, sum ((LineTotal)-(StandardCost*OrderQty)) as profit
	from project
	group by YEAR
	order by YEAR

--   Profitability and quantity of items sold per product ordered by profitability
	select  ProductID,name,
	sum ((LineTotal)-(StandardCost*OrderQty))  as 'profit',
	sum (orderqty) as 'SumQty'
	from project
	group by ProductID, Name
order by profit desc


	--   Profitability and quantity of items sold per product, ordered by the quantity of items sold
select  ProductID,name,
	sum ((LineTotal)-(StandardCost*OrderQty))  as 'profit',
	sum (orderqty) as 'SumQty'
	from project
	group by ProductID, Name
order by SumQty desc

-- Top 10 best selling products
SELECT TOP 10 
    p.Name AS ProductName, 
    SUM(sod.OrderQty) AS TotalSold, 
    p.StandardCost AS CostPerUnit, 
    p.ListPrice AS PricePerUnit, 
    (SELECT SUM(Quantity) FROM Production.ProductInventory WHERE ProductID = p.ProductID) AS StockBalance
FROM 
    Sales.SalesOrderDetail sod
    JOIN Production.Product p ON p.ProductID = sod.ProductID
GROUP BY 
    p.ProductID, 
    p.Name, 
    p.StandardCost, 
    p.ListPrice
ORDER BY  SUM(sod.OrderQty) DESC

-- A losing product in 2014 from the Mountain-500 series
select  ProductID,name,
	sum ((LineTotal)-(StandardCost*OrderQty))  as 'profit',
	sum (OrderQty) as 'sumqty'
	from project
	where YEAR= 2014 and name like '%500%'
	group by ProductID, Name
order by profit


--  Losing products from series Mountain-500 with a discount
select *, LineTotal- StandardCost*OrderQty as 'profit'
from project
where ProductID in (988,987,985,986,984) and UnitPriceDiscount > 0

--   Losing products from series Mountain-500 without discount
select *, LineTotal- StandardCost*OrderQty as 'profit'
from project
where ProductID in (988,987,985,986,984, 884, 883, 715, 835, 881) and UnitPriceDiscount =0

select*
 from project

 -- The products that the company has loses on them
 select top 10 ProductID,
         [Name]
		,sum(LineTotal-(StandardCost*OrderQty)) as profit
from project
where [year] = 2014 
group by ProductID,[Name]
order by profit

--The profit on this products when they sail without discount
select  ProductID
         ,[Name]
		,sum(LineTotal-(StandardCost*OrderQty)) as profit
		,sum(OrderQty) as 'sells'
from project
where [year] = 2014 and UnitPriceDiscount = 0 and ProductID in (988,987,985,986,984, 884, 883, 715, 835, 881) -- without discount
group by ProductID,[Name]
order by profit

--The profit on this products when they sail with discount
 select  ProductID,
         [Name]
		,sum(LineTotal-(StandardCost*OrderQty)) as profit
		,sum(OrderQty) as 'sells'
from project
where [year] = 2014 and UnitPriceDiscount > 0 and ProductID in (988,987,985,986,984, 884, 883, 715, 835, 881)-- with discount
group by ProductID,[Name]
order by profit

-- The products that the company has lose on them
 select top 10 ProductID,
         [Name]
		,sum(LineTotal-(StandardCost*OrderQty)) as profit
from project
where [year] = 2014 and ProductID in (988,987,985,986,984)
group by ProductID,[Name]
order by profit

--The profit on this products when they sail without discount
select  ProductID
         ,[Name]
		,sum(LineTotal-(StandardCost*OrderQty)) as profit
from project
where [year] = 2014 and UnitPriceDiscount = 0 and ProductID in (988,987,985,986,984) -- without discount
group by ProductID,[Name]
order by profit

--The profit on this products when they sail with discount
 select  ProductID,
         [Name]
		,sum(LineTotal-(StandardCost*OrderQty)) as profit
from project
where [year] = 2014 and UnitPriceDiscount > 0 and ProductID in (988,987,985,986,984)-- with discount
group by ProductID,[Name]
order by profit


-- Top 10 best selling products
SELECT TOP 10 
    p.Name AS ProductName, 
    SUM(sod.OrderQty) AS TotalSold 
FROM 
    Sales.SalesOrderDetail sod
    JOIN Production.Product p ON p.ProductID = sod.ProductID
GROUP BY 
    p.ProductID, 
    p.Name, 
    p.StandardCost, 
    p.ListPrice
ORDER BY  SUM(sod.OrderQty) DESC


-- Seller with Discount
select ProductID, SalesPersonID, territoryID, OrderDate ,sum(LineTotal-(StandardCost*OrderQty)) over (partition by SalesPersonID) as profit
 from project 
 where ProductID in (988,987,985,986,984) and UnitPriceDiscount > 0
 order by SalesPersonID 

-- Seller without Discount
 select ProductID, SalesPersonID, territoryID, OrderDate,sum(LineTotal-(StandardCost*OrderQty)) over (partition by SalesPersonID) as profit
 from project
 where ProductID in (988,987,985,986,984) and UnitPriceDiscount = 0 and OrderDate > '2014-03-01'
  order by SalesPersonID


 