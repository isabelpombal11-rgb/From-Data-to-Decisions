-- Follow-up question: does each country have different best sellers?
-- Top product per category in each customer country, by revenue.
WITH sales AS (
    SELECT u.country, p.category, p.product_name, SUM(o.amount) AS revenue
    FROM orders o
    JOIN users u    ON u.user_id    = o.user_id
    JOIN products p ON p.product_id = o.product_id
    GROUP BY u.country, p.category, p.product_name
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY country, category ORDER BY revenue DESC) AS rn
    FROM sales
)
SELECT category, country, product_name, ROUND(revenue, 0) AS revenue
FROM ranked
WHERE rn = 1
ORDER BY category, country;
