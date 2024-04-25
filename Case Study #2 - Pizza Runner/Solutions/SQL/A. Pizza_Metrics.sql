/* --------------------
Case Study #2 - Pizza Runner
   --------------------*/
--A. Pizza Metrics
--1. How many pizzas were ordered?
SELECT COUNT(order_id) AS number_of_order
FROM pizza_runner..cleaned_customer_orders;

--2. How many unique customer orders were made?
SELECT COUNT(DISTINCT(order_id)) AS number_of_order
FROM pizza_runner..cleaned_customer_orders;

--3. How many successful orders were delivered by each runner?
SELECT 
	runner_id, 
	COUNT(order_id) AS successful_orders
FROM pizza_runner..cleaned_runner_orders
WHERE distance IS NOT NULL
GROUP BY runner_id;

--4. How many of each type of pizza was delivered?
SELECT 
	t2.pizza_id, 
	COUNT(t1.order_id) AS delivered_pizza_count
FROM pizza_runner..cleaned_customer_orders AS t1
JOIN pizza_runner..pizza_names AS t2
ON t1.pizza_id = t2.pizza_id
JOIN pizza_runner..cleaned_runner_orders AS t3
ON t1.order_id = t3.order_id
WHERE t3.distance != 0
GROUP BY t2.pizza_id;

--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	t1.customer_id,
	t2.pizza_name,
	COUNT(t1.pizza_id)AS order_count
FROM pizza_runner..cleaned_customer_orders AS t1
JOIN pizza_runner..pizza_names AS t2
ON t1.pizza_id = t2.pizza_id
GROUP BY t1.customer_id, t2.pizza_name
ORDER BY t1.customer_id;

-- 6. What was the maximum number of pizzas delivered in a single order?
WITH number_of_pizza AS (
	SELECT 
		t1.customer_id,
		t1.order_id,
		COUNT (t1.order_id) AS number_of_pizza
	FROM pizza_runner..cleaned_customer_orders t1
	JOIN pizza_runner..cleaned_runner_orders t2
	ON t1.order_id = t2.order_id
	WHERE t2.distance IS NOT NULL
	GROUP BY t1.customer_id, t1.order_id
)

SELECT MAX(number_of_pizza) AS max_number_of_pizza
FROM number_of_pizza;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT t1.customer_id, 
	SUM(
		CASE
			WHEN t1.exclusions <> ' ' OR t1.extras <> ' ' THEN 1
			ELSE 0
			END) AS at_least_1_change,
	SUM(
		CASE
			WHEN t1.exclusions = ' ' AND t1.extras = ' ' THEN 1
			ELSE 0
			END) AS no_change
FROM pizza_runner..cleaned_customer_orders AS t1
JOIN pizza_runner..cleaned_runner_orders AS t2
ON t1.order_id = t2.order_id
WHERE t2.distance IS NOT NULL
GROUP BY t1.customer_id
ORDER BY t1.customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
	SUM(
		CASE
			WHEN t1.exclusions <> ' ' AND t1.extras <> ' ' THEN 1
			ELSE 0 
			END) AS pizza_delivered_with_exclusions_extras
FROM pizza_runner..cleaned_customer_orders AS t1
JOIN pizza_runner..cleaned_runner_orders AS t2
ON t1.order_id = t2.order_id
WHERE t2.distance IS NOT NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT 
    DATEPART(hour, order_time) AS hour_of_day,
    COUNT(order_id) AS total_volume
FROM pizza_runner..cleaned_customer_orders
GROUP BY DATEPART(hour, order_time)
ORDER BY DATEPART(hour, order_time);

-- 10. What was the volume of orders for each day of the week?
SELECT 
    CASE DATEPART(dw, order_time) 
		WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
	END AS day_of_week,
    COUNT(order_id) AS total_volume
FROM pizza_runner..cleaned_customer_orders
GROUP BY DATEPART(dw, order_time)
ORDER BY DATEPART(dw, order_time);

