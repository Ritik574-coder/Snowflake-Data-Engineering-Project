import json
import random
import unicodedata
from datetime import date, timedelta
from collections import Counter

random.seed(7)

def esc(s):
    return str(s).replace("'", "''")

def rand_date(start, end):
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))

def email_part(s):
    s = unicodedata.normalize('NFKD', s).encode('ascii', 'ignore').decode('ascii')
    return ''.join(ch for ch in s.lower() if ch.isalnum())

TODAY = date(2026, 8, 30)

FIRST_NAMES = ["Emma","Liam","Olivia","Noah","Ava","Ethan","Sophia","Mason","Isabella","Lucas",
    "Mia","Elijah","Charlotte","James","Amelia","Benjamin","Harper","Henry","Evelyn",
    "Alexander","Abigail","Michael","Emily","Daniel","Elizabeth","Matthew","Sofia",
    "William","Avery","David","Jose","Francois","Priya","Wei","Sean","Nadia"]
LAST_NAMES = ["Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez",
    "Martinez","Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor",
    "Moore","Jackson","Martin","Lee","Perez","Thompson","White","Harris","Clark",
    "Lewis","Robinson","Walker","Young","Nguyen","Dubois"]
# Forced apostrophe-containing names so quote-escaping is guaranteed testable, regardless of RNG.
FORCED_LAST_NAMES = {0: "O'Brien", 7: "D'Souza", 15: "N'Diaye"}

CITIES = [
    ("New York", "NY", "USA", 40.7128, -74.0060),
    ("Los Angeles", "CA", "USA", 34.0522, -118.2437),
    ("Chicago", "IL", "USA", 41.8781, -87.6298),
    ("Houston", "TX", "USA", 29.7604, -95.3698),
    ("Phoenix", "AZ", "USA", 33.4484, -112.0740),
    ("Philadelphia", "PA", "USA", 39.9526, -75.1652),
    ("San Diego", "CA", "USA", 32.7157, -117.1611),
    ("Dallas", "TX", "USA", 32.7767, -96.7970),
    ("Austin", "TX", "USA", 30.2672, -97.7431),
    ("Seattle", "WA", "USA", 47.6062, -122.3321),
    ("Denver", "CO", "USA", 39.7392, -104.9903),
    ("Toronto", "ON", "Canada", 43.6532, -79.3832),
    ("Vancouver", "BC", "Canada", 49.2827, -123.1207),
    ("London", "England", "UK", 51.5074, -0.1278),
    ("Berlin", "Berlin", "Germany", 52.5200, 13.4050),
    ("Sydney", "NSW", "Australia", -33.8688, 151.2093),
    ("Paris", "Ile-de-France", "France", 48.8566, 2.3522),
]

DEVICE_TYPES = ["mobile", "desktop", "tablet"]
OS_BY_DEVICE = {"mobile": ["iOS", "Android"], "desktop": ["Windows", "macOS", "Linux"], "tablet": ["iPadOS", "Android"]}
LANGS = ["en", "es", "fr", "de", "pt"]
CURRENCIES = ["USD", "EUR", "GBP", "CAD", "AUD"]
CHANNELS = ["email", "sms", "push", "postal_mail"]
TIERS = ["bronze", "silver", "gold", "platinum"]

