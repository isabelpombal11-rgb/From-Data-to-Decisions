"""
Generates a synthetic e-commerce / subscription dataset for the
From Data to Decisions. Deterministic (fixed seed) so results
are reproducible for anyone who clones the repo.

Built-in "stories" the analyses should uncover:
  1. Paid Social users retain worse than Organic / Referral users.
  2. A new onboarding flow launched 2025-07-01 improves retention
     for cohorts from July onwards.
"""
import sqlite3, random
from datetime import date, timedelta

random.seed(42)
START, END = date(2025, 1, 1), date(2025, 12, 31)
CHANNELS = {"Organic": 0.30, "Paid Search": 0.25, "Paid Social": 0.25, "Referral": 0.20}
# base probability a user is active k months after signup
CHANNEL_RETENTION = {"Organic": 0.55, "Paid Search": 0.45, "Paid Social": 0.30, "Referral": 0.60}
COUNTRIES = ["Portugal", "Spain", "France", "Germany", "Angola", "Brazil"]
DEVICES = ["mobile", "desktop", "tablet"]
CATEGORIES = {"Electronics": 120, "Home": 60, "Fashion": 45, "Books": 20, "Beauty": 30}
ONBOARDING_LAUNCH = date(2025, 7, 1)

def weighted(d):
    return random.choices(list(d), weights=d.values())[0]

users, events, orders = [], [], []
uid, oid = 1, 1
day = START
while day <= END:
    for _ in range(random.randint(8, 16)):            # signups per day
        ch = weighted(CHANNELS)
        users.append((uid, day.isoformat(), ch, random.choice(COUNTRIES), random.choice(DEVICES)))
        base = CHANNEL_RETENTION[ch] + (0.12 if day >= ONBOARDING_LAUNCH else 0)
        events.append((uid, day.isoformat(), "signup"))
        month_offset = 0
        active = True
        while active:
            m_start = day + timedelta(days=30 * month_offset)
            if m_start > END:
                break
            # number of active days this "user-month"
            for _ in range(random.randint(1, 6)):
                d = m_start + timedelta(days=random.randint(0, 29))
                if d <= END:
                    events.append((uid, d.isoformat(), random.choice(["login", "view_product", "add_to_cart"])))
                    if random.random() < 0.25:
                        cat = random.choice(list(CATEGORIES))
                        amt = round(max(5, random.gauss(CATEGORIES[cat], CATEGORIES[cat] * 0.3)), 2)
                        orders.append((oid, uid, d.isoformat(), amt, cat)); oid += 1
            month_offset += 1
            # retention decays a little each month, never below a floor
            active = random.random() < max(0.15, base * (0.97 ** month_offset) + 0.25)
        uid += 1
    day += timedelta(days=1)

con = sqlite3.connect("datasets/analytics.db")
cur = con.cursor()
cur.executescript("""
DROP TABLE IF EXISTS users; DROP TABLE IF EXISTS events; DROP TABLE IF EXISTS orders;
CREATE TABLE users  (user_id INTEGER PRIMARY KEY, signup_date TEXT, channel TEXT, country TEXT, device TEXT);
CREATE TABLE events (user_id INTEGER, event_date TEXT, event_type TEXT);
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, user_id INTEGER, order_date TEXT, amount REAL, category TEXT);
""")
cur.executemany("INSERT INTO users VALUES (?,?,?,?,?)", users)
cur.executemany("INSERT INTO events VALUES (?,?,?)", events)
cur.executemany("INSERT INTO orders VALUES (?,?,?,?,?)", orders)
con.commit()
print(f"users={len(users):,} events={len(events):,} orders={len(orders):,}")
