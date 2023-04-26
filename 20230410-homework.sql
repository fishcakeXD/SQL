-- 找出和最貴的產品同類別的所有產品
SELECT ProductID,ProductName,CategoryID
FROM Products 
WHERE CategoryID = (
SELECT TOP 1 CategoryID
FROM Products
ORDER BY UnitPrice DESC
)
-- 找出和最貴的產品同類別最便宜的產品
SELECT TOP 1 ProductID,ProductName,CategoryID
FROM Products 
WHERE CategoryID = (
SELECT TOP 1 CategoryID
FROM Products
ORDER BY UnitPrice DESC
)ORDER BY UnitPrice 
-- 計算出上面類別最貴和最便宜的兩個產品的價差
SELECT (MAX(UnitPrice)-MIN(UnitPrice)) AS Spread
FROM Products
WHERE CategoryID = (
SELECT TOP 1 CategoryID
FROM Products
ORDER BY UnitPrice DESC
)
-- 找出沒有訂過任何商品的客戶所在的城市的所有客戶
SELECT  c.CustomerID,c.CompanyName
FROM Customers c
WHERE c.City in (
SELECT c.City
FROM Orders o  
FULL  JOIN Customers c
ON c.CustomerID = o.CustomerID
WHERE o.OrderID is NULL
)
-- 找出第 5 貴跟第 8 便宜的產品的產品類別
SELECT   ProductName,CategoryID,CategoryName
FROM 
(
SELECT p.ProductName,c.CategoryID,c.CategoryName,DENSE_RANK() OVER (ORDER BY p.Unitprice DESC) AS rank_desc,
         DENSE_RANK() OVER (ORDER BY p.Unitprice ASC) AS rank_asc
FROM Products p
INNER JOIN Categories c ON  p.CategoryID = c.CategoryID
)ranked
WHERE rank_desc = 5 OR rank_asc = 8


-- 找出誰買過第 5 貴跟第 8 便宜的產品
SELECT c.CustomerID,c.CompanyName
FROM Customers c
INNER JOIN  Orders o On c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID =p.ProductID
WHERE p.ProductID  IN (
SELECT   ProductID
FROM 
(
SELECT p.ProductID,DENSE_RANK() OVER (ORDER BY p.Unitprice DESC) AS rank_desc,
         DENSE_RANK() OVER (ORDER BY p.Unitprice ASC) AS rank_asc
FROM Products p
)ranked
WHERE rank_desc = 5 OR rank_asc = 8
)
-- 找出誰賣過第 5 貴跟第 8 便宜的產品
SELECT s.SupplierID,s.CompanyName
FROM  Suppliers s 
INNER JOIN Products p ON p.SupplierID =s.SupplierID
WHERE p.ProductID  IN (
SELECT   ProductID
FROM 
(
SELECT p.ProductID,DENSE_RANK() OVER (ORDER BY p.Unitprice DESC) AS rank_desc,
         DENSE_RANK() OVER (ORDER BY p.Unitprice ASC) AS rank_asc
FROM Products p
)ranked
WHERE rank_desc = 5 OR rank_asc = 8
)
-- 找出 13 號星期五的訂單 (惡魔的訂單)
SELECT  *
FROM Orders 
WHERE   DAY(OrderDate) = 13 
AND DATEPART(WEEKDAY, OrderDate) = 6
-- 找出誰訂了惡魔的訂單
SELECT c.CustomerID,c.CompanyName
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE OrderDate IN (
SELECT  OrderDate
FROM Orders
WHERE   DAY(OrderDate) = 13 
AND DATEPART(WEEKDAY, OrderDate) = 6
)
-- 找出惡魔的訂單裡有什麼產品
SELECT  p.ProductID,p.ProductName,o.OrderDate
FROM Products p
INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
INNER JOIN Orders o ON  o.OrderID = od.OrderID
WHERE o.OrderDate IN (
SELECT  OrderDate
FROM Orders
WHERE   DAY(OrderDate) = 13 
AND DATEPART(WEEKDAY, OrderDate) = 6
)

-- 列出從來沒有打折 (Discount) 出售的產品
SELECT DISTINCT  p.ProductID,p.ProductName
FROM [Order Details] od
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE od.Discount = 0
-- 列出購買非本國的產品的客戶
SELECT c.CustomerID,c.CompanyName
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID
INNER JOIN [Order Details] od ON od.ProductID = p.ProductID
INNER JOIN Orders o ON o.OrderID = od.OrderID
INNER JOIN Customers c ON c.CustomerID = o.CustomerID
WHERE s.Country <> c.Country
-- 列出在同個城市中有公司員工可以服務的客戶
SELECT e.EmployeeID,e.FirstName,c.CompanyName
FROM Employees e
INNER JOIN Orders o ON e.EmployeeID = o.EmployeeID
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
WHERE e.City = c.City

-- 列出那些產品沒有人買過
SELECT p.ProductID,od.OrderID
FROM Products p 
FULL JOIN  [Order Details] od ON p.ProductID=od.ProductID
WHERE od.OrderID is NULL
----------------------------------------------------------------------------------------

