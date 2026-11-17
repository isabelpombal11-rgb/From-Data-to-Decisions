-- Why not NTILE(5) for frequency? Run this to see the problem.
-- Customers with the SAME number of orders end up with DIFFERENT scores.
WITH rfm AS (
    SELECT user_id, COUNT(*) AS frequency FROM orders GROUP BY user_id
),
scored AS (
    SELECT frequency, NTILE(5) OVER (ORDER BY frequency) AS ntile_score
    FROM rfm
)
-- Window results can't be grouped in the same step, so we group here.
SELECT frequency,
       ntile_score,
       COUNT(*) AS customers
FROM scored
WHERE frequency <= 3
GROUP BY frequency, ntile_score
ORDER BY frequency, ntile_score;
