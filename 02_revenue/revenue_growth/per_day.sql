-- Follow-up question: is the month-to-month zigzag real?
-- Months have 28, 30 or 31 days, so a 31-day month earns more
-- just by being longer. Dividing by days in the month removes that.
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           SUM(amount)                   AS revenue,
           -- last day of the month = first day + 1 month - 1 day
           CAST(strftime('%d', date(strftime('%Y-%m-01', order_date), '+1 month', '-1 day')) AS INT) AS days
    FROM orders
    GROUP BY month
)
SELECT month,
       days,
       ROUND(revenue / days, 0) AS revenue_per_day,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
                   / LAG(revenue) OVER (ORDER BY month), 1)            AS mom_growth_pct,
       ROUND(100.0 * (revenue / days - LAG(revenue / days) OVER (ORDER BY month))
                   / LAG(revenue / days) OVER (ORDER BY month), 1)     AS mom_growth_per_day_pct
FROM monthly
ORDER BY month;
