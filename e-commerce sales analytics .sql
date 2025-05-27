-- Create Database
CREATE DATABASE EcommerceDB;
GO
USE EcommerceDB;

-- Create Table RawData to store the raw imported CSV data
CREATE TABLE RawData (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Description NVARCHAR(255),
    Quantity INT,
    InvoiceDate DATETIME,
    UnitPrice DECIMAL(10, 2),
    CustomerID INT,
    Country NVARCHAR(50)
);

-- Import data from CSV file into RawData table
BULK INSERT RawData
FROM 'C:\Users\Administrator\Downloads\data.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2 -- Skip the header row
);

-- View the imported raw data
SELECT * FROM RawData;

-- Create Customers table with primary key
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Country NVARCHAR(50)
);

-- Create Products table with primary key
CREATE TABLE Products (
    StockCode VARCHAR(20) PRIMARY KEY,
    Description NVARCHAR(255),
    UnitPrice DECIMAL(10, 2)
);

-- Create Orders table with a foreign key reference to Customers
CREATE TABLE Orders (
    InvoiceNo VARCHAR(20),
    InvoiceDate DATETIME,
    CustomerID INT,
    PRIMARY KEY (InvoiceNo),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create OrderItems table with foreign keys to Orders and Products
CREATE TABLE OrderItems (
    InvoiceNo VARCHAR(20),
    StockCode VARCHAR(20),
    Quantity INT,
    FOREIGN KEY (InvoiceNo) REFERENCES Orders(InvoiceNo),
    FOREIGN KEY (StockCode) REFERENCES Products(StockCode)
);

-- Insert distinct products using latest description and unit price per StockCode
WITH RankedProducts AS (
    SELECT 
        StockCode, 
        Description, 
        UnitPrice, 
        ROW_NUMBER() OVER (PARTITION BY StockCode ORDER BY MAX(InvoiceDate) DESC) AS rn
    FROM RawData
    GROUP BY StockCode, Description, UnitPrice
)
INSERT INTO Products (StockCode, Description, UnitPrice)
SELECT StockCode, Description, UnitPrice
FROM RankedProducts
WHERE rn = 1;

-- View inserted product records
SELECT * FROM Products;

-- Insert distinct customers using any available country
INSERT INTO Customers (CustomerID, Country)
SELECT DISTINCT CustomerID, MIN(Country)
FROM RawData
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID;

-- View inserted customers
SELECT * FROM Customers;

-- Insert orders with unique invoice numbers and the latest date per invoice
WITH RankOrders AS (
    SELECT 
        InvoiceNo, 
        InvoiceDate, 
        CustomerID, 
        ROW_NUMBER() OVER (
            PARTITION BY InvoiceNo 
            ORDER BY InvoiceDate DESC
        ) AS rn
    FROM RawData
    WHERE CustomerID IS NOT NULL
)
INSERT INTO Orders (InvoiceNo, InvoiceDate, CustomerID)
SELECT DISTINCT InvoiceNo, InvoiceDate, CustomerID
FROM RankOrders
WHERE rn = 1;

-- View inserted orders
SELECT * FROM Orders;

-- Insert order items by summing quantities per product per invoice
INSERT INTO OrderItems (InvoiceNo, StockCode, Quantity)
SELECT 
    r.InvoiceNo, 
    r.StockCode, 
    SUM(r.Quantity)
FROM RawData r
WHERE EXISTS (
    SELECT 1 FROM Orders o WHERE o.InvoiceNo = r.InvoiceNo
)
GROUP BY r.InvoiceNo, r.StockCode;

-- View inserted order items
SELECT * FROM OrderItems;

-- Drop the RawData table as it's no longer needed
DROP TABLE RawData;

-- Top 10 customers by total spending
SELECT TOP 10 
    c.CustomerID, 
    SUM(oi.Quantity * p.UnitPrice) AS TotalSpent
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderItems oi ON o.InvoiceNo = oi.InvoiceNo
JOIN Products p ON oi.StockCode = p.StockCode
GROUP BY c.CustomerID
ORDER BY TotalSpent DESC;

-- Average number of orders per customer
SELECT AVG(OrderCount) AS AvgOrdersPerCustomer
FROM (
    SELECT CustomerID, COUNT(*) AS OrderCount
    FROM Orders
    GROUP BY CustomerID
) AS Sub;

-- Monthly revenue report
SELECT 
    FORMAT(o.InvoiceDate, 'yyyy-MM') AS Month, 
    SUM(oi.Quantity * p.UnitPrice) AS Revenue
FROM Orders o
JOIN OrderItems oi ON o.InvoiceNo = oi.InvoiceNo
JOIN Products p ON oi.StockCode = p.StockCode
GROUP BY FORMAT(o.InvoiceDate, 'yyyy-MM')
ORDER BY Month;

-- Top 10 products by quantity sold
SELECT TOP 10 
    p.StockCode, 
    p.Description, 
    SUM(oi.Quantity) AS TotalQuantitySold
FROM Products p
JOIN OrderItems oi ON p.StockCode = oi.StockCode
GROUP BY p.StockCode, p.Description
ORDER BY TotalQuantitySold DESC;

-- Top 10 products by revenue generated
SELECT TOP 10 
    p.StockCode, 
    p.Description, 
    SUM(oi.Quantity * p.UnitPrice) AS TotalRevenue
FROM Products p
JOIN OrderItems oi ON p.StockCode = oi.StockCode
GROUP BY p.StockCode, p.Description
ORDER BY TotalRevenue DESC;

-- Peak order times by hour of the day
SELECT 
    DATEPART(HOUR, InvoiceDate) AS HourOfDay,
    COUNT(*) AS OrderCount
FROM Orders
GROUP BY DATEPART(HOUR, InvoiceDate)
ORDER BY OrderCount DESC;

-- Best selling product each month based on quantity sold
SELECT * FROM (
    SELECT
        FORMAT(o.InvoiceDate, 'yyyy-MM') AS Month,
        p.StockCode, 
        p.Description, 
        SUM(oi.Quantity) AS TotalSold,
        RANK() OVER (
            PARTITION BY FORMAT(o.InvoiceDate, 'yyyy-MM') 
            ORDER BY SUM(oi.Quantity) DESC
        ) AS ProductRank
    FROM Orders o 
    JOIN OrderItems oi ON o.InvoiceNo = oi.InvoiceNo
    JOIN Products p ON oi.StockCode = p.StockCode
    GROUP BY FORMAT(o.InvoiceDate, 'yyyy-MM'), p.StockCode, p.Description
) AS MonthlyRanking
WHERE ProductRank = 1;

-- Slow-moving products that haven't been ordered in the last 6 months
SELECT 
    p.StockCode, 
    p.Description, 
    MAX(o.InvoiceDate) AS LastOrderDate
FROM Products p
JOIN OrderItems oi ON p.StockCode = oi.StockCode
JOIN Orders o ON o.InvoiceNo = oi.InvoiceNo
GROUP BY p.StockCode, p.Description
HAVING MAX(o.InvoiceDate) < DATEADD(MONTH, -6, GETDATE())
ORDER BY LastOrderDate;