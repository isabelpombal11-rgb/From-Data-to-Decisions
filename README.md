# From Data to Decisions

*Real business questions, solved end-to-end: SQL and Python analysis, the financial impact, and what the business should do next.*

Each case follows the same path:
**business question → SQL / Python → visualisation → business recommendation.**

Every case folder contains:
- `question.md` — the business context, the stakeholders, and the definitions
- `solution.sql` — the query, commented step by step
- `insights.md` — findings, financial impact, caveats and recommendations

## Cases
| # | Case | Business question | Key skills | Status |
|---|---|---|---|---|
| 01 | **[The Leaking Bucket](01_growth/cohort_retention)**<br>Customer retention by signup cohort | Do the customers we acquire keep coming back? | CTEs, date math, pivoting | ✅ |
| 02 | **[The Abandoned Checkout](01_growth/funnel_conversion)**<br>Funnel conversion and mobile payment drop-off | Where do shoppers drop off before buying? | Conditional aggregation, segmentation | ✅ |
| 03 | **[Is Revenue Really Growing?](02_revenue/revenue_growth)**<br>Month-over-month and year-over-year growth | Is revenue growing, and how fast? | Window functions (LAG), revenue drivers | ✅ |
| 04 | **Signal vs. Noise**<br>Running totals and moving averages | What's the underlying trend beneath daily noise? | Window frames | 🔜 |
| 05 | **What Sells Where**<br>Top products in each category | What are the best sellers in each category? | ROW_NUMBER / RANK | 🔜 |
| 06 | **Know Your Customers**<br>RFM segmentation: best, at-risk and lost customers | Who are our best, at-risk, and lost customers? | NTILE, segmentation | 🔜 |
| 07 | **Did It Actually Work?**<br>A/B test analysis and statistical significance | Did the change actually cause the improvement? | Statistics in Python | 🔜 |
| 08 | **Why Don't the Numbers Match?**<br>Finding and removing duplicate records | Why are our totals wrong? | ROW_NUMBER, data quality | 🔜 |
| 09 | **Streaks and Gaps**<br>Customer activity streaks and inactive periods | How long are customers' activity streaks? | Advanced window logic | 🔜 |
| 10 | **Running to Stand Still**<br>Oil well production decline curves | How fast are our wells declining? | Energy domain, curve fitting | 🔜 |

## Run it yourself
```bash
pip install -r requirements.txt
python datasets/generate_data.py   # builds datasets/analytics.db (SQLite)
sqlite3 datasets/analytics.db < 01_growth/cohort_retention/solution.sql
```

## Dataset
Synthetic, reproducible e-commerce data (2025): `users` (4.4k), `events` (47.6k), `orders` (10.9k), `sessions` (20.3k).
