-- =============================================================
-- Case 07: Did It Actually Work?
-- Experiment: free delivery from 60 EUR (treatment) instead of 80 EUR (control)
-- Question: Does the lower threshold make customers spend more,
--           and does it bring in more revenue per visitor?
-- Dialect: SQLite.  The statistical tests are in analysis.py.
-- =============================================================

-- STEP 0: Sanity check first: was the split really 50/50?
-- (A broken split, called "sample ratio mismatch", makes every
--  other number untrustworthy. analysis.py tests it properly.)

-- STEP 1: One row per variant with the three metrics that matter.
--   Conversion rate      = buyers / visitors
--   Average order value  = revenue / orders  (only visitors who bought)
--   Revenue per visitor  = revenue / ALL visitors
--     -> combines the other two, so it is the metric that decides.
SELECT variant,
       COUNT(*)                                          AS visitors,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_visitors,
       SUM(converted)                                    AS orders,
       ROUND(100.0 * AVG(converted), 2)                  AS conversion_pct,
       ROUND(AVG(order_amount), 2)                       AS avg_order_value,      -- AVG ignores NULLs (non-buyers)
       ROUND(SUM(COALESCE(order_amount, 0)) / COUNT(*), 3) AS revenue_per_visitor,
       ROUND(100.0 * SUM(free_delivery) / SUM(converted), 1) AS pct_orders_free_delivery
FROM ab_test
GROUP BY variant
ORDER BY variant;
