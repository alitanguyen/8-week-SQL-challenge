
# Case Study #2 - Pizza Runner

<img src="Cover.png" alt="Cover" width="350" height="350">

## Table of contents
- [Introduction](#introduction)
- [Dataset](#dataset)
- [Entity Relationship Diagram](#entity-relationship-diagram)
- [Questions and Solutions](#questions-and-solutions)
   - [Data Cleaning](#data-cleaning)
   - [A. Pizza Metrics](#a-pizza-metrics)
   - [B. Runner and Customer Experience](#b-runner-and-customer-experience)
   - [C. Ingredient Optimisation](#c-ingredient-optimisation)
   - [D. Pricing and Ratings](#d-pricing-and-ratings)
   - [E. Bonus Questions](#e-bonus-questions)

This case study is available on the challenge [website](https://8weeksqlchallenge.com/case-study-2/).

<a id="introduction"></a>
## **INTRODUCTION**

Danny was expanding his new Pizza Empire. But he knew that pizza alone was not going to help him get seed funding, so he had one more genius idea to combine with it - he was going to *Uberize* it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

<a id="business-task"></a>
## **BUSINESS TASK**

Danny requires further assistance to clean the data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

<a id="dataset"></a>
## **DATASET**

There are 6 key datasets for this case study:

### **```runners```**
<details>
<summary>
View table
</summary>

The runners table shows the **```registration_date```** for each new runner.


|runner_id|registration_date|
|---------|-----------------|
|1        |2021-01-01       |
|2        |2021-01-03       |
|3        |2021-01-08       |
|4        |2021-01-15       |

</details>


### **```customer_orders```**

<details>
<summary>
View table
</summary>

Customer pizza orders are captured in the **```customer_orders```** table with 1 row for each individual pizza that is part of the order.

The pizza_id relates to the type of pizza which was ordered whilst the exclusions are the ingredient_id values which should be removed from the pizza and the extras are the ingredient_id values which need to be added to the pizza.

|order_id|customer_id|pizza_id|exclusions|extras|order_time          |
|--------|-----------|--------|----------|------|--------------------|
|1       |101        |1       |          |      |2021-01-01 18:05:02 |
|2       |101        |1       |          |      |2021-01-01 19:00:52 |
|3       |102        |1       |          |      |2021-01-02 23:51:23 |
|3       |102        |2       |          |NaN   |2021-01-02 23:51:23 |
|4       |103        |1       |4         |      |2021-01-04 13:23:46 |
|4       |103        |1       |4         |      |2021-01-04 13:23:46 |
|4       |103        |2       |4         |      |2021-01-04 13:23:46 |
|5       |104        |1       |null      |1     |2021-01-08 21:00:29 |
|6       |101        |2       |null      |null  |2021-01-08 21:03:13 |
|7       |105        |2       |null      |1     |2021-01-08 21:20:29 |
|8       |102        |1       |null      |null  |2021-01-09 23:54:33 |
|9       |103        |1       |4         |1, 5  |2021-01-10 11:22:59 |
|10      |104        |1       |null      |null  |2021-01-11 18:34:49 |
|10      |104        |1       |2, 6      |1, 4  |2021-01-11 18:34:49 |

</details>

### **```runner_orders```**

<details>
<summary>
View table
</summary>

After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.

The **```pickup_time```** is the timestamp at which the runner arrives at the Pizza Runner headquarters to pick up the freshly cooked pizzas. 

The **```distance```** and **```duration```** fields are related to how far and long the runner had to travel to deliver the order to the respective customer.



|order_id|runner_id|pickup_time        |distance  |duration  |cancellation           |
|--------|---------|-------------------|----------|----------|-----------------------|
|1       |1        |2021-01-01 18:15:34|20km      |32 minutes|                       |
|2       |1        |2021-01-01 19:10:54|20km      |27 minutes|                       |
|3       |1        |2021-01-03 00:12:37|13.4km    |20 mins   |NaN                    |
|4       |2        |2021-01-04 13:53:03|23.4      |40        |NaN                    |
|5       |3        |2021-01-08 21:10:57|10        |15        |NaN                    |
|6       |3        |null               |null      |null      |Restaurant Cancellation|
|7       |2        |020-01-08 21:30:45 |25km      |25mins    |null                   |
|8       |2        |2020-01-10 00:15:02|23.4 km   |15 minute |null                   |
|9       |2        |null               |null      |null      |Customer Cancellation  |
|10      |1        |2020-01-11 18:50:20|10km      |10minutes |null                   |

</details>

### **```pizza_names```**

<details>
<summary>
View table
</summary>

|pizza_id|pizza_name |
|--------|-----------|
|1       |Meat Lovers|
|2       |Vegetarian |

</details>

### **```pizza_recipes```**

<details>
<summary>
View table
</summary>

Each **```pizza_id```** has a standard set of **```toppings```** which are used as part of the pizza recipe.


|pizza_id|toppings               |
|--------|-----------------------|
|1       |1, 2, 3, 4, 5, 6, 8, 10| 
|2       |4, 6, 7, 9, 11, 12     | 

</details>

### **```pizza_toppings```**

<details>
<summary>
View table
</summary>

This table contains all of the **```topping_name```** values with their corresponding **```topping_id```** value.


|topping_id|topping_name|
|----------|------------|
|1         |Bacon       | 
|2         |BBQ Sauce   | 
|3         |Beef        |  
|4         |Cheese      |  
|5         |Chicken     |     
|6         |Mushrooms   |  
|7         |Onions      |     
|8         |Pepperoni   | 
|9         |Peppers     |   
|10        |Salami      | 
|11        |Tomatoes    | 
|12        |Tomato Sauce|

</details>

<a id="entity-relationship-diagram"></a>
## **ENTITY RELATIONSHIP DIAGRAM**
<img src="ERD.png" alt="ERD" width="600" height="400">

<a id="questions-and-solutions"></a>
## QUESTIONS AND SOLUTIONS

***All of my queries were executed using Microsoft SQL v19.2.***
### Data Cleaning 
I found out some data type issues in certain columns that need to be addressed and cleaned before being used in my queries.

View my solution [HERE](https://github.com/alitanguyen/8-week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solutions/Data_Cleaning.md).

### A. Pizza Metrics
View my solution [HERE](https://github.com/alitanguyen/8-week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solutions/A.%20Pizza_Metrics.md).

- How many pizzas were ordered?
- How many unique customer orders were made?
- How many successful orders were delivered by each runner?
- How many of each type of pizza was delivered?
- How many Vegetarian and Meatlovers were ordered by each customer?
- What was the maximum number of pizzas delivered in a single order?
- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
- How many pizzas were delivered that had both exclusions and extras?
- What was the total volume of pizzas ordered for each hour of the day?
- What was the volume of orders for each day of the week?

### B. Runner and Customer Experience
View my solution [HERE](https://github.com/alitanguyen/8-week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solutions/B.%20Runner_and_Customer_Experience.md).

- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
- Is there any relationship between the number of pizzas and how long the order takes to prepare?
- What was the average distance travelled for each customer?
- What was the difference between the longest and shortest delivery times for all orders?
- What was the average speed for each runner for each delivery and do you notice any trend for these values?
- What is the successful delivery percentage for each runner?

### C. Ingredient Optimisation
View my solution [HERE](https://github.com/alitanguyen/8-week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solutions/C.%20Ingredient_Optimisation.md).

- What are the standard ingredients for each pizza?
- What was the most commonly added extra?
- What was the most common exclusion?
- Generate an order item for each record in the customers_orders table in the format of one of the following:
  - Meat Lovers
  - Meat Lovers - Exclude Beef
  - Meat Lovers - Extra Bacon
  - Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
- Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
  - For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
- What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

### D. Pricing and Ratings
View my solution [HERE](https://github.com/alitanguyen/8-week-SQL-challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solutions/D.%20Pricing_and%20_Ratings.md).

- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
- What if there was an additional $1 charge for any pizza extras?
    - Add cheese is $1 extra
- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
- Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
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
- If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

### E. Bonus Questions
View my solution HERE.

If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?




