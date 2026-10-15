-- Follow-up question: does retention differ by acquisition channel?
WITH base AS (
    SELECT u.user_id, u.channel, strftime('%Y-%m', u.signup_date) AS cohort_month,
           (CAST(strftime('%Y', e.event_date) AS INT) - CAST(strftime('%Y', u.signup_date) AS INT)) * 12
         + (CAST(strftime('%m', e.event_date) AS INT) - CAST(strftime('%m', u.signup_date) AS INT)) AS month_number
    FROM users u JOIN events e ON e.user_id = u.user_id
    WHERE u.signup_date < '2025-07-01'          -- only cohorts with 3+ months of history
)
SELECT channel,
       COUNT(DISTINCT user_id) AS users,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN month_number = 1 THEN user_id END) / COUNT(DISTINCT user_id), 1) AS m1_pct,
       ROUND(100.0 * COUNT(DISTINCT CASE WHEN month_number = 3 THEN user_id END) / COUNT(DISTINCT user_id), 1) AS m3_pct
FROM base
GROUP BY channel
ORDER BY m3_pct DESC;
