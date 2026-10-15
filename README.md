# From Data to Decisions

*Real business questions, solved end-to-end: SQL and Python analysis, the financial impact, and what the business should do next.*

Each case follows the same path:
**business question → SQL / Python → visualisation → business recommendation.**

Every problem folder contains:
- `question.md` — the business context, the stakeholders, and the definitions
- `solution.sql` — the query, commented step by step
- `insights.md` — findings, financial impact, caveats and recommendations

## Cases
| # | Problem | Business question | Key skills | Status |
|---|---|---|---|---|
| 01 | [Cohort Retention](01_growth/cohort_retention) | Do the customers we acquire keep coming back? | CTEs, date math, pivoting | ✅ |
| 02 | Funnel Conversion | Where do users drop off before buying? | Conditional aggregation | 🔜 |
| 03 | MoM Revenue Growth | Is revenue growing, and how fast? | Window functions (LAG) | 🔜 |
| 04 | Running Totals & Moving Averages | What's the underlying trend beneath daily noise? | Window frames | 🔜 |
| 05 | Top-N per Group | What are the best sellers in each category? | ROW_NUMBER / RANK | 🔜 |
| 06 | RFM Segmentation | Who are our best, at-risk, and lost customers? | NTILE, segmentation | 🔜 |
| 07 | A/B Test Analysis | Did the change actually cause the improvement? | Statistics in Python | 🔜 |
| 08 | Deduplication | Why are our totals wrong? | ROW_NUMBER, data quality | 🔜 |
| 09 | Gaps & Islands | How long are customers' activity streaks? | Advanced window logic | 🔜 |
| 10 | Production Decline Curves | How fast are our wells declining? | Energy domain, curve fitting | 🔜 |

## Run it yourself
```bash
pip install -r requirements.txt
python datasets/generate_data.py   # builds datasets/analytics.db (SQLite)
sqlite3 datasets/analytics.db < 01_growth/cohort_retention/solution.sql
```

## Dataset
Synthetic, reproducible e-commerce data (2025): `users` (4.4k), `events` (47.6k), `orders` (10.9k).
