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