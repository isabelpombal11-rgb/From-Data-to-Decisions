-- Follow-up question: how often does a single day look like bad news?
-- Compares each day with the day before, and with its 7-day average.
WITH RECURSIVE calendar(day) AS (
    SELECT '2025-01-01'
    UNION ALL
    SELECT date(day, '+1 day') FROM calendar WHERE day < '2025-12-31'
),
daily AS (
    SELECT c.day, COALESCE(SUM(o.amount), 0) AS revenue
    FROM calendar c LEFT JOIN orders o ON o.order_date = c.day
    GROUP BY c.day
),
compared AS (
    SELECT day,
           revenue,
           LAG(revenue) OVER (ORDER BY day)                                  AS prev_day,
           AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_7d,
           AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 13 PRECEDING AND 7 PRECEDING) AS avg_7d_week_before
    FROM daily
)
SELECT COUNT(*)                                                         AS days,
       SUM(CASE WHEN revenue < 0.8 * prev_day THEN 1 ELSE 0 END)        AS days_down_20pct_vs_yesterday,
       ROUND(100.0 * SUM(CASE WHEN revenue < 0.8 * prev_day THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_of_days,
       SUM(CASE WHEN revenue < 0.8 * prev_day AND avg_7d > avg_7d_week_before
                THEN 1 ELSE 0 END)                                      AS of_which_trend_was_rising
FROM compared
WHERE day >= '2025-01-15';   -- skip the launch weeks with very few orders
