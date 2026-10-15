# Extension: Average Order Value by Category
*My own follow-up question to Case 03, written and analysed by me.*

## The question
Case 03 showed that overall average order value (AOV) barely changed during 2025. Is that true inside every product category, or is one category getting more expensive or cheaper while another moves the other way?

## My query
```sql
SELECT category,
       strftime('%Y-%m', order_date) AS month,
       ROUND(AVG(amount), 2)         AS avg_order_value
FROM orders
GROUP BY category, month
ORDER BY category, avg_order_value ASC;
```
Grouping by **two** columns gives one row per category per month (5 × 12 = 60 rows). Sorting by `avg_order_value` inside each category puts the lowest month first and the highest month last, so I didn't have to find them by eye.

## What I found

| Category | Average for the year | Lowest month | Highest month | Gap as % of average |
|---|---|---|---|---|
| Electronics | €119.81 | Feb (€112.63) | Aug (€122.06) | 8% |
| Beauty | €29.90 | Jan (€28.17) | Mar (€30.90) | 9% |
| Home | €60.07 | Jan (€55.21) | Aug (€61.38) | 10% |
| Fashion | €45.28 | Jan (€42.54) | Apr (€47.36) | 11% |
| Books | €19.75 | Apr (€18.83) | Jul (€21.43) | 13% |

No category rises or falls steadily from January to December. Each one wobbles up and down around its own average.

## My conclusion
> Average order value within each category stayed stable all year, so revenue growth came from more orders, not from customers spending more per order. This means AOV is a growth lever the business hasn't used yet, for example a free-delivery threshold just above the current average order of €55, which encourages customers to add one more item.

## What I learned
- **Let SQL find the extremes.** When twelve numbers are close together, scanning by eye picks the wrong one. Sorting with `ORDER BY ... ASC` gives the exact answer.
- **A flat result is still a finding.** "Nothing changed" told me where growth did *not* come from, and pointed to an opportunity.
- **Be careful with the word "promotion".** A discount lowers what customers spend per order. The useful levers make customers *add* to their basket: delivery thresholds and bundles.
- **Small samples wobble more.** Several of the lowest months are January and February, when the shop had only 154 and 397 orders, against 1,394 in December. Fewer orders means each average moves more by chance.
