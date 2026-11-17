# Case 04 — Signal vs. Noise
*Running totals and moving averages*

## The business question
> "Yesterday's revenue dropped 40%. Should we be worried, and how are we doing for the year so far?"

## Who asks it
| Stakeholder | What they want to know |
|---|---|
| CEO / Head of E-commerce | Is a bad day a real problem, or just a normal wobble? |
| Finance | How much revenue have we made so far this year, and are we on track? |
| Operations / Engineering | When should a drop trigger an alert and an investigation? |
| Marketing | Did a campaign really lift sales, or was it a lucky day? |

## Why daily numbers are not enough
Daily revenue is noisy: a few big orders, the weather, a payday, or plain chance can move it 20–50% from one day to the next. Reacting to every swing wastes time and creates panic. A **moving average** smooths the noise so the real direction (the signal) is visible. A **running total** answers a different question: how much have we accumulated so far?

## Data used
- `orders` — one row per order, with `order_date` and `amount`

## Definitions (agree on these before writing SQL)
- **Daily revenue:** sum of order amounts on that day, **€0 on days with no orders**.
- **7-day moving average:** the average of today and the previous 6 days. Seven days contains each weekday exactly once, so weekend effects cancel out.
- **28-day moving average:** the same idea over four full weeks. Smoother, but slower to react.
- **Running total (year to date):** the sum of all revenue from 1 January up to and including that day.
