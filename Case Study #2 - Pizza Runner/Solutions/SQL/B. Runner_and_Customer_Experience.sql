/* --------------------
Case Study #2 - Pizza Runner
   --------------------*/
--B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT 
	DATEPART(week, registration_date) AS registration_week,
	COUNT(runner_id) AS runner_signup
FROM pizza_runner..runners
GROUP BY DATEPART(WEEK, registration_date);

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH t3 AS (
	SELECT 
		t1.order_id, 
		t1.order_time,
		t2.pickup_time, 
		DATEDIFF(second, t1.order_time, t2.pickup_time) AS runner_arrival_time_second
FROM pizza_runner..cleaned_customer_orders AS t1
JOIN pizza_runner..cleaned_runner_orders AS t2
ON t1.order_id = t2.order_id
WHERE t2.pickup_time IS NOT NULL
GROUP BY t1.order_id, t1.order_time, t2.pickup_time
)

SELECT 
	AVG(runner_arrival_time_second/60) AS avg_pickup_time_mins
FROM t3;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH t3 AS (
	SELECT
		t1.order_id,
		COUNT(t1.order_id) AS number_of_pizza,
		t1.order_time,
		t2.pickup_time, 
		DATEDIFF(second, t1.order_time, t2.pickup_time) AS prep_time_second
FROM pizza_runner..cleaned_customer_orders AS t1
JOIN pizza_runner..cleaned_runner_orders AS t2
ON t1.order_id = t2.order_id
WHERE t2.pickup_time IS NOT NULL
GROUP BY t1.order_id, t1.order_time, t2.pickup_time
)

SELECT 
	number_of_pizza,
	AVG(prep_time_second/60) AS avg_prep_time_min
FROM t3
GROUP BY number_of_pizza;

-- 4. What was the average distance travelled for each customer?
SELECT 
	t2.customer_id,
	ROUND(AVG(t1.distance),2) AS avg_distance
FROM pizza_runner..cleaned_runner_orders AS t1
JOIN pizza_runner..cleaned_customer_orders AS t2
ON t1.order_id = t2.order_id
GROUP BY t2.customer_id
ORDER BY t2.customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT 
	MAX(duration)AS longest_delivery_time,
	MIN(duration) AS shortest_delivery_time,
	MAX(duration) - MIN(duration) AS difference
FROM pizza_runner..cleaned_runner_orders;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT 
	runner_id,
	order_id,
	distance, 
	duration, 
	ROUND(AVG((distance/duration)*60),2) AS avg_speed_km_per_hour
FROM pizza_runner..cleaned_runner_orders
WHERE distance != 0
GROUP BY runner_id, order_id, distance, duration
ORDER BY runner_id;

-- 7. What is the successful delivery percentage for each runner?
WITH t1 AS (
	SELECT 
		runner_id,
		COUNT(order_id) AS total_order
	FROM pizza_runner..cleaned_runner_orders
	GROUP BY runner_id
),

t2 AS (
	SELECT 
		runner_id,
		COUNT(order_id) AS successful_orders
	FROM pizza_runner..cleaned_runner_orders
	WHERE distance IS NOT NULL
	GROUP BY runner_id
)

SELECT 
	t1.runner_id,
    COALESCE((t2.successful_orders * 100 / t1.total_order), 0) AS successful_delivery_percentage
FROM t1
JOIN t2
ON t1.runner_id = t2.runner_id;
