/* --------------------
Case Study #2 - Pizza Runner
   --------------------*/
-- C. Ingredient Optimisation
-- DATA CLEANING
-- 1. Alter the data type of column `toppings` (TEXT) in table `pizza_recipes` to the correct data type 
ALTER TABLE pizza_runner..pizza_recipes
ALTER COLUMN toppings VARCHAR(23);

-- 2. Create a temporary table named `#pizza_recipes_split` to split the values of `toppings` into separate rows
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

-- 3. Add a column named `#orderred_pizza_id` to `cleaned_customer_orders` in order to separate each orderred pizza 
ALTER TABLE pizza_runner..cleaned_customer_orders
ADD orderred_pizza_id INT IDENTITY(1,1);

SELECT * 
FROM pizza_runner..cleaned_customer_orders;

-- 4. Create a temporary table named `#exclusions_split` to split the values of `exclusions` into separate rows
DROP TABLE IF EXISTS #exclusions_split;
SELECT 
	order_id,
	customer_id, 
	pizza_id,
	value AS exclusions_split,
	extras,
	order_time,
	orderred_pizza_id
INTO #exclusions_split
FROM pizza_runner..cleaned_customer_orders 
CROSS APPLY 
	STRING_SPLIT(exclusions, ',');

SELECT *
FROM #exclusions_split;

-- 5. Create a temporary table named `#extras_split` to split the values of `extras` into separate rows
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

-- SOLUTIONS
-- 1. What are the standard ingredients for each pizza?
ALTER TABLE #pizza_recipes_split
ALTER COLUMN topping_name VARCHAR(23);

SELECT 
	t1.pizza_name, 
	STRING_AGG(t2.topping_name,', ') AS standard_ingredients
FROM #pizza_recipes_split AS t2
JOIN pizza_runner..pizza_names AS t1
ON t1.pizza_id = t2.pizza_id
GROUP BY t1.pizza_name;

-- 2. What was the most commonly added extra?
ALTER TABLE #extras_split
ALTER COLUMN extras_split INT;

ALTER TABLE pizza_runner..pizza_toppings
ALTER COLUMN topping_name VARCHAR(23);

SELECT TOP(1)
	t2.topping_name,
	COUNT(t1.extras_split) AS most_commonly_added_extra
FROM #extras_split AS t1
JOIN pizza_runner..pizza_toppings AS t2
ON t1.extras_split = t2.topping_id
GROUP BY t2.topping_name
ORDER BY COUNT(t1.extras_split) DESC;

-- 3. What was the most common exclusion?
SELECT TOP(1)
	t2.topping_name,
	COUNT(t1.exclusions_split) AS most_common_exclusion
FROM #exclusions_split AS t1
JOIN pizza_runner..pizza_toppings AS t2
ON t1.exclusions_split = t2.topping_id
GROUP BY t2.topping_name
ORDER BY COUNT(t1.exclusions_split) DESC;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH cteExclusion AS (
	SELECT 
		t1.orderred_pizza_id,
		'Exclude ' + STRING_AGG (t2.topping_name,', ') AS pizza_name
	FROM #exclusions_split AS t1
	JOIN pizza_runner..pizza_toppings AS t2
	ON t1.exclusions_split = t2.topping_id
	GROUP BY t1.orderred_pizza_id
),

cteExtras AS (
	SELECT 
		t1.orderred_pizza_id,
		'Extra ' + STRING_AGG (t2.topping_name,', ') AS pizza_name
	FROM #extras_split AS t1
	JOIN pizza_runner..pizza_toppings AS t2
	ON t1.extras_split = t2.topping_id
	GROUP BY t1.orderred_pizza_id
),

cteUnion AS (
	SELECT *
	FROM cteExtras
	UNION 
	SELECT * 
	FROM cteExclusion
)
	
SELECT 
	t1.order_id,
	t1.customer_id,
	t1.pizza_id,
	t1.exclusions, 
	t1.extras,  
	t1.orderred_pizza_id, 
	CONCAT_WS(' - ', t3.pizza_name, STRING_AGG(t2.pizza_name, ' - ')) AS pizza_list
FROM pizza_runner..cleaned_customer_orders AS t1
LEFT JOIN cteUnion AS t2
ON t1.orderred_pizza_id = t2.orderred_pizza_id
JOIN pizza_runner..pizza_names AS t3
ON t1.pizza_id = t3.pizza_id
GROUP BY 
	t1.order_id,
	t1.customer_id,
	t1.pizza_id,
	t1.exclusions, 
	t1.extras,  
	t1.orderred_pizza_id, 
	t3.pizza_name;

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
