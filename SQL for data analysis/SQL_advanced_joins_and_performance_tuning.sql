-- each account who has a sales rep and each sales rep that has an account (all of the columns in these returned rows will be full)
SELECT *
FROM accounts a
FULL JOIN sales_reps s
ON a.sales_rep_id = s.id

-- but also each account that does not have a sales rep and each sales rep that does not have an account (some of the columns in these returned rows will be empty)
SELECT *
FROM accounts a
FULL JOIN sales_reps s
ON a.sales_rep_id = s.id
WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL

-- In the following SQL Explorer, write a query that left joins the accounts table and the sales_reps tables on each sale rep's ID number and joins it using the < comparison operator on accounts.primary_poc and sales_reps.name
SELECT a.name account_name, a.primary_poc, s.name sales_rep_name
FROM accounts a
LEFT JOIN sales_reps s
ON s.id = a.sales_rep_id AND a.primary_poc < s.name

-- Modify the query from the previous video, which is pre-populated in the SQL Explorer below, to perform the same interval analysis except for the web_events table. Also:
-- change the interval to 1 day to find those web events that occurred after, but not more than 1 day after, another web event
-- add a column for the channel variable in both instances of the table in your query
SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at

SELECT e1.id AS e1_id,
       e1.account_id AS e1_account_id,
       e1.occurred_at AS e1_occurred_at,
       e1.channel AS e1_channel,
       e2.id AS e2_id,
       e2.account_id AS e2_account_id,
       e2.occurred_at AS e2_occurred_at,
       e2.channel AS e2_channel
  FROM web_events e1
 LEFT JOIN web_events e2
   ON e1.account_id = e2.account_id
  AND e2.occurred_at > e1.occurred_at
  AND e2.occurred_at <= e1.occurred_at + INTERVAL '1 day'
ORDER BY e1.account_id, e1.occurred_at

-- Write a query that uses UNION ALL on two instances (and selecting all columns) of the accounts table. Then inspect the results and answer the subsequent quiz.
SELECT *
FROM accounts

UNION ALL

SELECT *
FROM accounts

-- Add a WHERE clause to each of the tables that you unioned in the query above, filtering the first table where name equals Walmart and filtering the second table where name equals Disney. Inspect the results then answer the subsequent quiz.
SELECT *
FROM accounts
WHERE name = 'Walmart'

UNION ALL

SELECT *
FROM accounts
WHERE name = 'Disney'

-- How else could the above query results be generated?
SELECT *
FROM accounts
WHERE name = 'Walmart' OR name = 'Disney'

-- Perform the union in your first query (under the Appending Data via UNION header) in a common table expression and name it double_accounts. Then do a COUNT the number of times a name appears in the double_accounts table. If you do this correctly, your query results should have a count of 2 for each name.
WITH double_accounts AS (
  SELECT *
  FROM accounts

  UNION ALL

  SELECT *
  FROM accounts
)
SELECT name, COUNT(*)
FROM double_accounts
GROUP BY 1
ORDER BY 2 DESC