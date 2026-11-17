"""
Case 07: Did It Actually Work?  Statistical analysis of the free-delivery test.

Run from the repository root:
    python3 05_experiments/ab_test/analysis.py

Steps
  1. Sample ratio check  - was the 50/50 split real?
  2. Conversion rate     - two-proportion z-test
  3. Average order value - Welch's t-test (buyers only)
  4. Revenue per visitor - Welch's t-test (all visitors; the deciding metric)
  5. Peeking             - what we would have concluded if we had stopped early
  6. Profit check        - extra revenue vs extra delivery cost
  7. Power               - how many visitors we would need to prove the revenue effect
"""
import sqlite3
from pathlib import Path
import numpy as np
import pandas as pd
from scipy import stats

ROOT = Path(__file__).resolve().parents[2]
con = sqlite3.connect(ROOT / "datasets" / "analytics.db")
df = pd.read_sql("SELECT * FROM ab_test", con)
df["revenue"] = df["order_amount"].fillna(0)
c, t = df[df.variant == "control"], df[df.variant == "treatment"]

def ci_diff(a, b, alpha=0.05):
    """95% confidence interval for mean(b) - mean(a), Welch method."""
    diff = b.mean() - a.mean()
    se = np.sqrt(a.var(ddof=1) / len(a) + b.var(ddof=1) / len(b))
    z = stats.norm.ppf(1 - alpha / 2)
    return diff, diff - z * se, diff + z * se

print("=" * 64)
# 1. Sample ratio mismatch: chi-square test against a perfect 50/50 split
n_c, n_t = len(c), len(t)
srm_p = stats.chisquare([n_c, n_t]).pvalue
print(f"1. Split: control {n_c:,} vs treatment {n_t:,}  ->  p = {srm_p:.2f}")
print("   p > 0.01, so the split looks healthy." if srm_p > 0.01 else "   WARNING: split is broken, stop here.")

# 2. Conversion: two-proportion z-test
x_c, x_t = c.converted.sum(), t.converted.sum()
p_c, p_t = x_c / n_c, x_t / n_t
p_pool = (x_c + x_t) / (n_c + n_t)
z = (p_t - p_c) / np.sqrt(p_pool * (1 - p_pool) * (1 / n_c + 1 / n_t))
conv_p = 2 * (1 - stats.norm.cdf(abs(z)))
_, lo, hi = ci_diff(c.converted, t.converted)
print(f"2. Conversion: {p_c:.2%} -> {p_t:.2%}  (diff {100*(p_t-p_c):+.2f} pts, 95% CI {100*lo:+.2f} to {100*hi:+.2f})  p = {conv_p:.2f}")

# 3. Average order value: buyers only
a_c, a_t = c.order_amount.dropna(), t.order_amount.dropna()
d, lo, hi = ci_diff(a_c, a_t)
aov_p = stats.ttest_ind(a_t, a_c, equal_var=False).pvalue
print(f"3. Avg order value: EUR {a_c.mean():.2f} -> EUR {a_t.mean():.2f}  (diff EUR {d:+.2f}, 95% CI {lo:+.2f} to {hi:+.2f})  p = {aov_p:.4f}")

# 4. Revenue per visitor: everyone, non-buyers count as 0
d, lo, hi = ci_diff(c.revenue, t.revenue)
rpv_p = stats.ttest_ind(t.revenue, c.revenue, equal_var=False).pvalue
print(f"4. Revenue per visitor: EUR {c.revenue.mean():.3f} -> EUR {t.revenue.mean():.3f}  "
      f"({100*d/c.revenue.mean():+.1f}%, 95% CI EUR {lo:+.3f} to {hi:+.3f})  p = {rpv_p:.2f}")

# 5. Peeking: cumulative result at the end of each week
print("5. If we had checked revenue per visitor every week:")
weeks = []
for w in range(1, 13):
    cut = (pd.Timestamp("2025-09-01") + pd.Timedelta(days=7 * w)).strftime("%Y-%m-%d")
    cw, tw = c[c.visit_date < cut].revenue, t[t.visit_date < cut].revenue
    pw = stats.ttest_ind(tw, cw, equal_var=False).pvalue
    lift = 100 * (tw.mean() / cw.mean() - 1)
    weeks.append((w, lift, pw))
    print(f"   week {w:2d}: lift {lift:+5.1f}%   p = {pw:.3f}{'   <- looks significant' if pw < 0.05 else ''}")
pd.DataFrame(weeks, columns=["week", "lift_pct", "p_value"]).to_csv(Path(__file__).with_name("weekly_peeking.csv"), index=False)

# 6. Profit check (assumptions stated, change them to match the business)
MARGIN, DELIVERY_COST = 0.40, 4.50       # 40% gross margin, EUR 4.50 per delivery the shop pays
gross_c = MARGIN * c.revenue.sum() / n_c
gross_t = MARGIN * t.revenue.sum() / n_t
deliv_c = DELIVERY_COST * c.free_delivery.fillna(0).sum() / n_c
deliv_t = DELIVERY_COST * t.free_delivery.fillna(0).sum() / n_t
print(f"6. Profit per visitor (40% margin, EUR 4.50 per free delivery):")
print(f"   control   EUR {gross_c:.3f} margin - EUR {deliv_c:.3f} delivery = EUR {gross_c - deliv_c:.3f}")
print(f"   treatment EUR {gross_t:.3f} margin - EUR {deliv_t:.3f} delivery = EUR {gross_t - deliv_t:.3f}")

# 7. Power: visitors per variant needed to detect the observed revenue lift
#    (80% power, 5% significance, two-sided)
delta = t.revenue.mean() - c.revenue.mean()
sd = np.sqrt((c.revenue.var(ddof=1) + t.revenue.var(ddof=1)) / 2)
n_needed = 2 * ((stats.norm.ppf(0.975) + stats.norm.ppf(0.80)) * sd / delta) ** 2
per_week = (n_c + n_t) / 12
print(f"7. To prove a lift of EUR {delta:.3f} per visitor we'd need ~{n_needed:,.0f} visitors per variant "
      f"(~{2*n_needed/per_week:.0f} weeks at current traffic).")
print("=" * 64)
