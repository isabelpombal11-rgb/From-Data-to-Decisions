# Case 07 — Did It Actually Work?
*A/B test analysis and statistical significance*

## The business question
> "We lowered the free-delivery threshold from €80 to €60 for half of our visitors. Did it make customers spend more, and should we switch everyone over?"

This tests the recommendation from the Case 03 extension: a free-delivery threshold just above the average order, so customers add one more item.

## Who asks it
| Stakeholder | What they want to know |
|---|---|
| Head of E-commerce | Should we roll the €60 threshold out to everyone? |
| Finance | Does it make more *profit*, or just more revenue? |
| Logistics | How many more free deliveries will we be paying for? |
| Product team | Can we trust the result, or did we get lucky? |

## Why "before and after" is not enough
If you change the threshold in October and sales rise in November, was it the threshold, or Christmas shopping, or a marketing campaign? An **A/B test** answers this by showing the change to a random half of visitors (the *treatment*) and keeping the other half as they were (the *control*), at the same time. Because the two groups are alike in every other way, any difference between them comes from the change itself, or from chance. Statistics tells us how likely chance is.

## Data used
- `ab_test` — one row per visitor during the test (1 Sep – 23 Nov 2025): `variant`, `device`, `converted` (1 if they ordered), `order_amount`, `free_delivery` (1 if the order qualified).

## Definitions (agree on these BEFORE the test starts)
- **Control:** free delivery on orders of €80 or more (the current rule).
- **Treatment:** free delivery on orders of €60 or more.
- **Conversion rate:** visitors who ordered ÷ all visitors.
- **Average order value (AOV):** revenue ÷ orders, buyers only.
- **Revenue per visitor (RPV):** revenue ÷ all visitors. It combines conversion and AOV, so it is the **primary metric**: the one that decides.
- **Significance level:** 5%. A p-value below 0.05 means a difference this large would be unlikely if the change had no real effect.
- **Test length:** fixed in advance at 12 weeks. No stopping early because the numbers look good.
