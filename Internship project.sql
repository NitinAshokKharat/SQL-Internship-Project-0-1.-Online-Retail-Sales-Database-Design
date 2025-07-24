create database retailsales;

use retailsales;

-- Customers Table
CREATE TABLE Customers (
  CustomerID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100),
  Email VARCHAR(100) UNIQUE,
  Phone VARCHAR(15),
  Address TEXT
);

-- Products Table
CREATE TABLE Products (
  ProductID INT AUTO_INCREMENT PRIMARY KEY,
  ProductName VARCHAR(100),
  Category VARCHAR(50),
  Price DECIMAL(10,2),
  Stock INT
);

-- Orders Table
CREATE TABLE Orders (
  OrderID INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID INT,
  OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  Status VARCHAR(50),
  FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- OrderItems Table
CREATE TABLE OrderItems (
  OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT,
  ProductID INT,
  Quantity INT,
  Price DECIMAL(10,2),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Payments Table
CREATE TABLE Payments (
  PaymentID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT,
  PaymentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  Amount DECIMAL(10,2),
  PaymentMethod VARCHAR(50),
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);


show tables;

select * from customers;


-- Switch to the database
USE retailsales;

-- Insert data into Customers table
INSERT INTO Customers (Name, Email, Phone, Address) VALUES
('Rahul Sharma', 'rahul@gmail.com', '9876543210', 'Mumbai'),
('Priya Desai', 'priya@gmail.com', '9988776655', 'Pune'),
('Amit Verma', 'amitv@gmail.com', '9012345678', 'Delhi'),
('Sneha Kapoor', 'sneha_k@yahoo.com', '9234567890', 'Bangalore'),
('Ravi Mehta', 'ravi.mehta@gmail.com', '9123456789', 'Hyderabad');

-- Insert data into Products table
INSERT INTO Products (ProductName, Category, Price, Stock) VALUES
('Wireless Mouse', 'Electronics', 599.00, 100),
('T-Shirt', 'Apparel', 499.00, 200),
('Bluetooth Speaker', 'Electronics', 1499.00, 75),
('Running Shoes', 'Footwear', 1999.00, 50),
('Notebook', 'Stationery', 49.00, 500);

-- Insert data into Orders table
INSERT INTO Orders (CustomerID, OrderDate, Status) VALUES
(1, '2025-07-20 10:30:00', 'Completed'),
(2, '2025-07-21 14:00:00', 'Completed'),
(3, '2025-07-22 09:15:00', 'Pending'),
(4, '2025-07-23 11:45:00', 'Cancelled'),
(5, '2025-07-23 15:20:00', 'Completed');

-- Insert data into OrderItems table
INSERT INTO OrderItems (OrderID, ProductID, Quantity, Price) VALUES
(1, 1, 2, 599.00),
(1, 2, 1, 499.00),
(2, 4, 1, 1999.00),
(3, 3, 1, 1499.00),
(5, 5, 10, 49.00);

-- Insert data into Payments table
INSERT INTO Payments (OrderID, PaymentDate, Amount, PaymentMethod) VALUES
(1, '2025-07-20 11:00:00', 1697.00, 'Credit Card'),
(2, '2025-07-21 14:30:00', 1999.00, 'UPI'),
(5, '2025-07-23 16:00:00', 490.00, 'Cash'),
(1, '2025-07-20 11:05:00', 499.00, 'Wallet'),
(3, '2025-07-22 10:00:00', 1499.00, 'Credit Card'); -- even though order is pending

--  1. View: Full Sales Report
CREATE VIEW SalesReport AS
SELECT 
    O.OrderID,
    C.Name AS CustomerName,
    C.Email,
    P.ProductName,
    P.Category,
    OI.Quantity,
    OI.Price AS UnitPrice,
    (OI.Quantity * OI.Price) AS TotalItemAmount,
    O.OrderDate,
    O.Status,
    PM.PaymentMethod,
    PM.Amount AS PaymentAmount,
    PM.PaymentDate
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN OrderItems OI ON O.OrderID = OI.OrderID
JOIN Products P ON OI.ProductID = P.ProductID
LEFT JOIN Payments PM ON O.OrderID = PM.OrderID;

SELECT * FROM SalesReport;  -- using salesreportview to see report


-- 2. Query: Total Sales per Product

SELECT 
    P.ProductName,
    SUM(OI.Quantity) AS TotalUnitsSold,
    SUM(OI.Quantity * OI.Price) AS TotalRevenue
FROM OrderItems OI
JOIN Products P ON OI.ProductID = P.ProductID
GROUP BY P.ProductName;


-- 3. Query: Total Sales per Customer


SELECT 
    C.Name AS CustomerName,
    C.Email,
    SUM(PM.Amount) AS TotalSpent
FROM Payments PM
JOIN Orders O ON PM.OrderID = O.OrderID
JOIN Customers C ON O.CustomerID = C.CustomerID
GROUP BY C.CustomerID;


-- 4. Query: Daily Sales Summary

SELECT 
    DATE(O.OrderDate) AS SalesDate,
    COUNT(DISTINCT O.OrderID) AS TotalOrders,
    SUM(OI.Quantity * OI.Price) AS DailyRevenue
FROM Orders O
JOIN OrderItems OI ON O.OrderID = OI.OrderID
GROUP BY DATE(O.OrderDate)
ORDER BY SalesDate DESC;


-- 5. Query: Top Selling Products

SELECT 
    P.ProductName,
    SUM(OI.Quantity) AS UnitsSold
FROM OrderItems OI
JOIN Products P ON OI.ProductID = P.ProductID
GROUP BY P.ProductName
ORDER BY UnitsSold DESC
LIMIT 5;


-- 6. Query: Orders with Multiple Products


SELECT 
    O.OrderID,
    C.Name AS CustomerName,
    COUNT(OI.ProductID) AS ProductCount
FROM Orders O
JOIN Customers C ON O.CustomerID = C.CustomerID
JOIN OrderItems OI ON O.OrderID = OI.OrderID
GROUP BY O.OrderID
HAVING COUNT(OI.ProductID) > 1;




