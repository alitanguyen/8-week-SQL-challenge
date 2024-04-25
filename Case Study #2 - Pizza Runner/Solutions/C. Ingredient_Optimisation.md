# Case Study #2 - Pizza Runner

## C. Ingredient Optimisation

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

4. Create a temporary table named `#exclusions_split` to split the values of `exclusions` into separate rows

```sql
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
```

**Result:**

| order_id | customer_id | pizza_id | exclusions_split | extras | order_time              | orderred_pizza_id |
| -------- | ----------- | -------- | ---------------- | ------ | ----------------------- | ----------------- |
|1 		   | 101         | 1  		|        	       |   	    | 2020-01-01 18:05:02.000 | 1				  |
|2		   | 101         | 1  		|        	       |   	    | 2020-01-01 19:00:52.000 | 2				  |
|3		   | 102         | 1  		|        	       |   	    | 2020-01-02 23:51:23.000 | 3				  |
|3		   | 102         | 2  		|        	       |   	    | 2020-01-02 23:51:23.000 | 4				  |
|4		   | 103         | 1  		| 4      	       |   	    | 2020-01-04 13:23:46.000 | 5				  |
|4		   | 103         | 1  		| 4      	       |   	    | 2020-01-04 13:23:46.000 | 6				  |
|4		   | 103         | 2  		| 4      	       |   	    | 2020-01-04 13:23:46.000 | 7				  |
|5		   | 104         | 1  		|        	       | 1 	    | 2020-01-08 21:00:29.000 | 8				  |
|6		   | 101         | 2  		|        	       |   	    | 2020-01-08 21:03:13.000 | 9				  |
|7		   | 105         | 2  		|        	       | 1 	    | 2020-01-08 21:20:29.000 | 10				  |
|8		   | 102         | 1  		|        	       |   	    | 2020-01-09 23:54:33.000 | 11				  |
|9		   | 103         | 1  		| 4      	       | 1, 5   | 2020-01-10 11:22:59.000 | 12				  |
|10		   | 104         | 1  		|        	       |   	    | 2020-01-11 18:34:49.000 | 13				  |
|10		   | 104         | 1  		| 2      	       | 1, 4   | 2020-01-11 18:34:49.000 | 14				  |
|10		   | 104         | 1  		| 6      	       | 1, 4   | 2020-01-11 18:34:49.000 | 14				  |

<br>

5. Create a temporary table named `#extras_split` to split the values of `extras` into separate rows

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
**Query #1: What are the standard ingredients for each pizza?**

```sql
ALTER TABLE #pizza_recipes_split
ALTER COLUMN topping_name VARCHAR(23);

SELECT 
	t1.pizza_name, 
	STRING_AGG(t2.topping_name,', ') AS standard_ingredients
FROM #pizza_recipes_split AS t2
JOIN pizza_runner..pizza_names AS t1
ON t1.pizza_id = t2.pizza_id
GROUP BY t1.pizza_name;
```

**Answer:**

| pizza_name | standard_ingredients 												 |
| ---------- | --------------------------------------------------------------------- |
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce            |

---

**Query #2: What was the most commonly added extra?**

```sql
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
```

**Answer:**

| topping_name | most_commonly_added_extra |
| ------------ | ------------------------- |
| Bacon        | 4  					   |

---

**Query #3: What was the most common exclusion?**

```sql
SELECT TOP(1)
	t2.topping_name,
	COUNT(t1.exclusions_split) AS most_common_exclusion
FROM #exclusions_split AS t1
JOIN pizza_runner..pizza_toppings AS t2
ON t1.exclusions_split = t2.topping_id
GROUP BY t2.topping_name
ORDER BY COUNT(t1.exclusions_split) DESC;
```

**Answer:**

| topping_name | most_common_exclusion |
| ------------ | --------------------- |
| Cheese        | 4  				   |

---

**Query #4: Generate an order item for each record in the customers_orders table in the format of one of the following:**

- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

**Steps:** 
- Create `cteExclusions`, `cteExtras` and `cteUnion` to combine the data from the result of the first two queries. 
- **LEFT JOIN** the table `cleaned_customer_orders` with the `cteUnion` and **JOIN** with the table `pizza_name`.
- Use the **CONCAT_WS** with **STRING_AGG** to generate an order item for each record followed the given format. 


```sql
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
```
***Answer:**

- `cteExclusion` 

| orderred_pizza_id | pizza_name                  |
| ----------------- | --------------------------- |
| 5                 |Exclude Cheese               |			
| 6                 |Exclude Cheese               |			
| 7                 |Exclude Cheese               |			
| 12                |Exclude Cheese               | 			
| 14                |Exclude BBQ Sauce, Mushrooms |			
			
- `cteExtras`

| orderred_pizza_id | pizza_name            |
| ----------------- | --------------------- |
|8 		            | Extra Bacon			|
|10 				| Extra Bacon			|
|12 				| Extra Bacon, Chicken  |
|14 				| Extra Bacon, Cheese   |


- `cteUnion`

| orderred_pizza_id | pizza_name                   |
| ----------------- | ---------------------------- |
|5	 				| Exclude Cheese    		   |
|6	 				| Exclude Cheese    		   | 
|7	 				| Exclude Cheese    		   | 
|8	 				| Extra Bacon    		       | 
|10	  				| Extra Bacon    		       | 
|12	  				| Exclude Cheese    		   | 
|12	  				| Extra Bacon, Chicken    	   | 
|14	  				| Exclude BBQ Sauce, Mushrooms | 
|14	  				| Extra Bacon, Cheese    	   | 

| order_id | customer_id | pizza_id | exclusions | extras | orderred_pizza_id | pizza_list |
| -------- | ----------- | -------- | ---------- | ------ | ----------------  | ---------- |
| 1        | 101         | 1        |            |        | 1 				  | Meatlovers | 							
| 2        | 101         | 1        |            |        | 2 				  | Meatlovers | 								
| 3        | 102         | 1        |            |        | 3 				  | Meatlovers | 								
| 3        | 102         | 2        |            |        | 4 				  | Vegetarian | 								
| 4        | 103         | 1        | 4          |        | 5 				  | Meatlovers - Exclude Cheese |  							
| 4        | 103         | 1        | 4          |        | 6 				  | Meatlovers - Exclude Cheese |  							
| 4        | 103         | 2        | 4          |        | 7 				  | Vegetarian - Exclude Cheese |  							
| 5        | 104         | 1        |            | 1      | 8 				  | Meatlovers - Extra Bacon |  							
| 6        | 101         | 2        |            |        | 9 				  | Vegetarian | 			
| 7        | 105         | 2        |            | 1      | 10 				  | Vegetarian - Extra Bacon |  							
| 8        | 102         | 1        |            |        | 11 				  | Meatlovers | 			
| 9        | 103         | 1        | 4          | 1, 5   | 12 				  | Meatlovers - Exclude Cheese - Extra Bacon, Chicken |  								
| 10       | 104         | 1        |            |        | 13 				  | Meatlovers | 			
| 10       | 104         | 1        | 2, 6       | 1, 4   | 14 				  | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |  						


**Query #5: Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients**
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

---

**Query #6: What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?**

---

