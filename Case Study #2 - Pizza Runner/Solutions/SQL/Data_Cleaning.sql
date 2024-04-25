/* --------------------
Case Study #2 - Pizza Runner
   --------------------*/

-- DATA CLEANING
-- 1. Create a new table named `cleaned_customer_orders`
-- Create the table structure 
CREATE TABLE cleaned_customer_orders (
	order_id INT, 
	customer_id INT, 
	pizza_id INT,
	exclusions VARCHAR(4),
	extras VARCHAR(4),
	order_time DATETIME
);

-- Insert data into the table 
INSERT INTO cleaned_customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time)
SELECT 
	order_id, 
	customer_id, 
	pizza_id,
CASE
	WHEN exclusions = '' OR exclusions = 'NaN' OR exclusions = 'null' OR exclusions IS NULL THEN ' '
	ELSE exclusions
	END AS exclusions,
CASE
	WHEN extras = '' OR exclusions = 'NaN' OR extras = 'null' OR extras IS NULL THEN ' '
	ELSE extras
	END AS extras,
	order_time
FROM pizza_runner..customer_orders;

-- Query the newly created table 
SELECT *
FROM cleaned_customer_orders;

-- 2. Create a new table named `cleaned_runners_orders`
-- Create the table structure 
CREATE TABLE cleaned_runner_orders (
	order_id INT, 
	runner_id INT,
	pickup_time DATETIME,
	distance FLOAT,
	duration INT, 
	cancellation VARCHAR(23)
);

-- Insert data into the table 
INSERT INTO cleaned_runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) 
SELECT 
	order_id, 
	runner_id,
CAST(
	CASE
		WHEN pickup_time LIKE 'null' THEN NULL
		ELSE pickup_time
		END AS DATETIME) AS pickup_time,
CAST(
	CASE
		WHEN distance LIKE 'null' THEN NULL
		WHEN distance LIKE '%km' THEN TRIM('km' from distance)
		ELSE distance
		END AS FLOAT) AS distance,
CAST(
	CASE
		WHEN duration LIKE 'null' THEN NULL
		WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
		WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
		WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
		ELSE duration
		END AS INT) AS duration,
CASE	
	WHEN cancellation LIKE 'null' OR cancellation IS NULL OR cancellation = ' ' THEN NULL
	ELSE cancellation
	END AS cancellation
FROM pizza_runner..runner_orders;

-- Query the newly created table 
SELECT *
FROM cleaned_runner_orders;

-- 3. Alter the data type of column `pizza_name` in table `pizza_names`to the correct data type 
ALTER TABLE pizza_runner..pizza_names
ALTER COLUMN pizza_name VARCHAR(23);







