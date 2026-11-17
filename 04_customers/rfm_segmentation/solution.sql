-- =============================================================
-- Case 06: Know Your Customers
-- Question: Who are our best customers, who is slipping away,
--           and who have we already lost?
-- Method: RFM = Recency, Frequency, Monetary value
-- Dialect: SQLite (window functions need SQLite 3.25+)
-- Snapshot date: 2026-01-01 (the day after our data ends)
-- =============================================================

-- STEP 1: One row per customer with the three RFM measures.
--   Recency   = days since their last order (smaller is better)
--   Frequency = number of orders
--   Monetary  = total amount spent
WITH rfm AS (
    SELECT user_id,
           CAST(julianday('2026-01-01') - julianday(MAX(order_date)) AS INT) AS recency_days,
           COUNT(*)                                                         AS frequency,
           SUM(amount)                                                      AS monetary
    FROM orders
    GROUP BY user_id
),

-- STEP 2: Score each measure from 1 (worst) to 5 (best).
--   NTILE(5) splits customers into 5 equal-sized groups.
--   Recency is ordered DESC so the MOST recent customers get 5.
--   Frequency uses fixed thresholds instead of NTILE: 29% of customers
--   ordered exactly once, and NTILE would split those identical
--   customers into different scores just to keep the groups equal.
scored AS (
    SELECT *,
           NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
           CASE WHEN frequency = 1 THEN 1
                WHEN frequency = 2 THEN 2
                WHEN frequency = 3 THEN 3
                WHEN frequency <= 5 THEN 4
                ELSE 5 END                       AS f_score,
           NTILE(5) OVER (ORDER BY monetary)     AS m_score
    FROM rfm
),

-- STEP 3: Turn the scores into segments people can act on.
--   The order of the WHEN lines matters: the first match wins.
segmented AS (
    SELECT *,
           CASE WHEN r_score >= 4 AND f_score >= 4 THEN '1 Champions'
                WHEN r_score >= 3 AND f_score >= 3 THEN '2 Loyal'
                WHEN r_score >= 4 AND f_score <= 2 THEN '3 New & promising'
                WHEN r_score  = 3 AND f_score <= 2 THEN '4 Needs attention'
                WHEN r_score <= 2 AND f_score >= 3 THEN '5 At risk'
                ELSE                                    '6 Lost' END AS segment
    FROM scored
)

-- STEP 4: Describe each segment.
SELECT segment,
       COUNT(*)                                                    AS customers,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)          AS pct_customers,
       ROUND(SUM(monetary), 0)                                     AS revenue,
       ROUND(100.0 * SUM(monetary) / SUM(SUM(monetary)) OVER (), 1) AS pct_revenue,
       ROUND(AVG(recency_days), 0)                                 AS avg_days_since_last_order,
       ROUND(AVG(frequency), 1)                                    AS avg_orders,
       ROUND(AVG(monetary), 0)                                     AS avg_spend
FROM segmented
GROUP BY segment
ORDER BY segment;
