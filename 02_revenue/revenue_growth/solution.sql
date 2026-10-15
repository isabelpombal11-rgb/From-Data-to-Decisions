-- =============================================================
-- Case 03: Is Revenue Really Growing?
-- Question: How much revenue do we make each month, and how fast
--           is it growing compared with the month before?
-- Dialect: SQLite (window functions need SQLite 3.25+)
-- =============================================================

-- STEP 1: One row per month with the total revenue
WITH monthly AS (
    SELECT strftime('%Y-%m', order_date) AS month,
           SUM(amount)                   AS revenue
    FROM orders
    GROUP BY month
)

-- STEP 2: LAG() looks one row back, so each month can be compared
--         with the previous one without a self-join.
--         OVER (ORDER BY month) tells LAG what "previous" means.
SELECT month,
       ROUND(revenue, 0)                                   AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month), 0)        AS prev_month_revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY month), 0) AS change_eur,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
                   / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct,

       -- Year-over-year uses the SAME pattern, looking 12 rows back:
       -- LAG(revenue, 12). Our data covers one year only, so it is NULL
       -- here; with two years of data this column fills in.
       ROUND(100.0 * (revenue - LAG(revenue, 12) OVER (ORDER BY month))
                   / LAG(revenue, 12) OVER (ORDER BY month), 1) AS yoy_growth_pct
FROM monthly
ORDER BY month;
