/* --------------------
Case Study #2 - Pizza Runner
   --------------------*/
--B. Bonus Questions
-- If Danny wants to expand his range of pizzas - how would this impact the existing data design? 
-- Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu.

-- Insert a new Supreme pizza into table `pizza_names`
INSERT INTO pizza_runner..pizza_names (pizza_id, pizza_name)
VALUES
(3, 'Supreme')

SELECT *
FROM pizza_runner..pizza_names

-- Insert toppings of a new Supreme pizza into table `pizza_recipes`
ALTER TABLE pizza_runner..pizza_recipes
ALTER COLUMN toppings VARCHAR(39);

INSERT INTO pizza_runner..pizza_recipes (pizza_id, toppings) 
VALUES
(3, '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12')

SELECT *
FROM pizza_runner..pizza_recipes







