/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
--  will use count function of customers and grop by their state
SELECT state,count(customer_id) "no. of customers" from customer_t group by state;
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. 

Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
-- with coordination of CTE will summurize customer rating by creating num values and then avr them accor. to each quarter
WITH feedback_sel as ( 
SELECT 
quarter_number, 
CASE WHEN (customer_feedback) = 'Very Good' THEN 5 
WHEN (customer_feedback) = 'Good'  THEN 4
WHEN (customer_feedback) = 'Okay'  THEN 3
WHEN (customer_feedback) = 'bad'  THEN 2
WHEN (customer_feedback) = 'Very bad'  THEN 1
END rating 
FROM order_t )
SELECT distinct(quarter_number) dist_quarter, avg(rating)  AS rating_average 
FROM feedback_sel
group by dist_quarter
order by dist_quarter;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback.
      
Note: For reference, refer to question number 4. Week-2: mls_week-2_gl-beats_solution-1.sql. 
      You'll get an overview of how to use common table expressions from this question.*/
-- in coordination of CTE, will use count case when and assign allias to customer feedback texts and then will the %      

WITH feedback_cte AS (
    SELECT quarter_number, 
           COUNT(*) AS feedback_count,
           COUNT(CASE WHEN customer_feedback = 'Very Good' THEN 1 END) AS very_good_count,
           COUNT(CASE WHEN customer_feedback = 'Good' THEN 1 END) AS good_count,
           COUNT(CASE WHEN customer_feedback = 'Okay' THEN 1 END) AS okay_count,
           COUNT(CASE WHEN customer_feedback = 'Bad' THEN 1 END) AS bad_count,
           COUNT(CASE WHEN customer_feedback = 'Very Bad' THEN 1 END) AS very_bad_count
    FROM order_t
    GROUP BY quarter_number
)
SELECT quarter_number,
       (very_good_count/feedback_count)*100 AS percentage_very_good,
       (good_count/feedback_count)*100 AS percentage_good,
       (okay_count/feedback_count)*100 AS percentage_okay,
       (bad_count/feedback_count)*100 AS percentage_bad,
       (very_bad_count/feedback_count)*100 AS percentage_very_bad
FROM feedback_cte;
	
-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/
-- will use Order by Desc and limit 5 to get top 5

SELECT vehicle_maker, COUNT(*) AS customer_count
FROM product_t
GROUP BY vehicle_maker
ORDER BY customer_count DESC
LIMIT 5;

-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/
-- will use window function RANK() over partition and will have to query 2 cols from 2 diff tables
SELECT state, vehicle_maker
FROM (
    SELECT state, vehicle_maker,
           RANK() OVER (PARTITION BY state ORDER BY COUNT(*) DESC) AS most_pref_vehi
    FROM product_t, customer_t
    where product_t.product_id = product_id
     and customer_t.state = state
    GROUP BY state, vehicle_maker
) AS ranked_makes
WHERE most_pref_vehi = 1;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?
Hint: Count the number of orders for each quarter.*/
-- will use count function, group it and order it by quarter number

SELECT quarter_number, COUNT(*) AS order_count
FROM order_t
GROUP BY quarter_number
ORDER BY quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
-- will have to compare between perv and current with coordination of CTE and LAG function

WITH revenue_cte AS (
    SELECT quarter_number, SUM(vehicle_price * quantity) AS revenue
    FROM order_t
    GROUP BY quarter_number
)
SELECT quarter_number, 
       (revenue - LAG(revenue) OVER (ORDER BY quarter_number)) / LAG(revenue) OVER (ORDER BY quarter_number) * 100 AS qoq_percentage_change
FROM revenue_cte
ORDER BY quarter_number;
      
-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/

WITH revenue_cte AS (
    SELECT quarter_number, SUM(vehicle_price * quantity) AS revenue
    FROM order_t
    GROUP BY quarter_number
),
order_count_cte AS (
    SELECT quarter_number, COUNT(*) AS order_count
    FROM order_t
    GROUP BY quarter_number
)
SELECT r.quarter_number, r.revenue, o.order_count
FROM revenue_cte r
JOIN order_count_cte o ON r.quarter_number = o.quarter_number
ORDER BY r.quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT credit_card_type, AVG(discount) AS average_discount
FROM order_t,customer_t
where customer_t.credit_card_type = credit_card_type
	and order_t.discount = discount
GROUP BY credit_card_type;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/
SELECT quarter_number, AVG(DATEDIFF(ship_date, order_date)) AS average_shipping_time
FROM order_t
GROUP BY quarter_number;

-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------



