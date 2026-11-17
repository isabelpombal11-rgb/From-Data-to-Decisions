# Extension: Our 10 Best Customers
*My own follow-up to Case 06, written and analysed by me.*

## The question
Case 06 grouped customers into segments. Inside the best segment, who are the 10 individual customers who spent the most, and what should the business do for them?

## My query
The first three steps (`rfm`, `scored`, `segmented`) are the same as in `solution.sql`. Only the last part is new:

```sql
SELECT user_id,
       frequency          AS orders,
       ROUND(monetary, 2) AS total_spent,
       recency_days       AS days_since_last_order
FROM segmented
WHERE segment = '1 Champions'
ORDER BY monetary DESC
LIMIT 10;
```
- `WHERE segment = '1 Champions'` must match the label exactly, including the number at the start: SQL compares text letter by letter.
- `ORDER BY monetary DESC` puts the biggest spenders first. I sorted by the original, unrounded value so close customers are ordered precisely.
- `LIMIT 10` keeps only the first 10 rows.

## What I found

| user_id | Orders | Total spent | Days since last order |
|---|---|---|---|
| 574 | 16 | €1,097.15 | 1 |
| 502 | 16 | €969.25 | 33 |
| 1529 | 9 | €923.98 | 25 |
| 435 | 13 | €889.42 | 3 |
| 332 | 13 | €836.69 | 24 |
| 995 | 9 | €824.11 | 16 |
| 2092 | 10 | €786.46 | 24 |
| 824 | 13 | €783.26 | 30 |
| 2520 | 11 | €782.78 | 5 |
| 1048 | 11 | €759.69 | 16 |

- Each spent **€760–1,097**, about **5 times** an average buyer (€169) and 2.5 times an average Champion (€324).
- Together they spent **€8,653**: 1.5% of all revenue from 0.3% of buyers.
- **6 of the 10 came through Referral**, 3 Organic, 1 Paid Search and none from Paid Social, the same channel pattern as Cases 01 and 06.
- 7 of the 10 signed up in January–March, so they've had the longest time to build up spending.
- All ordered within the last 33 days: they are still very active.

## My conclusion
> I would create a VIP rewards programme for these top customers to keep them coming back, and make it visible so that Loyal customers are motivated to become regulars and reach the same rewards. The rewards should be perks rather than discounts (early access, free delivery, a personal thank-you), and should include a referral invitation, because 6 of the 10 best customers arrived through a friend's recommendation.

## What I learned
- **Filtering a segment needs the exact label.** `'Champions'` alone matches nothing when the label is `'1 Champions'`.
- **`LIMIT` keeps the first N rows**, so `ORDER BY ... DESC LIMIT 10` is the classic "top 10" pattern.
- **Look at who the best customers are, not just how much they spend.** Checking their channel and sign-up month showed *why* they're the best and *how* to find more like them.
- **Discounts aren't always a reward.** Customers who already buy often don't need a lower price; recognition and perks keep them without giving money away.
