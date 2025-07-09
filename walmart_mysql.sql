-- Walmart Project Queries

SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

SELECT 
	 payment_method, COUNT(*) as no_transactions
FROM walmart
GROUP BY payment_method
ORDER BY COUNT(*) DESC;

SELECT 
	COUNT(DISTINCT branch) 
FROM walmart;

SELECT MIN(quantity) 
FROM walmart;

-- Business problems
-- Q.1 Find different payment method and number of transactions, number of qty sold

SELECT payment_method, COUNT(*) as no_payments, SUM(quantity) as no_quanity_sold
FROM walmart
GROUP BY payment_method;

-- Q.2 Identify the highest-rated category in each branch, displaying the branch, category, AVG rating
SELECT *
FROM
( SELECT Branch, category, AVG(rating),
       RANK() OVER(PARTITION BY Branch ORDER BY AVG(rating) DESC) as Rank1
 FROM walmart
 GROUP BY Branch, category) as rating_per_category
 WHERE Rank1=1;

-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM
( SELECT Branch, dayname(str_to_date(date, '%d/%m/%y')) as day, COUNT(*) as no_transactions,
       RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as rank1
  FROM walmart
  GROUP BY Branch, dayname(str_to_date(date, '%d/%m/%y'))) as day_transactions
  WHERE rank1=1;

-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT payment_method, SUM(quantity) as total_quantity
FROM walmart
GROUP BY payment_method
ORDER BY total_quantity DESC;

-- Q.5 Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT city, category, AVG(rating) as avg_rating, MIN(rating) as min_rating, MAX(rating) as max_rating
FROM walmart
GROUP BY city, category
ORDER BY city, AVG(rating) DESC;

-- Q.6 Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT category, ROUND(SUM(total),2) as total_revenue, (total*profit_margin) as total_profit
FROM walmart
GROUP BY category
ORDER BY (unit_price*quantity*profit_margin) DESC;

-- Q.7 Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH CTE
AS
(SELECT Branch, payment_method, COUNT(*) as no_transactions,
       RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as rank1
 FROM walmart
 GROUP BY Branch, payment_method) 
 SELECT *
 FROM CTE
 WHERE rank1=1;

-- Q.8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

WITH CTE 
AS
(SELECT Branch, day_time, COUNT(*),
      RANK() OVER(PARTITION BY Branch ORDER BY COUNT(*) DESC) as rank1
FROM(SELECT *, 
    CASE 
         WHEN HOUR(time)<12 THEN 'Morning'
		 WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening' 
    END as day_time
FROM walmart) as day_time
GROUP BY Branch, day_time)
SELECT *
FROM CTE
WHERE rank1=1;

-- Q.9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)
-- rdr == last_rev-cr_rev/ls_rev*100

WITH revenue_2022
AS
(SELECT Branch, SUM(total) as ls_revenue
 FROM walmart
 WHERE YEAR(str_to_date(date, '%d/%m/%Y'))=2022
 GROUP BY Branch
 ),
 revenue_2023
 AS
 (SELECT Branch, SUM(total) as cs_revenue
 FROM walmart
 WHERE YEAR(str_to_date(date, '%d/%m/%Y'))=2023
 GROUP BY Branch
 )
SELECT ls.Branch, 
       ROUND(((ls_revenue-cs_revenue)/ls_revenue)* 100, 2) as decrease_ratio
FROM revenue_2022 as ls
JOIN revenue_2023 as cs ON ls.Branch=cs.Branch
WHERE ls_revenue>cs_revenue
ORDER BY decrease_ratio DESC
LIMIT 5
