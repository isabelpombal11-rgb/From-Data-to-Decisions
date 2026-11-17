-- Follow-up question: does "best seller" mean the same thing if we
-- count orders instead of revenue?
-- Ranks every product both ways and keeps the ones where the two
-- rankings disagree by 2 places or more.
WITH product_sales AS (
    SELECT p.category, p.product_name, p.list_price,
           COUNT(*) AS orders, SUM(o.amount) AS revenue
    FROM orders o JOIN products p ON p.product_id = o.product_id
    GROUP BY p.category, p.product_name, p.list_price
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY category ORDER BY orders  DESC) AS rank_by_orders,
           RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_by_revenue
    FROM product_sales
)
SELECT category, product_name, list_price, orders,
       ROUND(revenue, 0) AS revenue, rank_by_orders, rank_by_revenue
FROM ranked
WHERE ABS(rank_by_orders - rank_by_revenue) >= 2
ORDER BY category, rank_by_orders;