-- 列出所有在每個月月底的訂單
SELECT *
FROM Orders
WHERE OrderDate IN (
    SELECT EOMONTH(OrderDate)
    FROM Orders
)
-- 列出每個月月底售出的產品
SELECT p.ProductID,p.ProductName
FROM Products p
INNER JOIN [Order Details] od ON od.ProductID = p.ProductID
INNER JOIN  Orders o ON o.OrderID =od.OrderID
WHERE o.OrderDate IN (
    SELECT EOMONTH(OrderDate)
    FROM Orders
)
-- 找出有敗過最貴的三個產品中的任何一個的前三個大客戶
SELECT TOP 3 ProductID,UnitPrice
FROM  Products
ORDER BY UnitPrice DESC

SELECT TOP 3 c.CustomerID,c.CompanyName
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE od.ProductID IN (38,29,9)
GROUP BY c.CustomerID,c.CompanyName
ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC
-- 找出有敗過銷售金額前三高個產品的前三個大客戶
SELECT  TOP 3 
ProductID,SUM(UnitPrice*Quantity*(1-Discount)) AS SalesAmount
FROM [Order Details] 
GROUP BY ProductID
ORDER BY SUM(UnitPrice*Quantity*(1-Discount)) DESC

SELECT TOP 3  c.CustomerID,c.CompanyName,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS SalesAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE od.ProductID IN (38,29,59)
GROUP BY c.CustomerID,c.CompanyName
ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC
-- 找出有敗過銷售金額前三高個產品所屬類別的前三個大客戶
SELECT  TOP 3 
ProductID,SUM(UnitPrice*Quantity*(1-Discount)) AS SalesAmount
FROM [Order Details] 
GROUP BY ProductID
ORDER BY SUM(UnitPrice*Quantity*(1-Discount)) DESC

SELECT ProductID,CategoryID
FROM Products
WHERE ProductID IN (38,29,59)


SELECT   c.CustomerID,c.CompanyName,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS SalesAmount
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
WHERE p.CategoryID IN (6,1,4)
GROUP BY c.CustomerID,c.CompanyName
ORDER BY SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC
-- 列出消費總金額高於所有客戶平均消費總金額的客戶的名字，以及客戶的消費總金額
SELECT  CustomerID,CompanyName
FROM(
SELECT 
	c.CustomerID, c.CompanyName,
	(
		SELECT
			SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
		FROM [Order Details] od
		INNER JOIN Orders o ON od.OrderID = o.OrderID
		WHERE o.CustomerID = c.CustomerID
	) AS SalesAmount
FROM Customers c
) p
WHERE  SalesAmount >= (
SELECT  AVG(SalesAmount)
FROM(
SELECT 
	c.CustomerID, c.CompanyName,
	(
		SELECT
			SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
		FROM [Order Details] od
		INNER JOIN Orders o ON od.OrderID = o.OrderID
		WHERE o.CustomerID = c.CustomerID
	) AS SalesAmount
FROM Customers c
) p
)
-- 列出最熱銷的產品，以及被購買的總金額
SELECT TOP 1  ProductID,SUM(Quantity) AS SaleAmount
FROM [Order Details]
GROUP BY ProductID
ORDER BY SUM(Quantity) DESC

SELECT ProductID,SUM(UnitPrice*Quantity*(1-Discount))AS SaleAmount
FROM [Order Details]
WHERE ProductID = 60
GROUP BY ProductID
-- 列出最少人買的產品
SELECT TOP 1  ProductID,SUM(Quantity) AS SaleAmount
FROM [Order Details]
GROUP BY ProductID
ORDER BY SUM(Quantity) 
-- 列出最沒人要買的產品類別 (Categories)
SELECT  TOP 1 p.CategoryID,COUNT(p.CategoryID)
FROM [Order Details] od
INNER JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.CategoryID
ORDER BY COUNT(p.CategoryID)
-- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (含購買其它供應商的產品)
SELECT s.SupplierID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount))
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID
INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
INNER JOIN Orders o ON od.OrderID = o.OrderID
INNER JOIN Customers c ON o.CustomerID =c.CustomerID
GROUP BY  s.SupplierID
ORDER BY  SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC

SELECT s.SupplierID,c.CustomerID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount))
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID
INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
INNER JOIN Orders o ON od.OrderID = o.OrderID
INNER JOIN Customers c ON o.CustomerID =c.CustomerID
WHERE s.SupplierID = 18
GROUP BY  s.SupplierID,c.CustomerID
ORDER BY  SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) DESC