CATEGORIES = {
    "Electronics": {"brands": ["TechNova", "SoundWave", "PixelEdge", "CoreLogic"],
        "items": ["Wireless Bluetooth Headphones", "27-inch 4K Monitor", "Mechanical Keyboard",
                  "Portable SSD 1TB", "Smart Home Speaker", "Noise Cancelling Earbuds",
                  "Wireless Charging Pad", "USB-C Hub Adapter"], "price_range": (25, 450)},
    "Home & Kitchen": {"brands": ["HearthCraft", "KitchenPro", "HomeEase"],
        "items": ["Stainless Steel Cookware Set", "Espresso Machine", "Air Fryer",
                  "Robot Vacuum", "Ceramic Dinnerware Set", "Electric Kettle"], "price_range": (30, 400)},
    "Sportswear": {"brands": ["PeakForm", "TrailBlaze", "ActiveCore"],
        "items": ["Running Shoes", "Yoga Mat", "Compression Leggings", "Insulated Water Bottle"], "price_range": (15, 140)},
    "Books": {"brands": ["Lantern Press", "Northwind Publishing"],
        "items": ["The Long Horizon (Novel)", "Cooking with Fire (Cookbook)", "Modern Data Systems (Textbook)"], "price_range": (12, 60)},
    "Beauty": {"brands": ["GlowLab", "PureDerm"],
        "items": ["Vitamin C Serum", "Hydrating Face Cream", "Mineral Sunscreen SPF50"], "price_range": (10, 65)},
    "Outdoor": {"brands": ["SummitGear", "WildTrail"],
        "items": ["2-Person Camping Tent", "Hiking Backpack 40L", "Insulated Sleeping Bag"], "price_range": (40, 320)},
    "Office Supplies": {"brands": ["OfficeForm", "DeskPro"],
        "items": ["Ergonomic Office Chair", "Standing Desk Converter", "LED Desk Lamp"], "price_range": (25, 380)},
    "Furniture": {"brands": ["UrbanNest", "CraftHouse"],
        "items": ["Solid Wood Bookshelf", "Modern Accent Chair", "3-Seat Fabric Sofa"], "price_range": (90, 900)},
    "Automotive": {"brands": ["DriveTech", "AutoEdge"],
        "items": ["Dash Cam 1080p", "Car Phone Mount", "Portable Tire Inflator"], "price_range": (18, 150)},
}
SUBCATS = {
    "Electronics": ["Audio","Computing Accessories","Smart Home","Storage"],
    "Home & Kitchen": ["Cookware","Small Appliances","Dinnerware"],
    "Sportswear": ["Footwear","Apparel","Accessories"],
    "Books": ["Fiction","Non-Fiction","Reference"],
    "Beauty": ["Skincare","Suncare"],
    "Outdoor": ["Camping","Hiking Gear"],
    "Office Supplies": ["Seating","Desks","Lighting"],
    "Furniture": ["Storage","Seating","Sofas"],
    "Automotive": ["Electronics","Accessories"],
}
SUPPLIERS = [
    ("SUP-001", "Pacific Rim Manufacturing", "China"),
    ("SUP-002", "EuroGoods Trading Co.", "Germany"),
    ("SUP-003", "Global Source Partners", "USA"),
    ("SUP-004", "Northland Distributors", "Canada"),
    ("SUP-005", "Shenzhen Innovate Ltd.", "China"),
    ("SUP-006", "Atlas Wholesale", "Mexico"),
    ("SUP-007", "Meridian Supply Chain", "India"),
    ("SUP-008", "Sao Paulo Export Group", "Brazil"),
]
REVIEW_COMMENTS = [
    "Great value for the price!", "Works exactly as described.",
    "Shipping was fast and the quality is solid.", "Not as durable as I expected.",
    "Exceeded my expectations, would buy again.", "Decent, but there's room for improvement.",
    "Perfect for everyday use.", "Arrived slightly damaged, but support fixed it quickly.",
    "Exactly what I needed, no complaints.", "Good product overall, packaging could be better.",
    None, None
]
PAYMENT_METHODS = ["credit_card", "paypal", "gift_card", "bank_transfer"]
ORDER_STATUSES = ["pending", "processing", "shipped", "delivered", "cancelled"]
ORDER_CHANNELS = ["web", "mobile_app", "in_store", "phone"]
SHIP_METHODS = ["standard", "express", "overnight", "pickup"]
CARRIERS = ["UPS", "FedEx", "USPS", "DHL"]
STREETS = ["Maple","Oak","Cedar","Sunset","Main","Highland","River","Lake","Pine","Elm"]
STREET_TYPES = ["St","Ave","Blvd","Rd","Ln"]

def rand_street():
    return f"{random.randint(10,9999)} {random.choice(STREETS)} {random.choice(STREET_TYPES)}"

def rand_zip(country):
    return f"{random.randint(10000,99999)}" if country == "USA" else f"{random.randint(1000,9999)}"

