# Case Study #2 - Pizza Runner

## D. Pricing and Ratings

### DATA CLEANING
1. Alter the data type of column `toppings` (TEXT) in table `pizza_recipes` to the correct data type 

```sql
ALTER TABLE pizza_runner..pizza_recipes
ALTER COLUMN toppings VARCHAR(23);
```
<br>

2. Create a temporary table named `#pizza_recipes_split` to split the values of `toppings` into separate rows

```sql
DROP TABLE IF EXISTS #pizza_recipes_split;
SELECT	
	t1.pizza_id,
	value AS topping_id,
	t3.topping_name
INTO #pizza_recipes_split
FROM pizza_runner..pizza_recipes AS t1
CROSS APPLY 
	 STRING_SPLIT(t1.toppings, ',') AS t2
JOIN pizza_runner..pizza_toppings AS t3
ON value = t3.topping_id;

SELECT *
FROM #pizza_recipes_split;
```
**Result:**

| pizza_id | topping_id | topping_name |
| -------- | ---------- | ------------ |
| 1        | 1    		| Bacon		   |
| 1        | 2  		| BBQ Sauce	   |
| 1        | 3  		| Beef		   |
| 1        | 4  		| Cheese	   |
| 1        | 5  		| Chicken	   |
| 1        | 6  		| Mushrooms	   |
| 1        | 8  		| Pepperoni	   |
| 1        | 10  		| Salami	   |
| 2        | 4  		| Cheese	   |
| 2        | 6  		| Mushrooms	   |
| 2        | 7  		| Onions	   |
| 2        | 9  		| Peppers	   |
| 2        | 11  		| Tomatoes	   |
| 2        | 12  		| Tomato Sauce |

<br>

3. Add a column named `#orderred_pizza_id` to `cleaned_customer_orders` in order to separate each orderred pizza 

```sql
ALTER TABLE pizza_runner..cleaned_customer_orders
ADD orderred_pizza_id INT IDENTITY(1,1);

SELECT * 
FROM pizza_runner..cleaned_customer_orders;
```

**Result:**

| order_id | customer_id | pizza_id | exclusions | extras | order_time              | orderred_pizza_id |
| -------- | ----------- | -------- | ---------- | ------ | ----------------------- | ----------------- |
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02.000 | 1 				|
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52.000 | 2 				| 
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23.000 | 3 				| 
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23.000 | 4 				| 
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 5 				| 
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 6 				| 
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46.000 | 7 				| 
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29.000 | 8 				|
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13.000 | 9 				|
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29.000 | 10 				|
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33.000 | 11 				|
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59.000 | 12 				|
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49.000 | 13 				|
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49.000 | 14 				|

<br>

4. Create a temporary table named `#extras_split` to split the values of `extras` into separate rows

```sql
DROP TABLE IF EXISTS #extras_split;
SELECT 
	order_id,
	customer_id, 
	pizza_id,
	exclusions,
	value AS extras_split,
	order_time,
	orderred_pizza_id
INTO #extras_split
FROM pizza_runner..cleaned_customer_orders 
CROSS APPLY 
	STRING_SPLIT(extras, ',');

SELECT *
FROM #extras_split;
```
**Result:**

