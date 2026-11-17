# Extension: Choosing an Alert Rule
*My own follow-up to Case 04, written and analysed by me.*

## The question
Case 04 recommends watching revenue through moving averages instead of single days. But which window should trigger an alert, and when exactly should someone start investigating?

## Part 1 — Short window or long window?
I compared a 3-day and a 7-day moving average for November 2025.

```sql
ROUND(AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 0) AS avg_7d,
ROUND(AVG(revenue) OVER (ORDER BY day ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS avg_3d
```
The number in `PRECEDING` is always the window size minus one, because today counts as one of the days.

| | Lowest in November | Highest in November | Range |
|---|---|---|---|
| 7-day average | €2,167 | €2,418 | about €250 |
| 3-day average | €1,894 | €2,544 | about €650 |

**Example — 15 November:** revenue was €1,463. The 3-day average fell 26% in one day, which looks like an emergency. The 7-day average fell only 4%. Revenue recovered over the next three days, so nothing was actually wrong.

**What this shows:** a short window reacts **faster** to a real problem but raises **more false alarms**. A long window is calmer but slower.

## Part 2 — Use both, with a threshold
My first idea was to alert whenever the 7-day average falls below the 28-day average. I tested how often that would happen:

```sql
SELECT COUNT(*)                    AS days,
       SUM(avg_7d < avg_28d)       AS below_at_all,
       SUM(avg_7d < 0.9 * avg_28d) AS below_by_10pct
FROM smoothed
WHERE day >= '2025-02-01';
```
(`smoothed` holds the 7-day and 28-day averages for every day, built on a full calendar so that days with no orders count as €0.)

| Rule | Days it would alert (Feb–Dec, 334 days) | How often |
|---|---|---|
| 7-day below 28-day at all | 90 | about twice a week |
| 7-day more than 10% below 28-day | 10 | about once a month |

Adding the 10% threshold cuts alerts by about 90%. This business grew steadily all year with no known incidents, so most of those alerts would have been false alarms. Ten a year is a manageable number to investigate; ninety would quickly teach people to ignore the alert.

## My conclusion
> I would monitor both averages and raise an alert only when the 7-day average falls more than 10% below the 28-day average. In 2025 that rule would have fired about once a month instead of twice a week, so it catches real, sustained drops within about a week while ignoring normal day-to-day wobble. Urgent problems like a broken checkout still need faster signals, such as payment errors per hour.

## What I learned
- **Placeholders must be replaced before running.** `__` in a window frame gives "frame starting offset must be a non-negative integer".
- **Short window = fast but nervous; long window = calm but slow.** The right choice depends on what costs more: a missed problem or a false alarm.
- **Test an alert rule on past data before using it.** Counting how often it would have fired turned "alert when one falls below the other" into a rule that's actually usable.
- **No rule covers everything.** This one is good at sustained drops; short, sharp problems or ones that only hit one segment (like mobile checkout in Case 02) need other checks.
