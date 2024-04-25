# Case Study #2 - Pizza Runner

## DATA CLEANING

I found out some data type issues in certain columns that need to be addressed and cleaned before being used in my queries.

**Table 2: customer_orders**

- There are some blank spaces ' '.
- Both `NaN` and `null` values are used.
- `null` values are entered as both text and data type.

**Solution:**

- Create a new table named `#cleaned_customer_orders`.
- Replace all `NaN` and `null` values in `exclusions` and `extras` with blank space ' ' .

```sql
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
```
**Result:**

| order_id | customer_id | pizza_id | exclusions | extras | order_time              |
| -------- | ----------- | -------- | ---------- | ------ | ----------------------- |
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02.000 |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52.000 | 
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23.000 | 
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23.000 | 
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46.000 | 
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29.000 |
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13.000 |
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29.000 |
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33.000 |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59.000 |
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49.000 |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49.000 |

<br>

**Table 3: runner_orders**

- There are some blank spaces ' '.
- Both `NaN` and `null` values are used.
- `null` values are entered as both text and data type.
- Units with different formats are manually entered in `distance` and `duration`.

**Solution:**

- Create a new table named `#cleaned_runner_orders`.
- Replace all `NaN` and `null` text values in `pickup_time`, `distance`, `duration` and `cancellation` with blank space ' '.
- Remove "km" in `distance`, "minutes" and "mins" in `duration`.
- Cast `pickup_time`, `distance` and `duration` to the correct data type.
    - Cast `pickup_time` to DATETIME.
    - Cast `distance` to FLOAT.
    - Cast `duration` to INT.

```sql
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
```

**Result:**
| order_id | runner_id | pickup_time             | distance | duration | cancellation             |
| -------- | --------- | ----------------------- | -------- | -------- | -----------------------  |
| 1        | 1         | 2020-01-01 18:15:34.000 | 20       |32        | NULL    				  | 
| 2  	   | 1         | 2020-01-01 19:10:54.000 | 20       |27        | NULL    				  |
| 3  	   | 1         | 2020-01-03 00:12:37.000 | 13.4     |20        | NULL    				  |
| 4  	   | 2         | 2020-01-04 13:53:03.000 | 23.4     |40        | NULL    				  |
| 5  	   | 3         | 2020-01-08 21:10:57.000 | 10       |15        | NULL    				  |
| 6  	   | 3         | NULL                    | NULL     |NULL      | Restaurant Cancellation  |
| 7  	   | 2         | 2020-01-08 21:30:45.000 | 25       |25        | NULL    				  |
| 8  	   | 2         | 2020-01-10 00:15:02.000 | 23.4     |15        | NULL    				  |
| 9  	   | 2         | NULL                    | NULL     |NULL      | Customer Cancellation    |
| 10       | 1         | 2020-01-11 18:50:20.000 | 10       |10        | NULL    				  |