# ---------------- CUSTOMERS ----------------
NUM_CUSTOMERS = 30
customers = []
for i in range(NUM_CUSTOMERS):
    cid = 1001 + i
    first = random.choice(FIRST_NAMES)
    last = FORCED_LAST_NAMES.get(i, random.choice(LAST_NAMES))
    name = f"{first} {last}"
    city, region, country, lat, lng = random.choice(CITIES)
    join_date = rand_date(date(2021,1,1), date(2026,6,1))
    birth_date = rand_date(date(1965,1,1), date(2005,1,1))

    profile = {
        "first_name": first,
        "last_name": last,
        "email": f"{email_part(first)}.{email_part(last)}{random.randint(1,999)}@{random.choice(['gmail.com','yahoo.com','outlook.com','icloud.com'])}",
        "loyalty_tier": random.choice(TIERS),
        "join_date": join_date.isoformat(),
        "is_active": random.random() > 0.12,
        "account_balance": round(random.uniform(0, 500), 2),
        "lifetime_value": round(random.uniform(50, 8000), 2),
    }
    if random.random() > 0.2:
        profile["phone"] = f"+1-{random.randint(200,999)}-{random.randint(200,999)}-{random.randint(1000,9999)}"
    if random.random() > 0.3:
        profile["birth_date"] = birth_date.isoformat()
    profile["gender"] = random.choice(["female","male","non-binary",None,None])

    address = {
        "street": rand_street(),
        "city": city,
        "zip": rand_zip(country),
        "country": country,
        "type": random.choice(["shipping","billing"]),
    }
    if country in ("USA","Canada") or random.random() > 0.5:
        address["state"] = region
    if random.random() > 0.25:
        address["coordinates"] = {"lat": round(lat + random.uniform(-0.05,0.05), 4), "lng": round(lng + random.uniform(-0.05,0.05), 4)}

    preferences = {
        "newsletter_opt_in": random.random() > 0.4,
        "preferred_language": random.choice(LANGS),
        "preferred_currency": random.choice(CURRENCIES),
        "marketing_channels": random.sample(CHANNELS, k=random.randint(0,3)),
        "notification_settings": {
            "email": random.random() > 0.2,
            "sms": random.random() > 0.6,
            "push": random.random() > 0.5
        }
    }

    devices = []
    for _ in range(random.randint(0,3)):
        dtype = random.choice(DEVICE_TYPES)
        devices.append({
            "device_id": f"DEV-{random.randint(100000,999999)}",
            "device_type": dtype,
            "os": random.choice(OS_BY_DEVICE[dtype]),
            "last_login": f"{rand_date(date(2026,6,1), TODAY).isoformat()}T{random.randint(0,23):02d}:{random.randint(0,59):02d}:00Z",
            "is_trusted": random.random() > 0.3
        })

    data = {"profile": profile, "address": address, "preferences": preferences, "devices": devices}
    customers.append({"customer_id": cid, "customer_name": name, "data": data})

# ---------------- PRODUCTS ----------------
NUM_PRODUCTS = 32
products = []
cat_names = list(CATEGORIES.keys())
for i in range(NUM_PRODUCTS):
    pid = f"PROD-{i+1:04d}"
    cat = cat_names[i % len(cat_names)]
    cat_info = CATEGORIES[cat]
    brand = random.choice(cat_info["brands"])
    item_name = random.choice(cat_info["items"])
    lo, hi = cat_info["price_range"]
    base_price = round(random.uniform(lo, hi), 2)

    specs = {
        "category": cat,
        "brand": brand,
        "color_options": random.sample(["Black","White","Silver","Blue","Red","Green","Gray"], k=random.randint(0,4)),
    }
    if random.random() > 0.3:
        specs["subcategory"] = random.choice(SUBCATS.get(cat, [cat]))
    if cat != "Books":
        specs["weight_kg"] = round(random.uniform(0.1, 15.0), 2)
        specs["dimensions"] = {
            "length": round(random.uniform(5,120),1),
            "width": round(random.uniform(5,80),1),
            "height": round(random.uniform(2,80),1),
            "unit": "cm"
        }
    else:
        specs["weight_kg"] = round(random.uniform(0.2, 1.2), 2)
    if random.random() > 0.5:
        specs["material"] = random.choice(["Plastic","Aluminum","Stainless Steel","Cotton","Wood","Glass","Silicone"])

    pricing = {"base_price": base_price, "currency": "USD", "tax_rate": round(random.uniform(0.0, 0.095), 4)}
    if random.random() > 0.5:
        pricing["discount_percentage"] = random.choice([0, 5, 10, 15, 20])
    if random.random() > 0.4:
        pricing["cost_price"] = round(base_price * random.uniform(0.4,0.7), 2)
    if random.random() > 0.5:
        hist = []
        for h in range(random.randint(1,3)):
            hist.append({"date": rand_date(date(2025,1,1), TODAY).isoformat(), "price": round(base_price * random.uniform(0.85,1.1), 2)})
        pricing["price_history"] = hist

    sup_choices = random.sample(SUPPLIERS, k=random.randint(1,3))
    suppliers = []
    for idx, (sid, sname, scountry) in enumerate(sup_choices):
        suppliers.append({"supplier_id": sid, "supplier_name": sname, "country": scountry,
                           "lead_time_days": random.randint(3,45), "is_primary": idx == 0})

    reviews = []
    num_reviews = random.choices([0,1,2,3,4,5,6], weights=[15,15,20,20,15,10,5])[0]
    for r in range(num_reviews):
        anon = random.random() > 0.7
        reviews.append({
            "review_id": f"REV-{pid}-{r+1:02d}",
            "customer_id": None if anon else random.choice(customers)["customer_id"],
            "rating": random.randint(1,5),
            "comment": random.choice(REVIEW_COMMENTS),
            "review_date": rand_date(date(2025,6,1), TODAY).isoformat(),
            "verified_purchase": random.random() > 0.25
        })

    data = {"specifications": specs, "pricing": pricing, "suppliers": suppliers, "reviews": reviews}
    products.append({"product_id": pid, "name": f"{brand} {item_name}", "base_price": base_price, "data": data})

