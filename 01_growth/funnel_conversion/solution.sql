-- =============================================================
-- Case 02: The Abandoned Checkout (funnel conversion by step and device)
-- Question: Of all shopping sessions, how many reach each step
--           (view product -> add to cart -> checkout -> purchase),
--           and where do we lose the most people?
-- Dialect: SQLite
-- =============================================================

-- STEP 1: Turn the furthest step into a number so we can say
--         "this session reached step 3 or beyond".
--         A session that reached checkout also passed view and cart.
WITH ranked AS (
    SELECT session_id,
           device,
           CASE furthest_step
                WHEN 'landing'      THEN 0
                WHEN 'view_product' THEN 1
                WHEN 'add_to_cart'  THEN 2
                WHEN 'checkout'     THEN 3
                WHEN 'purchase'     THEN 4
           END AS step_no
    FROM sessions
),

-- STEP 2: Count sessions that reached AT LEAST each step
--         (conditional aggregation: one pass over the table).
counts AS (
    SELECT COUNT(*)                                AS sessions,
           SUM(CASE WHEN step_no >= 1 THEN 1 END)  AS viewed,
           SUM(CASE WHEN step_no >= 2 THEN 1 END)  AS carted,
           SUM(CASE WHEN step_no >= 3 THEN 1 END)  AS checkout,
           SUM(CASE WHEN step_no >= 4 THEN 1 END)  AS purchased
    FROM ranked
)

-- STEP 3: Two kinds of rate
--   step rate    = this step / previous step  -> where is the leak?
--   overall rate = this step / all sessions   -> how big is the funnel?
SELECT 'Session'      AS step, sessions  AS reached, NULL AS step_rate_pct, 100.0 AS overall_pct FROM counts
UNION ALL
SELECT 'View product', viewed,    ROUND(100.0*viewed   /sessions,1), ROUND(100.0*viewed   /sessions,1) FROM counts
UNION ALL
SELECT 'Add to cart',  carted,    ROUND(100.0*carted   /viewed,1),   ROUND(100.0*carted   /sessions,1) FROM counts
UNION ALL
SELECT 'Checkout',     checkout,  ROUND(100.0*checkout /carted,1),   ROUND(100.0*checkout /sessions,1) FROM counts
UNION ALL
SELECT 'Purchase',     purchased, ROUND(100.0*purchased/checkout,1), ROUND(100.0*purchased/sessions,1) FROM counts;
