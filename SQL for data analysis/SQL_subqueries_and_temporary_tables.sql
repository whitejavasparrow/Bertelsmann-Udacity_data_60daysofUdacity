-- We want to find the average number of events for each day for each channel. The first table will provide us the number of events for each day and channel, and then we will need to average these values together using a second query.
SELECT channel, DATE_TRUNC('day', occurred_at), COUNT(*)
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC

SELECT *
FROM
(SELECT channel, DATE_TRUNC('day', occurred_at), COUNT(*)
FROM web_events
GROUP BY 1,2
ORDER BY 3 DESC) sub

SELECT channel, AVG(event_count) avg_event_count
FROM
(SELECT channel, DATE_TRUNC('day', occurred_at), COUNT(*) event_count
FROM web_events
GROUP BY 1,2) sub
GROUP BY channel
ORDER BY avg_event_count

SELECT DATE_TRUNC('month', MIN(occurred_at))
FROM orders

SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
  (SELECT DATE_TRUNC('month', MIN(occurred_at))
  FROM orders)

-- You need to find the average number of events for each channel per day.
SELECT channel, event_day, AVG(event_count) avg_event_count
FROM (
  SELECT channel, DATE_TRUNC('day', occurred_at) event_day, COUNT(*) event_count
  FROM web_events w
  GROUP BY 1,2
) sub
GROUP BY channel, event_day
ORDER BY avg_event_count DESC

WITH sub AS (
  SELECT channel, DATE_TRUNC('day', occurred_at) event_day, COUNT(*) event_count
  FROM web_events w
  GROUP BY 1,2
)

SELECT channel, event_day, AVG(event_count) avg_event_count
FROM sub
GROUP BY channel, event_day
ORDER BY avg_event_count DESC

-- Provide the name of the sales_rep in each region with the largest amount of total_amt_usd sales.
SELECT s.name rep_name, r.name region_name, o.total_amt_usd
FROM sales_reps s
JOIN region r
ON r.id = s.region_id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id

WITH sub AS (
  SELECT s.name rep_name, r.name region_name, o.total_amt_usd total_amt_usd
  FROM sales_reps s
  JOIN region r
  ON r.id = s.region_id
  JOIN accounts a
  ON a.sales_rep_id = s.id
  JOIN orders o
  ON o.account_id = a.id
),

sub2 AS (
  SELECT rep_name, region_name, SUM(total_amt_usd)
  FROM sub
  GROUP BY rep_name, region_name
),
sub3 AS (
  SELECT region_name, MAX(sum) max_sum
  FROM sub2
  GROUP BY region_name
)

SELECT sub2.region_name, sub2.rep_name, sub2.sum
FROM sub3
JOIN sub2
ON sub2.region_name = sub3.region_name AND sub2.sum = sub3.max_sum

-- For the region with the largest sales total_amt_usd, how many total orders were placed?
WITH sub AS (
  SELECT s.name rep_name, r.name region_name, o.total_amt_usd total_amt_usd
  FROM sales_reps s
  JOIN region r
  ON r.id = s.region_id
  JOIN accounts a
  ON a.sales_rep_id = s.id
  JOIN orders o
  ON o.account_id = a.id
),
sub2 AS (
  SELECT rep_name, region_name, SUM(total_amt_usd)
  FROM sub
  GROUP BY rep_name, region_name
),
sub3 AS (
  SELECT region_name, MAX(sum) max_sum
  FROM sub2
  GROUP BY region_name
),
sub4 AS (
  SELECT r.id region_id, r.name region_name, SUM(o.id) order_sum
  FROM orders o
  JOIN accounts a
  ON a.id = o.account_id
  JOIN sales_reps s
  ON s.id = a.sales_rep_id
  JOIN region r
  ON r.id = s.region_id
  GROUP BY r.id, r.name
),
sub5 AS (
  SELECT sub2.region_name region_name, sub2.rep_name rep_name, sub2.sum amt_sum
  FROM sub3
  JOIN sub2
  ON sub2.region_name = sub3.region_name AND sub2.sum = sub3.max_sum
)

SELECT *
FROM sub4
JOIN sub5
ON sub4.region_name = sub5.region_name
ORDER BY amt_sum DESC
LIMIT 1

WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name), 
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);