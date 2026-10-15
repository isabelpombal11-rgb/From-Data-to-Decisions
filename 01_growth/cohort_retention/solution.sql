-- =============================================================
-- Case 01: The Leaking Bucket (customer retention by signup cohort)
-- Question: Of the users who signed up in month X, what % are
--           still active 1, 2, 3... months later?
-- Dialect: SQLite (notes for PostgreSQL / BigQuery in README)
-- =============================================================

-- STEP 1: Give every user a cohort = the month they signed up
WITH cohorts AS (
    SELECT user_id,
           strftime('%Y-%m', signup_date) AS cohort_month
    FROM users
),

-- STEP 2: List every month each user was active (one row per user per month)
activity AS (
    SELECT DISTINCT user_id,
           strftime('%Y-%m', event_date) AS activity_month
    FROM events
),

-- STEP 3: Join and compute "months since signup" (month_number)
cohort_activity AS (
    SELECT c.cohort_month,
           a.user_id,
           (CAST(substr(a.activity_month,1,4) AS INT) - CAST(substr(c.cohort_month,1,4) AS INT)) * 12
         + (CAST(substr(a.activity_month,6,2) AS INT) - CAST(substr(c.cohort_month,6,2) AS INT))
           AS month_number
    FROM cohorts c
    JOIN activity a ON a.user_id = c.user_id
),

-- STEP 4: Cohort size = number of users active in month 0
cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT user_id) AS cohort_users
    FROM cohort_activity
    WHERE month_number = 0
    GROUP BY cohort_month
)

-- STEP 5: Retention % = active users in month N / cohort size
SELECT ca.cohort_month,
       cs.cohort_users,
       ca.month_number,
       COUNT(DISTINCT ca.user_id) AS active_users,
       ROUND(100.0 * COUNT(DISTINCT ca.user_id) / cs.cohort_users, 1) AS retention_pct
FROM cohort_activity ca
JOIN cohort_size cs ON cs.cohort_month = ca.cohort_month
WHERE ca.month_number >= 0
GROUP BY ca.cohort_month, cs.cohort_users, ca.month_number
ORDER BY ca.cohort_month, ca.month_number;
