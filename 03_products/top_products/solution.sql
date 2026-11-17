-- =============================================================
-- Case 05: What Sells Where
-- Question: What are the top 3 products in each category, and how
--           much of the category's revenue do they bring in?
-- Dialect: SQLite (window functions need SQLite 3.25+)
-- =============================================================

-- STEP 1: Revenue and number of orders per product.
--         JOIN brings in the product name from the products table.
WITH product_sales AS (
    SELECT p.category,
           p.product_name,
           COUNT(*)      AS orders,
           SUM(o.amount) AS revenue
    FROM orders o
    JOIN products p ON p.product_id = o.product_id
    GROUP BY p.category, p.product_name
),

-- STEP 2: Number the products inside each category, best first.
--         PARTITION BY restarts the numbering for every category,
--         so each category gets its own 1, 2, 3...
--         SUM(...) OVER (PARTITION BY category) is the category total,
--         repeated on every row, so each product can be compared with it.
ranked AS (
    SELECT category,
           product_name,
           orders,
           revenue,
           ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC) AS rank_in_category,
           SUM(revenue) OVER (PARTITION BY category)                       AS category_revenue
    FROM product_sales
)

-- STEP 3: Keep the top 3 of each category.
--         The filter has to happen here, in an outer query: SQL works out
--         WHERE before window functions, so "WHERE ROW_NUMBER() <= 3"
--         inside the same query is not allowed.
SELECT category,
       rank_in_category,
       product_name,
       orders,
       ROUND(revenue, 0)                            AS revenue,
       ROUND(100.0 * revenue / category_revenue, 1) AS pct_of_category
FROM ranked
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;
