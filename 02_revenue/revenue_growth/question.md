# Case 03 — Is Revenue Really Growing?
*Month-over-month and year-over-year growth*

## The business question
> "Revenue went up again this month. How fast are we really growing, and what is driving it?"

## Who asks it
| Stakeholder | What they want to know |
|---|---|
| CEO / Board / Investors | What is our growth rate, and can it continue? |
| Finance | What revenue should we forecast and budget for next year? |
| Marketing | Is growth coming from new customers, or from customers we already have? |
| Product | Are customers spending more per order, or ordering more often? |

## Why "revenue went up" is not enough
A rising total can come from very different places: more customers, customers ordering more often, or bigger baskets. Each one points to a different team and a different plan. Growth percentages can also mislead: a young business shows huge percentages from a tiny starting point, and months with more days look like growth.

## Data used
- `orders` — one row per order, with `order_date` and `amount`
- `users` — `signup_date`, to separate new from returning customers

## Definitions (agree on these before writing SQL)
- **Revenue:** sum of order amounts in the calendar month (no refunds in this dataset).
- **MoM growth:** (this month − last month) ÷ last month.
- **YoY growth:** (this month − same month last year) ÷ same month last year.
- **New customer:** signed up in the same calendar month as the order. **Returning:** signed up in an earlier month.
- **CMGR (compound monthly growth rate):** the steady monthly rate that turns the starting month into the ending month. It ignores the zigzag in between.
