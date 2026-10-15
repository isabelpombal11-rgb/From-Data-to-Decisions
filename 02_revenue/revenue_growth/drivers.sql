-- Follow-up question: WHAT is driving the growth?
-- Revenue = buyers x orders per buyer x average order value (AOV).
-- Splitting it this way shows which lever actually moved.
-- We also split revenue into NEW customers (signed up that month)
-- and RETURNING customers (signed up in an earlier month).
SELECT strftime('%Y-%m', o.order_date)                        AS month,
       COUNT(DISTINCT o.user_id)                              AS buyers,
       ROUND(1.0 * COUNT(*) / COUNT(DISTINCT o.user_id), 2)   AS orders_per_buyer,
       ROUND(AVG(o.amount), 2)                                AS aov,
       ROUND(SUM(CASE WHEN strftime('%Y-%m', u.signup_date) =  strftime('%Y-%m', o.order_date)
                      THEN o.amount ELSE 0 END), 0)           AS new_customer_revenue,
       ROUND(SUM(CASE WHEN strftime('%Y-%m', u.signup_date) <  strftime('%Y-%m', o.order_date)
                      THEN o.amount ELSE 0 END), 0)           AS returning_customer_revenue,
       ROUND(SUM(o.amount), 0)                                AS revenue
FROM orders o
JOIN users u ON u.user_id = o.user_id
GROUP BY month
ORDER BY month;
