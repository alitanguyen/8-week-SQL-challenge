/* --------------------
Case Study #1 - Danny's Diner
   --------------------*/
-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	sales.customer_id,
	SUM(menu.price) AS total_sales
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id
ORDER BY sales.customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT 
	sales.customer_id,
	COUNT (DISTINCT(order_date)) AS number_of_visit
FROM sales
GROUP BY customer_id
ORDER BY customer_id;

-- 3. What was the first item from the menu purchased by each customer? 
WITH t1 AS 
(
SELECT 
	sales.customer_id,
	sales.order_date, 
	menu.product_name,
	DENSE_RANK () OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS date_rank
FROM sales
JOIN menu
ON sales.product_id = menu.product_id
)

SELECT 
	customer_id, 
	product_name
FROM t1
WHERE date_rank = 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT TOP(1)
	menu.product_name, 
    COUNT(sales.product_id) AS most_purchased_item
FROM menu
JOIN sales
ON sales.product_id = menu.product_id
GROUP BY menu.product_name
ORDER BY most_purchased_item DESC


-- 5. Which item was the most popular for each customer?
WITH t1 AS 
(
SELECT 
	sales.customer_id, 
	menu.product_name, 
	COUNT(sales.product_id) AS order_count,
	DENSE_RANK () OVER (PARTITION BY sales.customer_id ORDER BY COUNT(sales.product_id) DESC) AS order_rank
FROM menu
JOIN sales
ON sales.product_id = menu.product_id
GROUP BY sales.customer_id, menu.product_name
)

SELECT
	customer_id, 
	product_name, 
	order_count
FROM t1
WHERE order_rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH t1 AS
(
SELECT	
	members.customer_id, 
	sales.order_date, 
	menu.product_name,
	DENSE_RANK () OVER (PARTITION BY members.customer_id ORDER BY sales.order_date) AS date_rank
FROM members
JOIN sales
ON members.customer_id = sales.customer_id
JOIN menu
ON sales.product_id = menu.product_id
WHERE sales.order_date > members.join_date
)

SELECT
	customer_id, 
	product_name
FROM t1
WHERE date_rank = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH t1 AS
(
SELECT 
	members.customer_id, 
	menu.product_name,
	DENSE_RANK () OVER (PARTITION BY members.customer_id ORDER BY sales.order_date DESC) AS date_rank
FROM members
JOIN sales
ON members.customer_id = sales.customer_id
JOIN menu
ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
)

SELECT 
	customer_id, 
	product_name
FROM t1
WHERE date_rank = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	members.customer_id, 
	COUNT(sales.product_id) AS total_items, 
	SUM(menu.price) AS total_sales
FROM members
JOIN sales
ON members.customer_id = sales.customer_id
JOIN menu
ON sales.product_id = menu.product_id
WHERE sales.order_date < members.join_date
GROUP BY members.customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH t1 AS
(
SELECT 
	sales.customer_id, 
	menu.product_name, 
	COUNT(sales.product_id) AS total_items, 
	SUM(menu.price) AS total_sales
FROM sales
JOIN menu
ON menu.product_id = sales.product_id
GROUP BY sales.customer_id, menu.product_name
) 

SELECT customer_id,
SUM(CASE 
		WHEN product_name = 'sushi' THEN total_sales * 20
		ELSE total_sales * 10
	END) AS total_points
FROM t1
GROUP BY customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH t1 AS (
SELECT 
	members.customer_id, 
	members.join_date, 
	sales.order_date, 
	menu.product_name, 
	COUNT(sales.product_id) AS sales_count,
	SUM(menu.price) AS total_sales,
	CASE 
		WHEN sales.order_date BETWEEN members.join_date AND DATEADD(day, 6, members.join_date) THEN SUM(menu.price) * 20
		WHEN menu.product_name = 'sushi' THEN SUM(menu.price) * 20
		ELSE SUM(menu.price) * 10
		END AS points
FROM members
JOIN sales
ON members.customer_id = sales.customer_id
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY members.customer_id, members.join_date, sales.order_date, menu.product_name
)

SELECT 
    customer_id,
    SUM(points) AS total_points
FROM t1
WHERE order_date <= '2021-01-31'  
GROUP BY customer_id;


