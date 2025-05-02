-- QUESTION 1 --
WITH RECURSIVE split_products AS (
    SELECT 
        OrderID,
        CustomerName,
        JSON_UNQUOTE(JSON_EXTRACT(JSON_ARRAYAGG(JSON_UNQUOTE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', 1), ',', -1)))), '$[0]')) AS Product,
        1 AS pos,
        Products,
        LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) + 1 AS total
    FROM ProductDetail

    UNION ALL

    SELECT
        OrderID,
        CustomerName,
        JSON_UNQUOTE(JSON_EXTRACT(JSON_ARRAYAGG(JSON_UNQUOTE(TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', pos + 1), ',', -1)))), '$[0]')),
        pos + 1,
        Products,
        total
    FROM split_products
    WHERE pos < total
)
SELECT DISTINCT 
    OrderID,
    CustomerName,
    Product
FROM split_products
ORDER BY OrderID;



-- QUESTION 2 --
-- a) Create Orders table (to remove partial dependency)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- b) Create OrderItems table (only data that depends on both OrderID and Product)
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- c) Insert data into Orders (DISTINCT to avoid duplication)
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

-- d) Insert data into OrderItems
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;
