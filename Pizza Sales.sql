CREATE DATABASE PIZZA_DB;
USE PIZZA_DB;
SELECT * FROM pizza_sales;
TRUNCATE TABLE PIZZA_DB.pizza_sales;
set global local_infile=on;    
LOAD DATA LOCAL INFILE '/Users/twinklejain/Desktop/Data Analysis Project/Pizza Sales/pizza_sales.csv'
INTO TABLE pizza_sales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(pizza_id, order_id, pizza_name_id, quantity, @order_date, @order_time, unit_price, total_price, pizza_size, pizza_category, @pizza_ingredients, @pizza_name)
SET order_date = DATE(STR_TO_DATE(@order_date, '%m/%d/%y')),
    order_time = TIME(STR_TO_DATE(@order_time, '%H:%i:%s')),
    pizza_ingredients = TRIM(BOTH '"' FROM @pizza_ingredients),
    pizza_name = TRIM(BOTH '"' FROM @pizza_name);

ALTER TABLE pizza_sales
MODIFY COLUMN order_time TIME;
ALTER TABLE pizza_sales
MODIFY COLUMN order_time DATETIME;
ALTER TABLE pizza_sales
MODIFY COLUMN order_date DATE;

/* KPI Requirements */
/* Total Revenue: The Sum of the total price of all pizza orders. */
SELECT SUM(total_price) AS Total_Revenue from pizza_sales;

/* Average Order Value: The average amount spent per order, calculated by dividing the total revenue by the total number of orders. */
SELECT SUM(total_price) / COUNT(DISTINCT order_id) AS Avg_Order_Value from pizza_sales;

/* Total Pizzas Sold: The Sum of all the quantities of Pizzas sold. */
SELECT SUM(quantity) AS Total_Pizzas_Sold from pizza_sales;

/* Total Orders Placed: The total number of orders placed. */
SELECT COUNT(DISTINCT order_id) AS Total_Orders from pizza_sales;

/* Average Pizzas per Order: The average number of pizzas sold per order, calculated by dividing the total number of pizzas sold by the total number of orders. */
SELECT CAST(CAST(SUM(quantity) AS DECIMAL (10,2)) / 
CAST(COUNT(DISTINCT order_id) AS DECIMAL (10,2)) AS DECIMAL(10,2)) AS Avg_Pizzas_per_Order from pizza_sales;

/* Chart Requirements */
/* Daily Trend For Total Orders */
SELECT DAYNAME(order_date) AS order_day, COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY DAYNAME(order_date);
SELECT DAYNAME(order_date) AS order_day, COUNT(DISTINCT order_id) AS Total_orders 
FROM pizza_sales 
WHERE order_date IS NOT NULL
GROUP BY DAYNAME(order_date);

/* Hourly Trend For Total Orders */
SELECT HOUR(order_time) AS order_hours, COUNT(DISTINCT order_id) AS Total_orders 
FROM pizza_sales 
GROUP BY HOUR(order_time) 
ORDER BY HOUR(order_time);

/* Percentage of Sales by Pizza Category */
SELECT pizza_category, SUM(total_price) AS Total_Sales, SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales WHERE MONTH(order_date) = 1) AS PCT
FROM pizza_sales
WHERE MONTH(order_date) = 1
GROUP BY pizza_category;

/* Percentage of Sales by Pizza Size */
SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Sales, CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_size
ORDER BY PCT DESC;

/* Total Pizzas Sold By Pizza Category */
SELECT pizza_category, SUM(quantity) as Total_Pizzas_Sold
FROM pizza_Sales
GROUP BY Pizza_Category;

/* Top 5 Bestsellers by Total Pizzas Sold */
SELECT pizza_name, SUM(quantity) as Total_Pizzas_Sold
FROM pizza_Sales
GROUP BY pizza_name
ORDER BY SUM(quantity) DESC
LIMIT 5;

/* Bottom 5 Worstsellers by Total Pizzas Sold */
SELECT pizza_name, SUM(quantity) as Total_Pizzas_Sold
FROM pizza_Sales
GROUP BY pizza_name
ORDER BY SUM(quantity) ASC
LIMIT 5;