| order_id | customer_id | pizza_id | exclusions | extras_split | order_time              | orderred_pizza_id |
| -------- | ----------- | -------- | ---------- | ------------ | ----------------------- | ----------------- |
| 1 	   | 101         | 1        |   	     |   			| 2020-01-01 18:05:02.000 | 1 				  |
| 2 	   | 101         | 1        |   	     |   			| 2020-01-01 19:00:52.000 | 2 				  | 
| 3 	   | 102         | 1        |   	     |   			| 2020-01-02 23:51:23.000 | 3 				  | 
| 3 	   | 102         | 2        |   	     |   			| 2020-01-02 23:51:23.000 | 4 				  | 
| 4 	   | 103         | 1        | 4 	     |   			| 2020-01-04 13:23:46.000 | 5 				  | 
| 4 	   | 103         | 1        | 4 	     |   			| 2020-01-04 13:23:46.000 | 6 				  | 
| 4 	   | 103         | 2        | 4 	     |   			| 2020-01-04 13:23:46.000 | 7 				  | 
| 5 	   | 104         | 1        |   	     | 1 			| 2020-01-08 21:00:29.000 | 8 				  | 
| 6 	   | 101         | 2        |   	     |   			| 2020-01-08 21:03:13.000 | 9 				  | 
| 7 	   | 105         | 2        |   	     | 1 			| 2020-01-08 21:20:29.000 | 10 				  | 
| 8 	   | 102         | 1        |   	     |   			| 2020-01-09 23:54:33.000 | 11 				  | 
| 9 	   | 103         | 1        | 4 	     | 1 			| 2020-01-10 11:22:59.000 | 12 				  | 
| 9 	   | 103         | 1        | 4 	     | 5 			| 2020-01-10 11:22:59.000 | 12 				  | 
| 10 	   | 104         | 1        |   	     |   			| 2020-01-11 18:34:49.000 | 13 				  | 
| 10 	   | 104         | 1        | 2, 6 	     | 1 			| 2020-01-11 18:34:49.000 | 14 				  | 
| 10 	   | 104         | 1        | 2, 6 	     | 4 			| 2020-01-11 18:34:49.000 | 14 				  | 

### SOLUTIONS
**Query #1: If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?**

```sql
WITH pizza_type AS (
	SELECT 
		t2.pizza_name, 
		COUNT(t1.pizza_id) AS number_of_pizza 
	FROM pizza_runner..cleaned_customer_orders AS t1
	JOIN pizza_runner..pizza_names AS t2
	ON t1.pizza_id = t2.pizza_id
	JOIN pizza_runner..cleaned_runner_orders AS t3
	ON t1.order_id = t3.order_id
	WHERE t3.cancellation IS NULL
	GROUP BY t2.pizza_name
	
)

SELECT 
	SUM(
		CASE 
			WHEN pizza_type.pizza_name = 'Meatlovers' THEN number_of_pizza * 12
			ELSE number_of_pizza * 10 
		END) AS total_money
FROM pizza_type;
```

**Answer:**

| total_money |
| ----------- |
| 138 		  |

---

**Query #2: What if there was an additional $1 charge for any pizza extras?**
- Add cheese is $1 extra

```sql
WITH pizza_type AS (
	SELECT 
		t2.pizza_name, 
		COUNT(t1.pizza_id) AS number_of_pizza 
	FROM pizza_runner..cleaned_customer_orders AS t1
	JOIN pizza_runner..pizza_names AS t2
	ON t1.pizza_id = t2.pizza_id
	JOIN pizza_runner..cleaned_runner_orders AS t3
	ON t1.order_id = t3.order_id
	WHERE t3.cancellation IS NULL
	GROUP BY t2.pizza_name
),

pizza_total AS (
	SELECT 
		SUM(
			CASE 
				WHEN pizza_type.pizza_name = 'Meatlovers' THEN number_of_pizza * 12
				ELSE number_of_pizza * 10 
			END) AS total_money
	FROM pizza_type
),

extras_total AS (
	SELECT
		SUM( 
			CASE
				WHEN t2.topping_name = 'Cheese' THEN 2
				ELSE 1 
			END) AS additional_charge
	FROM #extras_split AS t1
	JOIN pizza_runner..pizza_toppings AS t2
	ON t1.extras_split = t2.topping_id
) 

SELECT 
    (pt.total_money + et.additional_charge) AS grand_total
FROM 
    pizza_total AS pt,
    extras_total AS et;
```
**Answer:**

| grand_total |
| ----------- |
| 145 		  |

---

**Query #3: The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset. Generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.**

```sql
DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
	order_id INT,
	rating INT
);

INSERT INTO ratings ("order_id", "rating")
VALUES
('1', '3'),
('2', '5'),
('3', '3'),
('4', '1'),
('5', '5'),
('7', '3'),
('8', '4'),
('10', '3');

SELECT * 
FROM ratings;
```
**Answer:**

| order_id | rating |
| -------- | ------	|
| 1 	   | 3      |
| 2 	   | 5      |  
| 3 	   | 3      |  
| 4 	   | 1      |  
| 5 	   | 5      |  
| 7 	   | 3      |  
| 8 	   | 4      |  
| 10 	   | 3      |  

---