# ---------------- ORDERS ----------------
orders = []
order_counter = 1
for c in customers:
    n_orders = random.choices([1,2,3], weights=[45,35,20])[0]
    for _ in range(n_orders):
        order_id = f"ORD-{order_counter:05d}"
        order_counter += 1
        order_date = rand_date(date(2025,9,1), TODAY)
        status = random.choice(ORDER_STATUSES)

        n_items = random.randint(2,5)
        chosen_products = random.sample(products, k=n_items)
        items = []
        subtotal = 0.0
        for p in chosen_products:
            qty = random.randint(1,4)
            unit_price = p["base_price"]
            line_total = round(qty * unit_price, 2)
            subtotal += line_total
            item = {"product_id": p["product_id"], "product_name": p["name"], "quantity": qty,
                     "unit_price": unit_price, "line_total": line_total}
            if random.random() > 0.5:
                item["options"] = {"color": random.choice(["Black","White","Blue","Red",None]),
                                    "size": random.choice(["S","M","L","XL",None])}
            items.append(item)

        discounts = []
        if random.random() > 0.55:
            for _ in range(random.randint(1,2)):
                dtype = random.choice(["percentage","fixed_amount"])
                if dtype == "percentage":
                    val = random.choice([5,10,15,20])
                    applied = round(subtotal * val/100, 2)
                else:
                    val = random.choice([5,10,15,25])
                    applied = float(val)
                discounts.append({"code": f"SAVE{val}{random.choice(['','X','NOW'])}", "type": dtype,
                                   "value": val, "applied_amount": applied})
        discount_total = sum(d["applied_amount"] for d in discounts)

        ship_method = random.choice(SHIP_METHODS)
        shipping_cost = 0.0 if ship_method == "pickup" else random.choice([0,4.99,7.99,12.99,19.99])
        ship_city = random.choice(CITIES)
        shipping_address = {"street": rand_street(), "city": ship_city[0], "state": ship_city[1],
                             "zip": rand_zip(ship_city[2]), "country": ship_city[2]}

        amount_paid = round(subtotal - discount_total + shipping_cost, 2)

        order_details = {
            "order_date": f"{order_date.isoformat()}T{random.randint(0,23):02d}:{random.randint(0,59):02d}:00Z",
            "order_status": status,
            "order_channel": random.choice(ORDER_CHANNELS),
            "currency": "USD",
        }
        if random.random() > 0.7:
            order_details["notes"] = random.choice([
                "Please leave package at front door.", "Gift wrap requested.",
                "Customer requested expedited handling.", None])

        payment = {
            "method": random.choice(PAYMENT_METHODS),
            "transaction_id": f"TXN-{random.randint(10**9,10**10-1)}",
            "amount_paid": amount_paid,
            "payment_status": "refunded" if status=="cancelled" else random.choice(["paid","paid","paid","pending"])
        }
        if payment["method"] == "credit_card":
            payment["card_last4"] = f"{random.randint(1000,9999)}"
        if random.random() > 0.2:
            if random.random() > 0.3:
                payment["billing_address"] = dict(shipping_address)
            else:
                bcity = random.choice(CITIES)
                payment["billing_address"] = {"street": rand_street(), "city": bcity[0], "state": bcity[1],
                                               "zip": rand_zip(bcity[2]), "country": bcity[2]}

        shipping = {
            "method": ship_method,
            "carrier": None if ship_method=="pickup" else random.choice(CARRIERS),
            "tracking_number": None if status in ("pending","processing") else f"1Z{random.randint(10**8,10**9-1)}",
            "estimated_delivery": (order_date + timedelta(days=random.randint(2,10))).isoformat(),
            "shipping_address": shipping_address,
            "cost": shipping_cost
        }

        data = {"order_details": order_details, "items": items, "payment": payment, "shipping": shipping}
        if discounts or random.random() > 0.3:
            data["discounts"] = discounts

        orders.append({"order_id": order_id, "customer_id": c["customer_id"], "data": data})

