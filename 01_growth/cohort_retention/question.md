# Case 01 — The Leaking Bucket
*Customer retention by signup cohort*

## The business question
> "Of the customers we acquire each month, how many keep coming back — and is that getting better or worse?"

## Who asks it
| Stakeholder | What they want to know |
|---|---|
| CEO / Board | Is the business healthy, or are we buying growth that leaks away? |
| Product | Did the feature or onboarding change we shipped actually work? |
| Marketing | Which acquisition channels bring customers who *stay*? |
| Finance | How long does a customer stay, and what is their lifetime value? |

## Why total active users is not enough
Total active users can rise while the business is getting worse. If marketing spend doubles, new signups hide the fact that older customers are leaving. Cohorts separate **new users** from **retained users**, so you compare like with like: January signups against February signups, each at the same age.

## Data used
- `users` — one row per customer with `signup_date` and `channel`
- `events` — one row per user action with `event_date`

## Definitions (agree on these with stakeholders BEFORE writing SQL)
- **Cohort:** the calendar month a user signed up.
- **Active:** the user had at least one event in that calendar month.
- **Month N:** the Nth calendar month after the signup month.
