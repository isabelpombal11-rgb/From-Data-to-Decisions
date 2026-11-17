-- =============================================================
-- Case 04: Signal vs. Noise
-- Question: Daily revenue jumps up and down. What is the real
--           trend underneath, and how much have we made so far
--           this year?
-- Dialect: SQLite (window functions need SQLite 3.25+)
-- =============================================================

-- STEP 1: Build a calendar with EVERY day of the year.
--         Some days have no orders, so they don't appear in the
--         orders table at all. Without this step, "the last 7 rows"
--         would silently cover more than 7 days.
--         A recursive CTE starts at one date and keeps adding a day.
WITH RECURSIVE calendar(day) AS (
    SELECT '2025-01-01'
    UNION ALL
    SELECT date(day, '+1 day') FROM calendar WHERE day < '2025-12-31'
),

-- STEP 2: Daily revenue, with 0 for days that had no orders.
daily AS (
    SELECT c.day,
           COALESCE(SUM(o.amount), 0) AS revenue
    FROM calendar c
    LEFT JOIN orders o ON o.order_date = c.day
    GROUP BY c.day
)

-- STEP 3: Window functions over the daily rows.
--   Running total : SUM over every row from the start up to today.
--   7-day average : AVG over today and the 6 days before it.
--   28-day average: AVG over today and the 27 days before it.
--   COUNT over the same frame lets us hide averages that don't yet
--   have a full window (the first 6 or 27 days of the year).
SELECT day,
       ROUND(revenue, 0) AS revenue,

       ROUND(SUM(revenue) OVER (ORDER BY day
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0)  AS running_total_ytd,

       CASE WHEN COUNT(*) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) = 7
            THEN ROUND(AVG(revenue) OVER (ORDER BY day
                 ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0) END   AS avg_7d,

       CASE WHEN COUNT(*) OVER (ORDER BY day ROWS BETWEEN 27 PRECEDING AND CURRENT ROW) = 28
            THEN ROUND(AVG(revenue) OVER (ORDER BY day
                 ROWS BETWEEN 27 PRECEDING AND CURRENT ROW), 0) END  AS avg_28d
FROM daily
ORDER BY day;