orders.sort(key=lambda o: o["order_id"])

# ---------------- WRITE SQL ----------------
lines = []
lines.append("-- =====================================================================")
lines.append("-- Synthetic seed data for customers, orders, and products (Snowflake)")
lines.append(f"-- Generated rows: {len(customers)} customers, {len(products)} products, {len(orders)} orders")
lines.append("-- All data is fictional and generated for testing/demo purposes only.")
lines.append("-- =====================================================================")
lines.append("")
lines.append("-- ---------------------------------------------------------------------")
lines.append("-- CUSTOMERS")
lines.append("-- ---------------------------------------------------------------------")
for c in customers:
    json_str = esc(json.dumps(c["data"], ensure_ascii=False))
    name = esc(c["customer_name"])
    lines.append(f"INSERT INTO customers (customer_id, customer_name, customer_data) VALUES ({c['customer_id']}, '{name}', PARSE_JSON('{json_str}'));")

lines.append("")
lines.append("-- ---------------------------------------------------------------------")
lines.append("-- PRODUCTS")
lines.append("-- ---------------------------------------------------------------------")
for p in products:
    json_str = esc(json.dumps(p["data"], ensure_ascii=False))
    lines.append(f"INSERT INTO products (product_id, product_data) VALUES ('{p['product_id']}', PARSE_JSON('{json_str}'));")

lines.append("")
lines.append("-- ---------------------------------------------------------------------")
lines.append("-- ORDERS")
lines.append("-- ---------------------------------------------------------------------")
for o in orders:
    json_str = esc(json.dumps(o["data"], ensure_ascii=False))
    lines.append(f"INSERT INTO orders (order_id, customer_id, order_data) VALUES ('{o['order_id']}', {o['customer_id']}, PARSE_JSON('{json_str}'));")

with open("/content/seed_data.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(lines) + "\n")

# ---------------- VALIDATION ----------------
cust_ids = {c["customer_id"] for c in customers}
prod_ids = {p["product_id"] for p in products}
order_cust_ok = all(o["customer_id"] in cust_ids for o in orders)
item_prod_ok = all(all(item["product_id"] in prod_ids for item in o["data"]["items"]) for o in orders)

for c in customers: json.loads(json.dumps(c["data"]))
for p in products: json.loads(json.dumps(p["data"]))
for o in orders: json.loads(json.dumps(o["data"]))

oc = Counter(o["customer_id"] for o in orders)
multi = sum(1 for v in oc.values() if v > 1)

print(f"customers: {len(customers)}")
print(f"products: {len(products)}")
print(f"orders: {len(orders)}")
print(f"order.customer_id all reference existing customers: {order_cust_ok}")
print(f"item.product_id all reference existing products: {item_prod_ok}")
print(f"customers with 2+ orders: {multi} / {len(cust_ids)}")
print(f"items per order range: {min(len(o['data']['items']) for o in orders)}-{max(len(o['data']['items']) for o in orders)}")
print("all embedded JSON payloads parse cleanly: True")