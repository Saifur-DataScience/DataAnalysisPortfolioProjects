USE sales; 

-- Looking at first 5 rows from transaction table

SELECT * FROM transactions LIMIT 5;

-- Looking at the transactions done in year 2020

SELECT * FROM transactions
WHERE YEAR(order_date) = 2020
ORDER BY order_date;

SELECT COUNT(*) FROM transactions
WHERE YEAR(order_date) = 2020;

SELECT SUM(sales_amount) FROM transactions
WHERE YEAR(order_date) = 2020;

SELECT MAX(sales_qty) FROM transactions
WHERE YEAR(order_date) = 2020; 

SELECT MAX(sales_amount) FROM transactions
WHERE YEAR(order_date) = 2020;

SELECT MIN(sales_qty) FROM transactions
WHERE YEAR(order_date) = 2020; 

SELECT MIN(sales_amount) FROM transactions
WHERE YEAR(order_date) = 2020;

-- Comparing sales for years 2018, 2019 & 2020

SELECT SUM(sales_amount) FROM transactions
WHERE YEAR(order_date) = 2018; -- INR 41,43,08,941.00

SELECT SUM(sales_amount) FROM transactions
WHERE YEAR(order_date) = 2019; -- INR 33,64,52,114.00

SELECT SUM(sales_amount) FROM transactions
WHERE YEAR(order_date) = 2020; -- INR 14,22,35,559.00

-- We see that the sales is declining year after year and that is the major concern for Atliq Hardware

-- Looking at the transactions from Mumbai

SELECT * FROM transactions
WHERE market_code = (
	SELECT markets_code FROM markets
    WHERE markets_name = "Mumbai"
);

SELECT COUNT(*) FROM transactions
WHERE market_code = (
	SELECT markets_code FROM markets
    WHERE markets_name = "Mumbai"
);

SELECT SUM(sales_amount) FROM transactions
WHERE market_code = (
	SELECT markets_code FROM markets
    WHERE markets_name = "Mumbai"
);

SELECT ROUND(AVG(sales_amount), 2) FROM transactions
WHERE market_code = (
	SELECT markets_code FROM markets
    WHERE markets_name = "Mumbai"
);

-- Let's look at annual revenue zone wise

SELECT * FROM transactions t
INNER JOIN markets m ON t.market_code = m.markets_code; 

SELECT SUM(sales_amount) FROM transactions t
INNER JOIN markets m ON t.market_code = m.markets_code
WHERE zone = "North"; -- INR 67,69,59,990.00

SELECT SUM(sales_amount) FROM transactions t
INNER JOIN markets m ON t.market_code = m.markets_code
WHERE zone = "South"; -- INR 4,57,44,764.00

SELECT SUM(sales_amount) FROM transactions t
INNER JOIN markets m ON t.market_code = m.markets_code
WHERE zone = "Central"; -- INR 26,38,61,012.00

-- We now see that the South zone is generating the least revenue
-- Whereas, North zone is the highest in terms of revenue