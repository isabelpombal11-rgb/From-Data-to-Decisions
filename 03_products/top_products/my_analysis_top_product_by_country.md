# Extension: The Best-Selling Product in Each Country
*My own follow-up to Case 05, written and analysed by me.*

## The question
Case 05 found the top products inside each category. Across **all** categories, which single product brings in the most revenue in each country, and is it the same everywhere?

## My query
```sql
WITH sales AS (
    SELECT u.country, p.product_name, SUM(o.amount) AS revenue
    FROM orders o
    JOIN users u    ON u.user_id    = o.user_id
    JOIN products p ON p.product_id = o.product_id
    GROUP BY u.country, p.product_name
),
ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY country ORDER BY revenue DESC) AS rn
    FROM sales
)
SELECT country, product_name, ROUND(revenue, 0) AS revenue
FROM ranked
WHERE rn = 1
ORDER BY country;
```
- `PARTITION BY country` restarts the ranking for each country, so every country gets its own #1.
- `ORDER BY revenue DESC` puts the highest revenue first, so the winner gets `rn = 1`.
- In the `ranked` step the column is just `country`, not `u.country`: the alias `u` only exists inside the `sales` step where it was created.

## What I found

| Country | #1 product | Revenue | Orders | Runner-up (revenue, orders) |
|---|---|---|---|---|
| Germany | Smartwatch | €15,575 | 107 | E-reader (€10,831, 85) |
| France | Smartwatch | €14,015 | 95 | E-reader (€10,365, 79) |
| Spain | Smartwatch | €13,185 | 92 | Bluetooth Speaker (€8,951, 81) |
| Portugal | Smartwatch | €11,536 | 84 | E-reader (€8,029, 59) |
| Angola | Smartwatch | €10,317 | 74 | E-reader (€9,980, **77**) |
| Brazil | Smartwatch | €10,166 | 69 | Bluetooth Speaker (€8,169, **77**) |

The Smartwatch wins in every country. But in **Angola and Brazil, the runner-up was ordered more often**. The Smartwatch still wins on revenue because, at €159, each order is worth more. Ranked by number of orders, those two countries would have a different winner.

## My conclusion
> The same product, the Smartwatch, is the top earner in every country (€10k–16k each, €75k in total, 12.5% of all revenue), even though in Angola and Brazil other products are ordered more often. Because so much revenue depends on one product, the business should protect its stock and keep it visible: a month out of stock could cost about €6k in revenue.

## What I learned
- **`PARTITION BY` decides what "each" means.** Partitioning by country gives one winner per country; adding category gives one per country and category.
- **`ROW_NUMBER` gives the winner position 1.** `rn` is a position, not the revenue itself, so the top product is always `rn = 1`, and `rn <= 3` would give the top 3.
- **An alias only lives in the query block where it's created.** In the next CTE, use the plain column name.
- **The ranking metric changes the answer.** By revenue the Smartwatch wins everywhere; by orders it doesn't.
