"""
Generates a synthetic e-commerce / subscription dataset for the
From Data to Decisions. Deterministic (fixed seed) so results
are reproducible for anyone who clones the repo.

Built-in "stories" the analyses should uncover:
  1. Paid Social users retain worse than Organic / Referral users.
  2. A new onboarding flow launched 2025-07-01 improves retention
     for cohorts from July onwards.
  3. (sessions table) Mobile shoppers abandon at the payment step far
     more than desktop shoppers: a checkout problem, not a demand problem.
  4. (products) The best seller by number of orders is often not the
     best seller by revenue, and revenue is concentrated in a few products.
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

# ---------------------------------------------------------------
# Products (Case 05). Each order is matched to one product in its
# category, using its own random generator so nothing above changes.
# A product is more likely when it is popular AND its price is close
# to the order amount, so expensive orders go to expensive products.
# ---------------------------------------------------------------
import math
prng = random.Random(11)
PRODUCTS = {  # name: (price, popularity)
    "Electronics": {"Wireless Earbuds": (79, 10), "Bluetooth Speaker": (99, 7), "Smartwatch": (159, 5),
                    "USB-C Charger": (29, 9), "Noise-Cancelling Headphones": (189, 3), "Laptop Stand": (49, 4),
                    "HD Webcam": (69, 3), "E-reader": (129, 4)},
    "Home":        {"Scented Candle Set": (34, 8), "Linen Bedding Set": (89, 5), "Table Lamp": (59, 6),
                    "Ceramic Dinner Set": (79, 4), "Throw Blanket": (45, 7), "Wall Mirror": (69, 3),
                    "Storage Baskets": (29, 5), "Coffee Grinder": (55, 4)},
    "Fashion":     {"Cotton T-shirt": (22, 10), "Denim Jacket": (69, 4), "Leather Belt": (35, 5),
                    "Running Shoes": (85, 4), "Wool Scarf": (39, 6), "Summer Dress": (49, 6),
                    "Canvas Tote Bag": (25, 7), "Sunglasses": (55, 4)},
    "Books":       {"Bestseller Novel": (19, 10), "Cookbook": (28, 5), "Children's Picture Book": (14, 8),
                    "Travel Guide": (22, 4), "Self-help Book": (17, 7), "Graphic Novel": (24, 4)},
    "Beauty":      {"Face Moisturiser": (32, 9), "Lip Balm Set": (12, 8), "Hair Oil": (24, 5),
                    "Perfume 50ml": (65, 3), "Sunscreen SPF50": (19, 7), "Makeup Brush Set": (39, 4)},
}
products, pid_of = [], {}
pid = 1
for cat, items in PRODUCTS.items():
    for name, (price, _pop) in items.items():
        products.append((pid, name, cat, price)); pid_of[(cat, name)] = pid; pid += 1

def pick_product(cat, amount):
    names = list(PRODUCTS[cat])
    w = [PRODUCTS[cat][n][1] * math.exp(-((amount - PRODUCTS[cat][n][0]) / (0.35 * PRODUCTS[cat][n][0])) ** 2) + 1e-6
         for n in names]
    return pid_of[(cat, prng.choices(names, weights=w)[0])]

orders = [o + (pick_product(o[4], o[3]),) for o in orders]

con = sqlite3.connect("datasets/analytics.db")
cur = con.cursor()
cur.executescript("""
DROP TABLE IF EXISTS users; DROP TABLE IF EXISTS events; DROP TABLE IF EXISTS orders; DROP TABLE IF EXISTS products;
CREATE TABLE users  (user_id INTEGER PRIMARY KEY, signup_date TEXT, channel TEXT, country TEXT, device TEXT);
CREATE TABLE events (user_id INTEGER, event_date TEXT, event_type TEXT);
CREATE TABLE orders (order_id INTEGER PRIMARY KEY, user_id INTEGER, order_date TEXT, amount REAL, category TEXT, product_id INTEGER);
CREATE TABLE products (product_id INTEGER PRIMARY KEY, product_name TEXT, category TEXT, list_price REAL);
""")
cur.executemany("INSERT INTO users VALUES (?,?,?,?,?)", users)
cur.executemany("INSERT INTO events VALUES (?,?,?)", events)
cur.executemany("INSERT INTO orders VALUES (?,?,?,?,?,?)", orders)
cur.executemany("INSERT INTO products VALUES (?,?,?,?)", products)
# ---------------------------------------------------------------
# Sessions / checkout funnel (Case 02). Uses its own random
# generator so the tables above are unchanged.
# One row per session, with the furthest funnel step reached.
# ---------------------------------------------------------------
rng = random.Random(7)
STEP_RATES = {  # probability of reaching the next step, given the previous one
    "view_product": 0.62,
    "add_to_cart":  0.32,
    "checkout":     0.58,
}
PURCHASE_RATE = {"desktop": 0.72, "tablet": 0.64, "mobile": 0.39}  # checkout -> purchase
DEVICE_MIX = {"mobile": 0.58, "desktop": 0.32, "tablet": 0.10}
sessions = []
sid = 1
for (u_id, u_signup, u_channel, _country, _dev) in users:
    for _ in range(rng.randint(2, 9)):
        d = date.fromisoformat(u_signup) + timedelta(days=rng.randint(0, 120))
        if d > END:
            continue
        dev = rng.choices(list(DEVICE_MIX), weights=DEVICE_MIX.values())[0]
        step = "landing"
        for nxt, rate in STEP_RATES.items():
            if rng.random() < rate:
                step = nxt
            else:
                break
        if step == "checkout" and rng.random() < PURCHASE_RATE[dev]:
            step = "purchase"
        sessions.append((sid, u_id, d.isoformat(), dev, u_channel, step)); sid += 1

cur.executescript("""
DROP TABLE IF EXISTS sessions;
CREATE TABLE sessions (session_id INTEGER PRIMARY KEY, user_id INTEGER, session_date TEXT,
                       device TEXT, channel TEXT, furthest_step TEXT);
""")
cur.executemany("INSERT INTO sessions VALUES (?,?,?,?,?,?)", sessions)
con.commit()
print(f"users={len(users):,} events={len(events):,} orders={len(orders):,} sessions={len(sessions):,} products={len(products)}")
