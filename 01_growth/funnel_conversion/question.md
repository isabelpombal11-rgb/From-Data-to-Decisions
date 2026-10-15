# Case 02 — The Abandoned Checkout
*Funnel conversion and mobile payment drop-off*

## The business question
> "Out of everyone who visits the shop, how many end up buying, and at which step do we lose them?"

## Who asks it
| Stakeholder | What they want to know |
|---|---|
| Head of E-commerce | Where is revenue leaking, and which fix is worth the most? |
| Product / UX | Which page or step is broken or confusing? |
| Engineering | Is there a technical problem on a specific device or browser? |
| Marketing | Are we paying to bring visitors who never had a chance to buy? |

## Why a single conversion rate is not enough
"5.8% of sessions convert" tells you the size of the problem, not where it is. A funnel breaks the journey into steps, so each team can see the drop-off it owns. Splitting the funnel by device, channel or country then shows whether a drop is normal behaviour or a fixable problem in one segment.

## Data used
- `sessions` — one row per shopping session (2025), with `device`, `channel` and `furthest_step` reached

## Definitions (agree on these before writing SQL)
- **Funnel steps, in order:** session → view product → add to cart → checkout → purchase.
- **Reached a step:** the session got to that step *or any later one*. A purchase implies the shopper also checked out.
- **Step rate:** sessions reaching this step ÷ sessions reaching the previous step. This shows *where* people leave.
- **Overall rate:** sessions reaching this step ÷ all sessions. This shows *how big* the funnel is.
- **Unit:** sessions, not users. A user with 3 visits counts 3 times. (See the caveats in `insights.md`.)