SELECT c.CustomerID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount))AS Total
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
WHERE c.CustomerID = 'QUICK'
GROUP BY c.CustomerID
-- 列出跟銷售最好的供應商買最多金額的客戶與購買金額 (不含購買其它供應商的產品)
SELECT c.CustomerID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount))
FROM Suppliers s
INNER JOIN Products p ON s.SupplierID = p.SupplierID
INNER JOIN [Order Details] od ON p.ProductID = od.ProductID
INNER JOIN Orders o ON od.OrderID = o.OrderID
INNER JOIN Customers c ON o.CustomerID =c.CustomerID
WHERE c.CustomerID = 'QUICK' AND s.SupplierID = 18
GROUP BY   c.CustomerID
-- 列出沒有傳真 (Fax) 的客戶和它的消費總金額
SELECT  c.CustomerID,SUM(od.UnitPrice*od.Quantity*(1-od.Discount)) AS SalesAmount
FROM [Order Details] od
INNER JOIN Orders o ON od.OrderID = o.OrderID
INNER JOIN Customers c ON o.CustomerID =c.CustomerID
WHERE c.CustomerID IN (
SELECT CustomerID
FROM Customers
WHERE Fax IS NULL
)
GROUP BY c.CustomerID
-- 列出每一個城市消費的產品種類數量
SELECT City,COUNT(City)AS Amount
FROM(
SELECT  DISTINCT c.City,p.CategoryID
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID =od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
)p
GROUP BY City

-- 列出目前沒有庫存的產品在過去總共被訂購的數量
SELECT ProductID,SUM(Quantity)AS Total
FROM [Order Details] od
WHERE ProductID IN (
SELECT ProductID
FROM Products
WHERE UnitsInStock = 0
)
GROUP BY ProductID
-- 列出目前沒有庫存的產品在過去曾經被那些客戶訂購過
SELECT  DISTINCT c.CustomerID,c.CompanyName
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID =od.OrderID
WHERE od.ProductID IN (
SELECT ProductID
FROM Products
WHERE UnitsInStock = 0
)
-- 列出每位員工的下屬的業績總金額------------做一半
SELECT EmployeeID,ReportsTo
FROM Employees

SELECT e.ReportsTo,SUM(od.UnitPrice*od.Quantity*(1-od.Discount))AS Total
FROM Orders o
INNER JOIN [Order Details] od ON o.OrderID = od.OrderID
INNER JOIN Employees e ON o.EmployeeID =e.EmployeeID
GROUP BY e.ReportsTo


-- 列出每家貨運公司運送最多的那一種產品類別與總數量
SELECT  s.ShipperID,p.CategoryID,SUM(od.Quantity)AS Total
FROM Shippers s
INNER JOIN Orders o On s.ShipperID = o.ShipVia
INNER JOIN [Order Details] od  ON o.OrderID =od.OrderID
INNER JOIN Products p ON od.ProductID =p.ProductID
WHERE p.CategoryID = 1
GROUP BY s.ShipperID,p.CategoryID
ORDER BY s.ShipperID, COUNT(*) DESC
-- 列出每一個客戶買最多的產品類別與金額

SELECT  c.CustomerID,p.CategoryID,SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS Total
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od  ON o.OrderID =od.OrderID
INNER JOIN Products p ON od.ProductID =p.ProductID
GROUP BY c.CustomerID,p.CategoryID
HAVING SUM(od.Quantity*od.UnitPrice*(1-od.Discount))  IN
(SELECT MAX(Total)
FROM(
SELECT  c.CustomerID,p.CategoryID,SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) AS Total
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od  ON o.OrderID =od.OrderID
INNER JOIN Products p ON od.ProductID =p.ProductID
GROUP BY c.CustomerID,p.CategoryID)p
WHERE p.CustomerID = c.CustomerID
)
-- 列出每一個客戶買最多的那一個產品與購買數量
SELECT  c.CustomerID,p.ProductID,SUM(od.Quantity)
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od  ON o.OrderID =od.OrderID
INNER JOIN Products p ON od.ProductID =p.ProductID
GROUP BY c.CustomerID,p.ProductID
HAVING  SUM(od.Quantity) IN 
(
SELECT MAX(Total)
FROM (
SELECT  c.CustomerID,p.ProductID,SUM(od.Quantity)AS Total
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od  ON o.OrderID =od.OrderID
INNER JOIN Products p ON od.ProductID =p.ProductID
GROUP BY c.CustomerID,p.ProductID
)p
WHERE p.CustomerID = c.CustomerID
)

-- 按照城市分類，找出每一個城市最近一筆訂單的送貨時間
SELECT  c.City,MAX(o.ShippedDate)
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY  c.City
-- 列出購買金額第五名與第十名的客戶，以及兩個客戶的金額差距
SELECT CustomerID,Total
FROM(
SELECT c.CustomerID,SUM(od.Quantity*od.UnitPrice*(1-od.Discount))AS Total,DENSE_RANK() OVER (ORDER BY  SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) DESC) AS rank_desc
FROM Customers c
INNER JOIN Orders o  ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID =od.OrderID
GROUP BY c.CustomerID)ranked
WHERE rank_desc = 5 OR rank_desc = 10


SELECT MAX(Total)-Min(Total) AS Gap
FROM(
SELECT c.CustomerID,SUM(od.Quantity*od.UnitPrice*(1-od.Discount))AS Total,DENSE_RANK() OVER (ORDER BY  SUM(od.Quantity*od.UnitPrice*(1-od.Discount)) DESC) AS rank_desc
FROM Customers c
INNER JOIN Orders o  ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] od ON o.OrderID =od.OrderID
GROUP BY c.CustomerID)ranked
WHERE rank_desc = 5 OR rank_desc = 10