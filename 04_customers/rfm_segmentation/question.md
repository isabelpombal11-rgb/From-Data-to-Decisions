# Case 06 — Know Your Customers
*RFM segmentation: best, at-risk and lost customers*

## The business question
> "We send every customer the same emails and the same discounts. Who are our best customers, who is drifting away, and who is already gone?"

## Who asks it
| Stakeholder | What they want to know |
|---|---|
| CRM / Email marketing | Which customers should get which message? |
| Head of E-commerce | How much revenue depends on a small group of customers? |
| Finance | How much revenue is at risk if customers who used to buy don't come back? |
| Customer service | Who deserves VIP treatment? |

## Why one message for everyone is not enough
A customer who bought last week and one who hasn't bought in eight months need different messages. Treating them the same wastes money twice: discounts go to people who would have bought anyway, and the people slipping away get nothing that brings them back. **RFM** is a simple, widely used way to group customers by behaviour so each group gets the right action.

## Data used
- `orders` — one row per order, with `user_id`, `order_date` and `amount`
- `users` — `channel`, for the follow-up by acquisition channel

## Definitions (agree on these before writing SQL)
- **Snapshot date:** 1 January 2026, the day after the data ends. Every "days since" is measured from here.
- **Recency (R):** days since the customer's last order. Fewer is better.
- **Frequency (F):** number of orders in 2025.
- **Monetary (M):** total amount spent in 2025.
- **Scores:** each measure scored 1 (worst) to 5 (best). R and M use `NTILE(5)` (five equal groups); F uses fixed thresholds (1, 2, 3, 4–5, 6+ orders), explained in `insights.md`.
- **Segments:**

| Segment | Rule | In plain words |
|---|---|---|
| Champions | R ≥ 4 and F ≥ 4 | Bought recently and often |
| Loyal | R ≥ 3 and F ≥ 3 | Regular buyers, fairly recent |
| New & promising | R ≥ 4 and F ≤ 2 | Bought recently, but only once or twice |
| Needs attention | R = 3 and F ≤ 2 | Bought a few months ago, not often |
| At risk | R ≤ 2 and F ≥ 3 | Used to buy often, but not for a long time |
| Lost | R ≤ 2 and F ≤ 2 | Bought once or twice, long ago |

Customers who signed up but never ordered have no RFM scores; they are counted separately.
