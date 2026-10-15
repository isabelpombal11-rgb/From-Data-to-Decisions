-- Follow-up question: is the funnel the same on every device?
-- Each column is the step-to-step conversion rate.
WITH ranked AS (
    SELECT device,
           CASE furthest_step WHEN 'landing' THEN 0 WHEN 'view_product' THEN 1
                WHEN 'add_to_cart' THEN 2 WHEN 'checkout' THEN 3 WHEN 'purchase' THEN 4 END AS step_no
    FROM sessions
)
SELECT device,
       COUNT(*) AS sessions,
       ROUND(100.0 * SUM(step_no >= 1) / COUNT(*), 1)          AS view_pct,
       ROUND(100.0 * SUM(step_no >= 2) / SUM(step_no >= 1), 1) AS cart_pct,
       ROUND(100.0 * SUM(step_no >= 3) / SUM(step_no >= 2), 1) AS checkout_pct,
       ROUND(100.0 * SUM(step_no >= 4) / SUM(step_no >= 3), 1) AS purchase_pct,
       SUM(step_no >= 3) AS reached_checkout,
       SUM(step_no >= 4) AS purchases
FROM ranked
GROUP BY device
ORDER BY purchase_pct;