**Query #4: Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?**
- customer_id
- order_id
- runner_id
- rating
- order_time
- pickup_time
- Time between order and pickup
- Delivery duration
- Average speed
- Total number of pizzas

```sql
SELECT 
	t1.customer_id, 
	t1.order_id,
	t2.runner_id,
	t1.order_time, 
	t2.pickup_time, 
	DATEDIFF(MINUTE, t1.order_time, t2.pickup_time) AS time_difference,
	t2.duration, 
	ROUND(AVG((t2.distance/t2.duration)*60),2) AS avg_speed,
	COUNT(t1.order_id) AS total_number_of_pizza
FROM pizza_runner..cleaned_customer_orders AS t1
JOIN pizza_runner..cleaned_runner_orders AS t2
ON t1.order_id = t2.order_id
GROUP BY 
	t1.customer_id, 
	t1.order_id,
	t2.runner_id,
	t1.order_time, 
	t2.pickup_time, 
	t2.duration;
```
**Answer:**

| order_id | runner_id | order_time              | customer_id | pickup_time             | time_difference | duration | avg_speed | total_number_of_pizza |
| :------- | :-------- | :---------------------- | :---------- | :---------------------- | :-------------- | :------- | :-------- | :-------------------- |
| 1        | 1         | 2020-01-01 18:05:02.000 | 101         | 2020-01-01 18:15:34.000 | 10              | 32       | 37.5      | 1                     |
| 2        | 1         | 2020-01-01 19:00:52.000 | 101         | 2020-01-01 19:10:54.000 | 10              | 27       | 44.44     | 1                     |
| 6        | 3         | 2020-01-08 21:03:13.000 | 101         | NULL                    | NULL            | NULL     | NULL      | 1                     |
| 3        | 1         | 2020-01-02 23:51:23.000 | 102         | 2020-01-03 00:12:37.000 | 21              | 20       | 40.2      | 2                     |
| 8        | 2         | 2020-01-09 23:54:33.000 | 102         | 2020-01-10 00:15:02.000 | 21              | 15       | 93.6      | 1                     |
| 4        | 2         | 2020-01-04 13:23:46.000 | 103         | 2020-01-04 13:53:03.000 | 30              | 40       | 35.1      | 3                     |
| 9        | 2         | 2020-01-10 11:22:59.000 | 103         | NULL                    | NULL            | NULL     | NULL      | 1                     |
| 5        | 3         | 2020-01-08 21:00:29.000 | 104         | 2020-01-08 21:10:57.000 | 10              | 15       | 40        | 1                     |
| 10       | 1         | 2020-01-11 18:34:49.000 | 104         | 2020-01-11 18:50:20.000 | 16              | 10       | 60        | 2                     |
| 7        | 2         | 2020-01-08 21:20:29.000 | 105         | 2020-01-08 21:30:45.000 | 10              | 25       | 60        | 1                     |

---

**Query #5: If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled. How much money does Pizza Runner have left over after these deliveries?**

```sql
WITH pizza_type AS (
	SELECT 
		t2.pizza_name, 
		COUNT(t1.pizza_id) AS number_of_pizza 
	FROM pizza_runner..cleaned_customer_orders AS t1
	JOIN pizza_runner..pizza_names AS t2
	ON t1.pizza_id = t2.pizza_id
	JOIN pizza_runner..cleaned_runner_orders AS t3
	ON t1.order_id = t3.order_id
	WHERE t3.cancellation IS NULL
	GROUP BY t2.pizza_name
),

pizza_total AS (
	SELECT 
		SUM(
			CASE 
				WHEN pizza_type.pizza_name = 'Meatlovers' THEN number_of_pizza * 12
				ELSE number_of_pizza * 10 
			END) AS total_money
	FROM pizza_type
),

runner_paid AS (
	SELECT 
		runner_id, 
		SUM(distance) * 0.30 AS runner_cost  
	FROM pizza_runner..cleaned_runner_orders 
	WHERE distance IS NOT NULL 
	GROUP BY runner_id
)

SELECT 
	(pt.total_money - SUM(rp.runner_cost)) AS money_left 
FROM 
	pizza_total AS pt, 
	runner_paid AS rp
GROUP BY pt.total_money;
```

**Answer:**

| money_left |
| :--------- |
| 94.44      |

