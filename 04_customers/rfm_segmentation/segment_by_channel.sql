-- Follow-up question: which acquisition channels do our Champions and
-- our Lost customers come from? (Links back to Case 01.)
-- Also counts sign-ups who never ordered at all: they have no RFM row.
WITH rfm AS (
    SELECT user_id,
           CAST(julianday('2026-01-01') - julianday(MAX(order_date)) AS INT) AS recency_days,
           COUNT(*) AS frequency
    FROM orders GROUP BY user_id
),
scored AS (
    SELECT *, NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
           CASE WHEN frequency = 1 THEN 1 WHEN frequency = 2 THEN 2 WHEN frequency = 3 THEN 3
                WHEN frequency <= 5 THEN 4 ELSE 5 END AS f_score
    FROM rfm
),
segmented AS (
    SELECT user_id,
           CASE WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
                WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
                ELSE 'Other buyers' END AS segment
    FROM scored
)
SELECT u.channel,
       COUNT(*)                                                         AS signups,
       ROUND(100.0 * SUM(s.segment IS NULL)        / COUNT(*), 1)       AS pct_never_ordered,
       ROUND(100.0 * SUM(s.segment = 'Champions')  / COUNT(*), 1)       AS pct_champions,
       ROUND(100.0 * SUM(s.segment = 'Lost')       / COUNT(*), 1)       AS pct_lost
FROM users u
LEFT JOIN segmented s ON s.user_id = u.user_id
GROUP BY u.channel
ORDER BY pct_champions DESC;
