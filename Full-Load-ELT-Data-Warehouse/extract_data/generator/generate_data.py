"""
Airline Reservation System - Synthetic Data Generator
=======================================================

Generates a production-inspired, realistic (but internally consistent)
airline reservation dataset for Data Engineering / Snowflake practice.

- No impossible data (no negative ages, no arrival-before-departure, etc.)
- Includes realistic operational "dirtiness" (whitespace, casing, duplicate
  emails/phones, missing optional fields, inconsistent country naming, etc.)
- All foreign keys are valid (no orphan records).
- Deterministic via a fixed random seed.

Run:
    python generate_data.py --outdir ../data

Output: ~32 CSV files.
"""

import os
import argparse
import numpy as np
import pandas as pd
from datetime import datetime, timedelta

# ----------------------------------------------------------------------------
# CONFIG
# ----------------------------------------------------------------------------

SEED = 42
RNG = np.random.default_rng(SEED)

TODAY = datetime(2026, 8, 3)

# Row-count targets. Big transactional tables are intentionally large;
# dimension/reference tables stay small, as a real warehouse would look.
N_AIRLINES = 20
N_AIRCRAFT_MODELS = 25
N_AIRPORTS = 250
N_AIRCRAFT = 600
N_CREW = 2500
N_GATES = 600
N_ROUTES = 900
N_SCHEDULES = 2500
N_CUSTOMERS = 60000
N_LOYALTY_RATE = 0.55          # fraction of customers who are loyalty members
N_FLIGHTS = 80000
N_WEATHER = 40000
N_MAINTENANCE_LOGS = 6000
N_AIRCRAFT_MAINT_HISTORY = 8000
N_SUPPORT_TICKETS = 15000
N_FEEDBACK = 25000

FLIGHT_DATE_START = datetime(2025, 8, 1)
FLIGHT_DATE_END = datetime(2026, 8, 15)

OUT_DIR = None  # set in main()


def outp(name):
    return os.path.join(OUT_DIR, name)


# ----------------------------------------------------------------------------
# NAME / TEXT POOLS (hand-built, no external dependency needed)
# ----------------------------------------------------------------------------

FIRST_NAMES = [
    "James","Mary","John","Patricia","Robert","Jennifer","Michael","Linda","William","Elizabeth",
    "David","Barbara","Richard","Susan","Joseph","Jessica","Thomas","Sarah","Charles","Karen",
    "Christopher","Nancy","Daniel","Lisa","Matthew","Margaret","Anthony","Betty","Mark","Sandra",
    "Donald","Ashley","Steven","Dorothy","Paul","Kimberly","Andrew","Emily","Joshua","Donna",
    "Kenneth","Michelle","Kevin","Carol","Brian","Amanda","George","Melissa","Timothy","Deborah",
    "Ronald","Stephanie","Edward","Rebecca","Jason","Sharon","Jeffrey","Laura","Ryan","Cynthia",
    "Jacob","Kathleen","Gary","Amy","Nicholas","Shirley","Eric","Angela","Jonathan","Helen",
    "Stephen","Anna","Larry","Brenda","Justin","Pamela","Scott","Nicole","Brandon","Emma",
    "Benjamin","Samantha","Samuel","Katherine","Frank","Christine","Gregory","Debra","Raymond","Rachel",
    "Alexander","Carolyn","Patrick","Janet","Jack","Catherine","Dennis","Maria","Jerry","Heather",
    "Priya","Wei","Chen","Yuki","Hiro","Fatima","Ahmed","Mohammed","Olga","Ivan",
    "Liam","Noah","Sofia","Diego","Carlos","Ana","Elena","Dmitri","Sven","Freya",
]

LAST_NAMES = [
    "Smith","Johnson","Williams","Brown","Jones","Garcia","Miller","Davis","Rodriguez","Martinez",
    "Hernandez","Lopez","Gonzalez","Wilson","Anderson","Thomas","Taylor","Moore","Jackson","Martin",
    "Lee","Perez","Thompson","White","Harris","Sanchez","Clark","Ramirez","Lewis","Robinson",
    "Walker","Young","Allen","King","Wright","Scott","Torres","Nguyen","Hill","Flores",
    "Green","Adams","Nelson","Baker","Hall","Rivera","Campbell","Mitchell","Carter","Roberts",
    "Kim","Patel","Chen","Wang","Singh","Kumar","Khan","Ali","Ivanov","Muller",
    "Schmidt","Rossi","Dubois","Silva","Costa","Andersson","Johansson","Kowalski","Novak","Tanaka",
    "Suzuki","Watanabe","Yamamoto","Park","Choi","Santos","Oliveira","Pereira","Fernandez","Diaz",
]

CITY_COUNTRY = [
    ("New York","United States"),("Los Angeles","United States"),("Chicago","United States"),
    ("Dallas","United States"),("Atlanta","United States"),("Miami","United States"),
    ("San Francisco","United States"),("Seattle","United States"),("Denver","United States"),
    ("Boston","United States"),("Toronto","Canada"),("Vancouver","Canada"),("Montreal","Canada"),
    ("Mexico City","Mexico"),("London","United Kingdom"),("Manchester","United Kingdom"),
    ("Paris","France"),("Nice","France"),("Berlin","Germany"),("Frankfurt","Germany"),
    ("Munich","Germany"),("Madrid","Spain"),("Barcelona","Spain"),("Rome","Italy"),
    ("Milan","Italy"),("Amsterdam","Netherlands"),("Zurich","Switzerland"),("Vienna","Austria"),
    ("Dublin","Ireland"),("Lisbon","Portugal"),("Copenhagen","Denmark"),("Stockholm","Sweden"),
    ("Oslo","Norway"),("Helsinki","Finland"),("Warsaw","Poland"),("Prague","Czech Republic"),
    ("Athens","Greece"),("Istanbul","Turkey"),("Dubai","United Arab Emirates"),
    ("Abu Dhabi","United Arab Emirates"),("Doha","Qatar"),("Riyadh","Saudi Arabia"),
    ("Cairo","Egypt"),("Nairobi","Kenya"),("Johannesburg","South Africa"),("Lagos","Nigeria"),
    ("Mumbai","India"),("Delhi","India"),("Bengaluru","India"),("Chennai","India"),
    ("Singapore","Singapore"),("Bangkok","Thailand"),("Kuala Lumpur","Malaysia"),
    ("Jakarta","Indonesia"),("Manila","Philippines"),("Hong Kong","China"),
    ("Shanghai","China"),("Beijing","China"),("Tokyo","Japan"),("Osaka","Japan"),
    ("Seoul","South Korea"),("Sydney","Australia"),("Melbourne","Australia"),
    ("Auckland","New Zealand"),("Sao Paulo","Brazil"),("Rio de Janeiro","Brazil"),
    ("Buenos Aires","Argentina"),("Santiago","Chile"),("Bogota","Colombia"),
    ("Lima","Peru"),("Moscow","Russia"),("St. Petersburg","Russia"),
    ("Reykjavik","Iceland"),("Brussels","Belgium"),("Zagreb","Croatia"),
    ("Budapest","Hungary"),("Bucharest","Romania"),("Casablanca","Morocco"),
    ("Tunis","Tunisia"),("Tel Aviv","Israel"),("Amman","Jordan"),("Karachi","Pakistan"),
    ("Dhaka","Bangladesh"),("Colombo","Sri Lanka"),("Hanoi","Vietnam"),
    ("Ho Chi Minh City","Vietnam"),("Taipei","Taiwan"),("Houston","United States"),
    ("Phoenix","United States"),("Philadelphia","United States"),("San Diego","United States"),
    ("Orlando","United States"),("Las Vegas","United States"),("Portland","United States"),
    ("Calgary","Canada"),("Ottawa","Canada"),("Edinburgh","United Kingdom"),
    ("Birmingham","United Kingdom"),("Lyon","France"),("Hamburg","Germany"),("Cologne","Germany"),
]

# Small country-name inconsistencies used for dirtiness in customers.nationality
COUNTRY_VARIANTS = {
    "United States": ["United States", "USA", "U.S.A.", "United States of America", "us"],
    "United Kingdom": ["United Kingdom", "UK", "U.K.", "Britain"],
    "United Arab Emirates": ["United Arab Emirates", "UAE", "U.A.E."],
}

AIRLINE_NAME_ROOTS = [
    "Skyward","Continental","Pacific","Atlantic","Northern","Southern","Global","Horizon",
    "Summit","Falcon","Eagle","Star","Metro","Regional","Blue","Golden","Silver","Coastal",
    "Union","Alliance","Sunrise","Meridian","Prime","National","Crown","Voyager",
]
AIRLINE_SUFFIXES = ["Airlines", "Airways", "Air", "Aviation", "Jet"]

AIRCRAFT_MANUFACTURERS = ["Boeing", "Airbus", "Embraer", "Bombardier"]
AIRCRAFT_FAMILIES = {
    "Boeing": [("737-800", 189, 5765), ("737 MAX 8", 178, 6570), ("777-300ER", 396, 13650),
               ("787-9", 296, 14140), ("767-300", 261, 11070), ("747-8", 410, 14310)],
    "Airbus": [("A320", 180, 6100), ("A321neo", 220, 7400), ("A330-300", 335, 11750),
               ("A350-900", 325, 15000), ("A380-800", 555, 15200), ("A319", 156, 6850)],
    "Embraer": [("E175", 88, 3334), ("E190", 106, 4260), ("E195-E2", 146, 4800)],
    "Bombardier": [("CRJ900", 90, 2956), ("Q400", 78, 2040)],
}

CREW_ROLES = ["Captain", "First Officer", "Purser", "Flight Attendant", "Flight Attendant", "Flight Attendant"]

FARE_CLASSES = ["Economy", "Premium Economy", "Business", "First"]
FARE_CLASS_WEIGHTS = [0.72, 0.14, 0.11, 0.03]

PAYMENT_METHODS = ["Credit Card", "Debit Card", "PayPal", "Bank Transfer", "Gift Card"]
BOOKING_CHANNELS = ["Website", "Mobile App", "Travel Agent", "Call Center", "Airport Kiosk"]

DELAY_REASONS = ["Weather", "Air Traffic Control", "Mechanical Issue", "Crew Availability",
                  "Late Aircraft Arrival", "Security", "Airport Operations"]
CANCELLATION_REASONS = ["Severe Weather", "Mechanical Issue", "Crew Shortage",
                          "Air Traffic Control", "Low Booking Demand", "Airport Closure"]
SUPPORT_ISSUE_TYPES = ["Booking Issue", "Refund Request", "Baggage Complaint", "Flight Delay Complaint",
                         "Website/App Issue", "Seat Change Request", "Loyalty Points Issue", "General Inquiry"]
ANCILLARY_TYPES = ["Extra Baggage", "Seat Upgrade", "In-flight Meal", "Wi-Fi", "Priority Boarding",
                     "Lounge Access", "Travel Insurance", "Pet Fee"]
WEATHER_CONDITIONS_LIST = ["Clear", "Partly Cloudy", "Cloudy", "Rain", "Thunderstorm", "Snow", "Fog", "Windy"]


def pad_id(prefix, n, width=6):
    return np.array([f"{prefix}{i:0{width}d}" for i in range(1, n + 1)])


def choice(pool, size, p=None):
    return RNG.choice(pool, size=size, p=p)


def random_dates(start, end, size):
    """Vectorized random datetime between start and end (date only, returns np.array of datetime)."""
    delta_days = (end - start).days
    offsets = RNG.integers(0, delta_days + 1, size=size)
    return np.array([start + timedelta(days=int(o)) for o in offsets])


def dirty_case(s, rng_vals):
    """Apply random casing noise to a subset of strings based on rng_vals in [0,1)."""
    out = []
    for val, r in zip(s, rng_vals):
        if r < 0.03:
            out.append(val.upper())
        elif r < 0.06:
            out.append(val.lower())
        elif r < 0.09:
            out.append(f"  {val}  ")
        elif r < 0.11:
            out.append(f" {val}")
        else:
            out.append(val)
    return out


def save(df, name):
    path = outp(f"{name}.csv")
    df.to_csv(path, index=False)
    size_mb = os.path.getsize(path) / (1024 * 1024)
    print(f"  wrote {name:32s} rows={len(df):>8,d}   size={size_mb:8.2f} MB")


# ----------------------------------------------------------------------------
# DIMENSION / REFERENCE TABLES
# ----------------------------------------------------------------------------

def gen_airlines():
    ids = pad_id("AL", N_AIRLINES, 4)
    names = []
    used = set()
    for _ in range(N_AIRLINES):
        while True:
            nm = f"{RNG.choice(AIRLINE_NAME_ROOTS)} {RNG.choice(AIRLINE_SUFFIXES)}"
            if nm not in used:
                used.add(nm)
                names.append(nm)
                break
    iata = []
    used_codes = set()
    for _ in range(N_AIRLINES):
        while True:
            code = "".join(RNG.choice(list("ABCDEFGHJKLMNPQRSTUVWXYZ"), 2))
            if code not in used_codes:
                used_codes.add(code)
                iata.append(code)
                break
    countries = choice([c for _, c in CITY_COUNTRY], N_AIRLINES)
    active = choice([True, False], N_AIRLINES, p=[0.93, 0.07])
    df = pd.DataFrame({
        "airline_id": ids, "airline_name": names, "iata_code": iata,
        "country": countries, "active_flag": active,
    })
    save(df, "airlines")
    return df


def gen_aircraft_models():
    rows = []
    mid = 1
    combos = []
    for manu, fam in AIRCRAFT_FAMILIES.items():
        for model_name, cap, rng_km in fam:
            combos.append((manu, model_name, cap, rng_km))
    # replicate/perturb to reach N_AIRCRAFT_MODELS
    while len(combos) < N_AIRCRAFT_MODELS:
        manu, model_name, cap, rng_km = combos[len(combos) % len(AIRCRAFT_FAMILIES)]
        combos.append((manu, model_name + "R", cap - 10, rng_km + 500))
    combos = combos[:N_AIRCRAFT_MODELS]
    for manu, model_name, cap, rng_km in combos:
        category = "Wide-body" if cap > 250 else ("Regional Jet" if cap < 120 else "Narrow-body")
        rows.append((f"AM{mid:04d}", manu, model_name, cap, rng_km, category))
        mid += 1
    df = pd.DataFrame(rows, columns=["model_id", "manufacturer", "model_name", "capacity",
                                      "range_km", "category"])
    save(df, "aircraft_models")
    return df


def gen_airports():
    pool = CITY_COUNTRY.copy()
    reps = N_AIRPORTS // len(pool) + 1
    picks = (pool * reps)[:N_AIRPORTS]
    RNG.shuffle(picks)
    codes = set()
    rows = []
    aid = 1
    for city, country in picks:
        while True:
            code = "".join(RNG.choice(list("ABCDEFGHJKLMNPQRSTUVWXYZ"), 3))
            if code not in codes:
                codes.add(code)
                break
        r = RNG.random()
        if r < 0.05:
            name = f"{city} Intl"
        elif r < 0.10:
            name = f"{city.upper()} AIRPORT"
        elif r < 0.15:
            name = f" {city} International Airport "
        else:
            name = f"{city} International Airport"
        active = RNG.random() > 0.04
        tz_offset = int(RNG.integers(-11, 13))
        timezone = f"UTC{'+' if tz_offset >= 0 else ''}{tz_offset}"
        rows.append((f"APT{aid:05d}", code, name, city, country, timezone, active))
        aid += 1
    df = pd.DataFrame(rows, columns=["airport_id", "iata_code", "airport_name", "city",
                                      "country", "timezone", "active_flag"])
    save(df, "airports")
    return df


def gen_aircraft(models_df, airlines_df):
    ids = pad_id("ACFT", N_AIRCRAFT, 5)
    model_ids = choice(models_df["model_id"].values, N_AIRCRAFT)
    airline_ids = choice(airlines_df["airline_id"].values, N_AIRCRAFT)
    years = RNG.integers(1998, 2026, N_AIRCRAFT)
    tails = []
    for _ in range(N_AIRCRAFT):
        tails.append("N" + "".join(RNG.choice(list("0123456789"), 4)) +
                      "".join(RNG.choice(list("ABCDEFGHJKLMNPQRSTUVWXYZ"), 1)))
    status = choice(["Active", "Active", "Active", "In Maintenance", "Retired"], N_AIRCRAFT)
    df = pd.DataFrame({
        "aircraft_id": ids, "tail_number": tails, "model_id": model_ids,
        "airline_id": airline_ids, "manufacture_year": years, "status": status,
    })
    save(df, "aircraft")
    return df


def gen_crew(airlines_df, airports_df):
    ids = pad_id("CRW", N_CREW, 6)
    first = choice(FIRST_NAMES, N_CREW)
    last = choice(LAST_NAMES, N_CREW)
    roles = choice(CREW_ROLES, N_CREW)
    airline_ids = choice(airlines_df["airline_id"].values, N_CREW)
    hire_dates = random_dates(datetime(1995, 1, 1), datetime(2026, 6, 1), N_CREW)
    status = choice(["Active", "Active", "Active", "On Leave", "Inactive"], N_CREW)
    licenses = [f"LIC-{RNG.integers(100000,999999)}" for _ in range(N_CREW)]
    base_airport = choice(airports_df["airport_id"].values, N_CREW)
    df = pd.DataFrame({
        "crew_id": ids, "first_name": first, "last_name": last, "role": roles,
        "airline_id": airline_ids, "hire_date": [d.strftime("%Y-%m-%d") for d in hire_dates],
        "status": status, "license_number": licenses, "base_airport_id": base_airport,
    })
    save(df, "crew_members")
    return df


def gen_gates(airports_df):
    active_airports = airports_df[airports_df["active_flag"]]["airport_id"].values
    airport_ids = choice(active_airports, N_GATES)
    ids = pad_id("GATE", N_GATES, 5)
    terminals = choice(["A", "B", "C", "D", "E", "1", "2", "3"], N_GATES)
    gate_numbers = RNG.integers(1, 60, N_GATES)
    gate_type = choice(["Domestic", "International", "Domestic", "International"], N_GATES)
    df = pd.DataFrame({
        "gate_id": ids, "airport_id": airport_ids, "terminal": terminals,
        "gate_number": gate_numbers, "gate_type": gate_type,
    })
    save(df, "gate_information")
    return df


def gen_routes(airports_df):
    active_airports = airports_df[airports_df["active_flag"]]
    ids = pad_id("RT", N_ROUTES, 5)
    origin = choice(active_airports["airport_id"].values, N_ROUTES)
    dest = choice(active_airports["airport_id"].values, N_ROUTES)
    same = origin == dest
    # fix same-airport routes by shifting destination index
    dest_vals = active_airports["airport_id"].values
    fix_idx = np.where(same)[0]
    for i in fix_idx:
        alt = choice(dest_vals, 1)[0]
        while alt == origin[i]:
            alt = choice(dest_vals, 1)[0]
        dest[i] = alt
    distance = RNG.integers(200, 14000, N_ROUTES)
    duration = (distance / 800 * 60).astype(int) + RNG.integers(10, 40, N_ROUTES)
    df = pd.DataFrame({
        "route_id": ids, "origin_airport_id": origin, "destination_airport_id": dest,
        "distance_km": distance, "typical_duration_min": duration,
    })
    save(df, "flight_routes")
    return df


def gen_schedules(airlines_df, routes_df, models_df):
    ids = pad_id("SCH", N_SCHEDULES, 6)
    airline_ids = choice(airlines_df["airline_id"].values, N_SCHEDULES)
    route_ids = choice(routes_df["route_id"].values, N_SCHEDULES)
    model_ids = choice(models_df["model_id"].values, N_SCHEDULES)
    flight_numbers = [f"{RNG.choice(['XA','SK','CN','GL','NR','HZ'])}{RNG.integers(100,9999)}"
                       for _ in range(N_SCHEDULES)]
    dep_hours = RNG.integers(0, 24, N_SCHEDULES)
    dep_minutes = choice([0, 15, 30, 45], N_SCHEDULES)
    dep_times = [f"{h:02d}:{m:02d}:00" for h, m in zip(dep_hours, dep_minutes)]
    # arrival = departure + typical duration from route, wrap-around not modeled at schedule level
    route_lookup = routes_df.set_index("route_id")["typical_duration_min"].to_dict()
    durations = np.array([route_lookup[r] for r in route_ids])
    dep_total_min = dep_hours * 60 + dep_minutes
    arr_total_min = (dep_total_min + durations) % (24 * 60)
    arr_times = [f"{(m // 60):02d}:{(m % 60):02d}:00" for m in arr_total_min]
    days_pool = ["Daily", "Mon-Fri", "Weekends", "Mon,Wed,Fri", "Tue,Thu,Sat", "Mon-Sat"]
    days_of_week = choice(days_pool, N_SCHEDULES)
    start_dates = random_dates(datetime(2023, 1, 1), datetime(2025, 6, 1), N_SCHEDULES)
    end_dates = [d + timedelta(days=int(RNG.integers(365, 900))) for d in start_dates]
    df = pd.DataFrame({
        "schedule_id": ids, "airline_id": airline_ids, "route_id": route_ids,
        "flight_number": flight_numbers, "scheduled_departure_time": dep_times,
        "scheduled_arrival_time": arr_times, "days_of_week": days_of_week,
        "aircraft_model_id": model_ids,
        "effective_start_date": [d.strftime("%Y-%m-%d") for d in start_dates],
        "effective_end_date": [d.strftime("%Y-%m-%d") for d in end_dates],
    })
    save(df, "flight_schedules")
    return df


def gen_customers():
    ids = pad_id("CUS", N_CUSTOMERS, 7)
    first = choice(FIRST_NAMES, N_CUSTOMERS)
    last = choice(LAST_NAMES, N_CUSTOMERS)
    # middle name: ~55% missing
    has_middle = RNG.random(N_CUSTOMERS) > 0.55
    middle = np.where(has_middle, choice(FIRST_NAMES, N_CUSTOMERS), "")

    dob = random_dates(datetime(1945, 1, 1), datetime(2008, 12, 31), N_CUSTOMERS)
    gender = choice(["Male", "Female", "Other", "Prefer not to say"], N_CUSTOMERS,
                     p=[0.47, 0.47, 0.03, 0.03])

    base_countries = choice([c for _, c in CITY_COUNTRY], N_CUSTOMERS)
    nationality = []
    for c in base_countries:
        if c in COUNTRY_VARIANTS and RNG.random() < 0.15:
            nationality.append(RNG.choice(COUNTRY_VARIANTS[c]))
        else:
            nationality.append(c)

    cities = choice([c for c, _ in CITY_COUNTRY], N_CUSTOMERS)
    street_no = RNG.integers(1, 9999, N_CUSTOMERS)
    street_names = ["Main St", "Oak Ave", "Maple Dr", "Elm St", "Park Rd", "Sunset Blvd",
                    "Highland Ave", "Church St", "Lake Dr", "River Rd", "1st Ave", "2nd St"]
    streets = choice(street_names, N_CUSTOMERS)
    address = [f"{n} {s}" for n, s in zip(street_no, streets)]

    signup_dates = random_dates(datetime(2015, 1, 1), datetime(2026, 7, 30), N_CUSTOMERS)
    active = RNG.random(N_CUSTOMERS) > 0.08

    # emails: build then inject ~2% duplicates
    email_r = RNG.random(N_CUSTOMERS)
    emails = []
    for f, l, r, i in zip(first, last, email_r, range(N_CUSTOMERS)):
        domain = RNG.choice(["gmail.com", "yahoo.com", "outlook.com", "mail.com", "aol.com"])
        sep = RNG.choice([".", "_", ""])
        tag = "" if r > 0.5 else str(RNG.integers(1, 999))
        emails.append(f"{f.lower()}{sep}{l.lower()}{tag}@{domain}")
    dup_idx = RNG.choice(N_CUSTOMERS, size=int(N_CUSTOMERS * 0.02), replace=False)
    for i in dup_idx:
        src = RNG.integers(0, N_CUSTOMERS)
        emails[i] = emails[src]

    # phone numbers, mixed formats, ~1.5% duplicates
    phones = []
    for i in range(N_CUSTOMERS):
        n = "".join([str(RNG.integers(0, 10)) for _ in range(10)])
        fmt = RNG.integers(0, 4)
        if fmt == 0:
            phones.append(f"({n[0:3]}) {n[3:6]}-{n[6:10]}")
        elif fmt == 1:
            phones.append(f"{n[0:3]}-{n[3:6]}-{n[6:10]}")
        elif fmt == 2:
            phones.append(f"+1{n}")
        else:
            phones.append(n)
    dup_idx2 = RNG.choice(N_CUSTOMERS, size=int(N_CUSTOMERS * 0.015), replace=False)
    for i in dup_idx2:
        src = RNG.integers(0, N_CUSTOMERS)
        phones[i] = phones[src]

    case_r = RNG.random(N_CUSTOMERS)
    first_dirty = dirty_case(first, case_r)
    last_dirty = dirty_case(last, RNG.random(N_CUSTOMERS))

    df = pd.DataFrame({
        "customer_id": ids, "first_name": first_dirty, "middle_name": middle,
        "last_name": last_dirty, "email": emails, "phone": phones,
        "date_of_birth": [d.strftime("%Y-%m-%d") for d in dob], "gender": gender,
        "nationality": nationality, "address": address, "city": cities,
        "country": base_countries,
        "signup_date": [d.strftime("%Y-%m-%d") for d in signup_dates],
        "active_flag": active,
    })
    save(df, "customers")
    return df


def gen_loyalty(customers_df):
    n = int(N_CUSTOMERS * N_LOYALTY_RATE)
    cust_sample = RNG.choice(customers_df["customer_id"].values, size=n, replace=False)
    ids = pad_id("LOY", n, 7)
    tiers = choice(["Silver", "Gold", "Platinum", "Blue"], n, p=[0.40, 0.30, 0.10, 0.20])
    points = RNG.integers(0, 250000, n)
    enroll = random_dates(datetime(2015, 1, 1), datetime(2026, 7, 1), n)
    status = choice(["Active", "Active", "Active", "Suspended", "Expired"], n)
    df = pd.DataFrame({
        "loyalty_id": ids, "customer_id": cust_sample, "tier": tiers,
        "points_balance": points, "enrollment_date": [d.strftime("%Y-%m-%d") for d in enroll],
        "status": status,
    })
    save(df, "loyalty_members")
    return df


# ----------------------------------------------------------------------------
# FLIGHT + OPERATIONS TABLES
# ----------------------------------------------------------------------------

def gen_flights(schedules_df, aircraft_df, gates_df, airports_df):
    n = N_FLIGHTS
    ids = pad_id("FLT", n, 7)
    sched_idx = RNG.integers(0, len(schedules_df), n)
    sched = schedules_df.iloc[sched_idx].reset_index(drop=True)

    flight_dates = random_dates(FLIGHT_DATE_START, FLIGHT_DATE_END, n)
    is_future = np.array([d > TODAY for d in flight_dates])

    # aircraft & airline: pick aircraft belonging to the schedule's airline where possible
    airline_ids = sched["airline_id"].values
    aircraft_by_airline = aircraft_df.groupby("airline_id")["aircraft_id"].apply(list).to_dict()
    aircraft_ids = []
    for al in airline_ids:
        pool = aircraft_by_airline.get(al)
        if not pool:
            pool = aircraft_df["aircraft_id"].values
        aircraft_ids.append(RNG.choice(pool))
    aircraft_ids = np.array(aircraft_ids)

    route_lookup = schedules_df.set_index("schedule_id")
    origin_airport = sched["route_id"].map(
        lambda r: None)  # placeholder, filled below via routes join
    # We need routes df here; join via route_id -> handled in main() by passing merged sched
    df = pd.DataFrame({
        "flight_id": ids,
        "schedule_id": sched["schedule_id"].values,
        "flight_date": [d.strftime("%Y-%m-%d") for d in flight_dates],
        "aircraft_id": aircraft_ids,
        "airline_id": airline_ids,
        "route_id": sched["route_id"].values,
        "scheduled_departure_time": sched["scheduled_departure_time"].values,
        "scheduled_arrival_time": sched["scheduled_arrival_time"].values,
        "_is_future": is_future,
    })
    return df


def finalize_flights(flights_df, routes_df, gates_df, airports_df):
    n = len(flights_df)
    routes_lookup = routes_df.set_index("route_id")
    origin = flights_df["route_id"].map(routes_lookup["origin_airport_id"])
    dest = flights_df["route_id"].map(routes_lookup["destination_airport_id"])

    # status assignment
    status = np.empty(n, dtype=object)
    r = RNG.random(n)
    future_mask = flights_df["_is_future"].values
    status[future_mask] = "Scheduled"
    past_mask = ~future_mask
    # distribution among past flights: 82% On Time/Arrived, 13% Delayed, 5% Cancelled
    past_r = r[past_mask]
    past_status = np.where(past_r < 0.82, "Arrived",
                    np.where(past_r < 0.95, "Delayed", "Cancelled"))
    status[past_mask] = past_status

    # build actual departure/arrival datetimes
    flight_dates = pd.to_datetime(flights_df["flight_date"])
    sched_dep = flights_df["scheduled_departure_time"]
    sched_arr = flights_df["scheduled_arrival_time"]

    sched_dep_dt = pd.to_datetime(flights_df["flight_date"] + " " + sched_dep)
    dep_h = sched_dep.str.slice(0, 2).astype(int)
    arr_h = sched_arr.str.slice(0, 2).astype(int)
    overnight = arr_h < dep_h
    sched_arr_date = flight_dates + pd.to_timedelta(np.where(overnight, 1, 0), unit="D")
    sched_arr_dt = pd.to_datetime(sched_arr_date.dt.strftime("%Y-%m-%d") + " " + sched_arr)

    delay_minutes_all = np.zeros(n, dtype=int)
    delayed_mask = status == "Delayed"
    delay_vals = RNG.integers(15, 240, size=delayed_mask.sum())
    delay_minutes_all[delayed_mask] = delay_vals

    actual_dep_dt = sched_dep_dt + pd.to_timedelta(delay_minutes_all, unit="m")
    actual_arr_dt = sched_arr_dt + pd.to_timedelta(delay_minutes_all, unit="m")

    actual_dep_str = actual_dep_dt.dt.strftime("%Y-%m-%d %H:%M:%S")
    actual_arr_str = actual_arr_dt.dt.strftime("%Y-%m-%d %H:%M:%S")

    cancelled_mask = status == "Cancelled"
    actual_dep_str = actual_dep_str.mask(cancelled_mask | future_mask, None)
    actual_arr_str = actual_arr_str.mask(cancelled_mask | future_mask, None)

    # gate assignment: only for flights departing from active airports; ~4% missing gate
    gates_by_airport = gates_df.groupby("airport_id")["gate_id"].apply(list).to_dict()
    gate_ids = []
    missing_gate_r = RNG.random(n)
    for i, apt in enumerate(origin.values):
        if missing_gate_r[i] < 0.04 or status[i] == "Cancelled":
            gate_ids.append(None)
            continue
        pool = gates_by_airport.get(apt)
        gate_ids.append(RNG.choice(pool) if pool else None)

    out = flights_df.copy()
    out["origin_airport_id"] = origin.values
    out["dest_airport_id"] = dest.values
    out["status"] = status
    out["actual_departure_time"] = actual_dep_str.values
    out["actual_arrival_time"] = actual_arr_str.values
    out["gate_id"] = gate_ids
    out["_delay_minutes"] = delay_minutes_all
    out.drop(columns=["_is_future"], inplace=True)
    return out


def gen_flight_status_logs(flights_df):
    records = []
    log_seq = 1
    stages_normal = ["Scheduled", "Boarding", "Departed", "Arrived"]
    stages_cancel = ["Scheduled", "Cancelled"]
    stages_future = ["Scheduled"]
    for fid, fdate, dep, status in zip(flights_df["flight_id"], flights_df["flight_date"],
                                        flights_df["scheduled_departure_time"], flights_df["status"]):
        if status == "Cancelled":
            stages = stages_cancel
        elif status == "Scheduled":
            stages = stages_future
        else:
            stages = stages_normal
        base_dt = datetime.strptime(f"{fdate} {dep}", "%Y-%m-%d %H:%M:%S")
        for offset_i, stg in enumerate(stages):
            log_time = base_dt - timedelta(hours=2) + timedelta(minutes=offset_i * 45)
            remark = None
            if stg == "Delayed" or (status == "Delayed" and stg == "Departed"):
                remark = "Delay communicated to passengers"
            records.append((f"LOG{log_seq:08d}", fid, stg, log_time.strftime("%Y-%m-%d %H:%M:%S"), remark))
            log_seq += 1
    df = pd.DataFrame(records, columns=["log_id", "flight_id", "status", "status_time", "remarks"])
    save(df, "flight_status_logs")
    return df


def gen_crew_assignments(flights_df, crew_df):
    active_crew = crew_df[crew_df["status"] == "Active"]
    crew_by_role = {r: active_crew[active_crew["role"] == r]["crew_id"].values for r in set(CREW_ROLES)}
    records = []
    seq = 1
    roles_needed = ["Captain", "First Officer", "Flight Attendant", "Flight Attendant"]
    for fid in flights_df["flight_id"].values:
        for role in roles_needed:
            pool = crew_by_role.get(role)
            if pool is None or len(pool) == 0:
                pool = crew_df["crew_id"].values
            crew_id = RNG.choice(pool)
            records.append((f"CA{seq:08d}", fid, crew_id, role))
            seq += 1
    df = pd.DataFrame(records, columns=["assignment_id", "flight_id", "crew_id", "role_on_flight"])
    save(df, "crew_assignments")
    return df


def gen_bookings(customers_df, flights_df):
    n = int(N_FLIGHTS * 1.875)  # ~150,000
    ids = pad_id("BK", n, 8)
    cust_ids = choice(customers_df["customer_id"].values, n)
    flight_ids = choice(flights_df["flight_id"].values, n)
    flight_lookup = flights_df.set_index("flight_id")[["flight_date", "status"]]
    fl = flight_lookup.loc[flight_ids]
    booking_date = []
    for fdate in fl["flight_date"].values:
        f_dt = datetime.strptime(fdate, "%Y-%m-%d")
        lead_days = int(RNG.integers(1, 180))
        bd = f_dt - timedelta(days=lead_days)
        if bd > TODAY:
            bd = TODAY - timedelta(days=int(RNG.integers(1, 30)))
        booking_date.append(bd)
    channel = choice(BOOKING_CHANNELS, n)
    r = RNG.random(n)
    flight_status_vals = fl["status"].values
    booking_status = []
    for i in range(n):
        if flight_status_vals[i] == "Cancelled":
            booking_status.append("Cancelled" if r[i] < 0.9 else "Refunded")
        elif r[i] < 0.04:
            booking_status.append("Cancelled")
        else:
            booking_status.append("Confirmed")
    total_amount = np.round(RNG.uniform(80, 4500, n), 2)
    currency = choice(["USD", "EUR", "GBP", "AUD", "CAD"], n, p=[0.55, 0.2, 0.12, 0.07, 0.06])
    df = pd.DataFrame({
        "booking_id": ids, "customer_id": cust_ids,
        "booking_date": [d.strftime("%Y-%m-%d") for d in booking_date],
        "flight_id": flight_ids, "channel": channel, "booking_status": booking_status,
        "total_amount": total_amount, "currency": currency,
    })
    save(df, "bookings")
    return df


def gen_passengers(bookings_df, loyalty_df):
    # 1 to 3 passengers per booking
    n_bookings = len(bookings_df)
    counts = choice([1, 2, 3, 4], n_bookings, p=[0.45, 0.32, 0.16, 0.07])
    booking_ids_rep = np.repeat(bookings_df["booking_id"].values, counts)
    n = len(booking_ids_rep)
    ids = pad_id("PAX", n, 8)
    first = choice(FIRST_NAMES, n)
    last = choice(LAST_NAMES, n)
    has_middle = RNG.random(n) > 0.6
    middle = np.where(has_middle, choice(FIRST_NAMES, n), "")
    dob = random_dates(datetime(1935, 1, 1), datetime(2024, 12, 1), n)
    gender = choice(["Male", "Female", "Other"], n, p=[0.48, 0.48, 0.04])
    has_passport = RNG.random(n) > 0.1
    passport = [f"P{RNG.integers(10000000,99999999)}" if hp else None for hp in has_passport]
    has_loyalty = RNG.random(n) < 0.35
    loyalty_pool = loyalty_df["loyalty_id"].values
    loyalty_id = [RNG.choice(loyalty_pool) if hl else None for hl in has_loyalty]
    df = pd.DataFrame({
        "passenger_id": ids, "booking_id": booking_ids_rep, "first_name": first,
        "middle_name": middle, "last_name": last,
        "date_of_birth": [d.strftime("%Y-%m-%d") for d in dob], "gender": gender,
        "passport_number": passport, "loyalty_id": loyalty_id,
    })
    save(df, "passengers")
    return df


def gen_tickets(passengers_df, bookings_df):
    n = len(passengers_df)
    ids = pad_id("TKT", n, 8)
    booking_lookup = bookings_df.set_index("booking_id")[["flight_id", "booking_status"]]
    bl = booking_lookup.loc[passengers_df["booking_id"].values]
    fare_class = choice(FARE_CLASSES, n, p=FARE_CLASS_WEIGHTS)
    price_base = {"Economy": (80, 600), "Premium Economy": (300, 1200),
                  "Business": (900, 3500), "First": (2500, 9000)}
    prices = np.array([RNG.uniform(*price_base[fc]) for fc in fare_class]).round(2)
    ticket_status = []
    for bstatus in bl["booking_status"].values:
        if bstatus == "Cancelled":
            ticket_status.append("Cancelled")
        elif bstatus == "Refunded":
            ticket_status.append("Refunded")
        else:
            ticket_status.append("Issued")
    df = pd.DataFrame({
        "ticket_id": ids, "passenger_id": passengers_df["passenger_id"].values,
        "booking_id": passengers_df["booking_id"].values, "flight_id": bl["flight_id"].values,
        "fare_class": fare_class, "ticket_price": prices, "ticket_status": ticket_status,
    })
    save(df, "tickets")
    return df


def gen_boarding_passes_and_seats(tickets_df, flights_df, aircraft_df, models_df):
    valid = tickets_df[tickets_df["ticket_status"] == "Issued"].copy()
    # ~92% of valid ticket holders actually boarded
    boarded_mask = RNG.random(len(valid)) < 0.92
    boarded = valid[boarded_mask].reset_index(drop=True)
    n = len(boarded)

    flight_lookup = flights_df.set_index("flight_id")[["scheduled_departure_time", "flight_date", "aircraft_id"]]
    fl = flight_lookup.loc[boarded["flight_id"].values]
    boarding_time = []
    for fdate, dep in zip(fl["flight_date"].values, fl["scheduled_departure_time"].values):
        dep_dt = datetime.strptime(f"{fdate} {dep}", "%Y-%m-%d %H:%M:%S")
        bt = dep_dt - timedelta(minutes=int(RNG.integers(20, 60)))
        boarding_time.append(bt.strftime("%Y-%m-%d %H:%M:%S"))

    rows_letters = list("ABCDEFGHJK")
    seat_numbers = [f"{RNG.integers(1,45)}{RNG.choice(rows_letters)}" for _ in range(n)]
    boarding_group = choice(["A", "B", "C", "D"], n)
    bp_ids = pad_id("BP", n, 8)

    bp_df = pd.DataFrame({
        "boarding_pass_id": bp_ids, "ticket_id": boarded["ticket_id"].values,
        "passenger_id": boarded["passenger_id"].values, "flight_id": boarded["flight_id"].values,
        "seat_number": seat_numbers, "boarding_time": boarding_time,
        "boarding_group": boarding_group,
    })
    save(bp_df, "boarding_passes")

    # seat assignments table: one row per boarded passenger (seat map style)
    sa_ids = pad_id("SA", n, 8)
    seat_class = choice(FARE_CLASSES, n, p=FARE_CLASS_WEIGHTS)
    sa_df = pd.DataFrame({
        "seat_assignment_id": sa_ids, "flight_id": boarded["flight_id"].values,
        "aircraft_id": fl["aircraft_id"].values, "seat_number": seat_numbers,
        "passenger_id": boarded["passenger_id"].values, "class": seat_class,
    })
    save(sa_df, "seat_assignments")
    return bp_df, sa_df


def gen_baggage(tickets_df):
    valid = tickets_df[tickets_df["ticket_status"] == "Issued"].copy()
    # ~1.3 bags per valid ticket on average -> use repeat with variable counts
    n_tix = len(valid)
    counts = choice([0, 1, 2, 3], n_tix, p=[0.12, 0.48, 0.30, 0.10])
    ticket_ids_rep = np.repeat(valid["ticket_id"].values, counts)
    passenger_ids_rep = np.repeat(valid["passenger_id"].values, counts)
    n = len(ticket_ids_rep)
    ids = pad_id("BAG", n, 8)
    weight = RNG.normal(18, 5, n).round(1)
    weight = np.clip(weight, 3, 32)
    missing_w = RNG.random(n) < 0.03
    weight_out = np.where(missing_w, np.nan, weight)
    baggage_type = choice(["Checked", "Checked", "Carry-on", "Oversized"], n)
    status = choice(["Loaded", "Loaded", "Loaded", "Delayed", "Lost", "Damaged"], n,
                     p=[0.7, 0.1, 0.1, 0.06, 0.02, 0.02])
    df = pd.DataFrame({
        "baggage_id": ids, "ticket_id": ticket_ids_rep, "passenger_id": passenger_ids_rep,
        "weight_kg": weight_out, "baggage_type": baggage_type, "status": status,
    })
    save(df, "baggage")
    return df


def gen_payments(bookings_df):
    n = len(bookings_df)
    ids = pad_id("PAY", n, 8)
    payment_date = []
    for bdate in bookings_df["booking_date"].values:
        bd = datetime.strptime(bdate, "%Y-%m-%d")
        pd_ = bd + timedelta(hours=int(RNG.integers(0, 48)))
        payment_date.append(pd_.strftime("%Y-%m-%d %H:%M:%S"))
    method = choice(PAYMENT_METHODS, n)
    status = []
    for bstatus in bookings_df["booking_status"].values:
        if bstatus == "Refunded":
            status.append("Refunded")
        elif bstatus == "Cancelled":
            status.append(RNG.choice(["Failed", "Voided", "Completed"], p=[0.2, 0.3, 0.5]))
        else:
            status.append("Completed")
    df = pd.DataFrame({
        "payment_id": ids, "booking_id": bookings_df["booking_id"].values,
        "payment_date": payment_date, "amount": bookings_df["total_amount"].values,
        "payment_method": method, "payment_status": status,
    })
    save(df, "payments")
    return df


def gen_refunds(payments_df, bookings_df):
    refundable = payments_df[payments_df["payment_status"] == "Refunded"].copy()
    n = len(refundable)
    ids = pad_id("REF", n, 6)
    booking_lookup = bookings_df.set_index("booking_id")["booking_date"]
    refund_date = []
    for bid in refundable["booking_id"].values:
        bd = datetime.strptime(booking_lookup.loc[bid], "%Y-%m-%d")
        rd = bd + timedelta(days=int(RNG.integers(2, 45)))
        if rd > TODAY:
            rd = TODAY
        refund_date.append(rd.strftime("%Y-%m-%d"))
    refund_amount = np.round(refundable["amount"].values * RNG.uniform(0.5, 1.0, n), 2)
    reason = choice(["Flight Cancelled", "Passenger Request", "Duplicate Booking",
                      "Medical Emergency", "Schedule Change"], n)
    df = pd.DataFrame({
        "refund_id": ids, "payment_id": refundable["payment_id"].values,
        "booking_id": refundable["booking_id"].values, "refund_date": refund_date,
        "refund_amount": refund_amount, "reason": reason,
    })
    save(df, "refunds")
    return df


def gen_loyalty_transactions(loyalty_df, flights_df, bookings_df, passengers_df):
    n = int(len(loyalty_df) * 2.6)
    ids = pad_id("LT", n, 8)
    loyalty_ids = choice(loyalty_df["loyalty_id"].values, n)
    # link some transactions to a flight this member's passenger record could plausibly relate to
    pax_with_loyalty = passengers_df.dropna(subset=["loyalty_id"])
    flight_map = bookings_df.set_index("booking_id")["flight_id"]
    has_flight = RNG.random(n) < 0.7
    flight_ids = []
    for hf in has_flight:
        if hf and len(pax_with_loyalty) > 0:
            row = pax_with_loyalty.sample(1, random_state=int(RNG.integers(0, 1_000_000))).iloc[0]
            try:
                flight_ids.append(flight_map.loc[row["booking_id"]])
            except KeyError:
                flight_ids.append(None)
        else:
            flight_ids.append(None)
    ttype = choice(["Earn", "Redeem", "Bonus", "Adjustment"], n, p=[0.55, 0.25, 0.1, 0.1])
    points_earned = np.where(np.isin(ttype, ["Earn", "Bonus"]), RNG.integers(50, 5000, n), 0)
    points_redeemed = np.where(ttype == "Redeem", RNG.integers(500, 20000, n), 0)
    tx_date = random_dates(datetime(2020, 1, 1), TODAY, n)
    df = pd.DataFrame({
        "transaction_id": ids, "loyalty_id": loyalty_ids, "flight_id": flight_ids,
        "points_earned": points_earned, "points_redeemed": points_redeemed,
        "transaction_date": [d.strftime("%Y-%m-%d") for d in tx_date],
        "transaction_type": ttype,
    })
    save(df, "loyalty_transactions")
    return df


def gen_weather(airports_df):
    n = N_WEATHER
    ids = pad_id("WX", n, 7)
    airport_ids = choice(airports_df["airport_id"].values, n)
    obs_date = random_dates(FLIGHT_DATE_START, TODAY, n)
    condition = choice(WEATHER_CONDITIONS_LIST, n)
    temp = RNG.normal(18, 12, n).round(1)
    wind = np.abs(RNG.normal(15, 10, n)).round(1)
    visibility = np.clip(RNG.normal(9, 3, n), 0.1, 15).round(1)
    df = pd.DataFrame({
        "weather_id": ids, "airport_id": airport_ids,
        "observation_date": [d.strftime("%Y-%m-%d") for d in obs_date],
        "condition": condition, "temperature_c": temp, "wind_speed_kmh": wind,
        "visibility_km": visibility,
    })
    save(df, "weather_conditions")
    return df


def gen_maintenance_logs(aircraft_df):
    n = N_MAINTENANCE_LOGS
    ids = pad_id("ML", n, 6)
    aircraft_ids = choice(aircraft_df["aircraft_id"].values, n)
    log_date = random_dates(datetime(2023, 1, 1), TODAY, n)
    descriptions = choice(["Routine Inspection", "Engine Check", "Avionics Update",
                            "Tire Replacement", "Hydraulic System Check", "Cabin Repair",
                            "Landing Gear Inspection", "Software Update"], n)
    technician = [f"{RNG.choice(FIRST_NAMES)} {RNG.choice(LAST_NAMES)}" for _ in range(n)]
    status = choice(["Completed", "Completed", "Completed", "In Progress", "Scheduled"], n)
    df = pd.DataFrame({
        "log_id": ids, "aircraft_id": aircraft_ids,
        "log_date": [d.strftime("%Y-%m-%d") for d in log_date],
        "description": descriptions, "technician": technician, "status": status,
    })
    save(df, "maintenance_logs")
    return df


def gen_aircraft_maintenance_history(aircraft_df):
    n = N_AIRCRAFT_MAINT_HISTORY
    ids = pad_id("AMH", n, 6)
    aircraft_ids = choice(aircraft_df["aircraft_id"].values, n)
    m_date = random_dates(datetime(2018, 1, 1), TODAY, n)
    m_type = choice(["A-Check", "B-Check", "C-Check", "D-Check", "Unscheduled Repair"], n,
                     p=[0.4, 0.25, 0.2, 0.05, 0.1])
    cost = np.round(RNG.uniform(2000, 500000, n), 2)
    next_due = [d + timedelta(days=int(RNG.integers(90, 730))) for d in m_date]
    df = pd.DataFrame({
        "history_id": ids, "aircraft_id": aircraft_ids,
        "maintenance_date": [d.strftime("%Y-%m-%d") for d in m_date],
        "maintenance_type": m_type, "cost": cost,
        "next_due_date": [d.strftime("%Y-%m-%d") for d in next_due],
    })
    save(df, "aircraft_maintenance_history")
    return df


def gen_flight_delays(flights_df):
    delayed = flights_df[flights_df["status"] == "Delayed"].copy()
    n = len(delayed)
    ids = pad_id("DLY", n, 6)
    reason = choice(DELAY_REASONS, n)
    df = pd.DataFrame({
        "delay_id": ids, "flight_id": delayed["flight_id"].values,
        "delay_minutes": delayed["_delay_minutes"].values, "delay_reason": reason,
    })
    save(df, "flight_delays")
    return df


def gen_flight_cancellations(flights_df):
    cancelled = flights_df[flights_df["status"] == "Cancelled"].copy()
    n = len(cancelled)
    ids = pad_id("CXL", n, 6)
    reason = choice(CANCELLATION_REASONS, n)
    cancelled_at = []
    for fdate, dep in zip(cancelled["flight_date"].values, cancelled["scheduled_departure_time"].values):
        dep_dt = datetime.strptime(f"{fdate} {dep}", "%Y-%m-%d %H:%M:%S")
        ca = dep_dt - timedelta(hours=int(RNG.integers(1, 72)))
        cancelled_at.append(ca.strftime("%Y-%m-%d %H:%M:%S"))
    df = pd.DataFrame({
        "cancellation_id": ids, "flight_id": cancelled["flight_id"].values,
        "cancellation_reason": reason, "cancelled_at": cancelled_at,
    })
    save(df, "flight_cancellations")
    return df


def gen_support_tickets(customers_df, bookings_df):
    n = N_SUPPORT_TICKETS
    ids = pad_id("SUP", n, 6)
    cust_ids = choice(customers_df["customer_id"].values, n)
    has_booking = RNG.random(n) < 0.65
    booking_ids = [RNG.choice(bookings_df["booking_id"].values) if hb else None for hb in has_booking]
    issue = choice(SUPPORT_ISSUE_TYPES, n)
    opened = random_dates(datetime(2024, 1, 1), TODAY, n)
    status = choice(["Open", "In Progress", "Resolved", "Closed"], n, p=[0.1, 0.15, 0.35, 0.4])
    priority = choice(["Low", "Medium", "High", "Urgent"], n, p=[0.35, 0.4, 0.2, 0.05])
    df = pd.DataFrame({
        "ticket_id": ids, "customer_id": cust_ids, "booking_id": booking_ids,
        "issue_type": issue, "opened_date": [d.strftime("%Y-%m-%d") for d in opened],
        "status": status, "priority": priority,
    })
    save(df, "customer_support_tickets")
    return df


def gen_feedback(customers_df, flights_df):
    n = N_FEEDBACK
    ids = pad_id("FB", n, 6)
    cust_ids = choice(customers_df["customer_id"].values, n)
    has_flight = RNG.random(n) < 0.8
    flight_ids = [RNG.choice(flights_df["flight_id"].values) if hf else None for hf in has_flight]
    rating = RNG.integers(1, 6, n)
    comments_pool = ["Great service!", "Flight was delayed but staff were helpful.",
                      "Comfortable seats.", "Food could be better.", "", "",
                      "Excellent crew, will fly again.", "Lost my baggage, very disappointed.",
                      "Smooth check-in process.", None]
    comments = choice(comments_pool, n)
    submitted = random_dates(datetime(2024, 1, 1), TODAY, n)
    df = pd.DataFrame({
        "feedback_id": ids, "customer_id": cust_ids, "flight_id": flight_ids,
        "rating": rating, "comments": comments,
        "submitted_date": [d.strftime("%Y-%m-%d") for d in submitted],
    })
    save(df, "feedback")
    return df


def gen_ancillary_services(bookings_df, passengers_df):
    pax_by_booking = passengers_df.groupby("booking_id")["passenger_id"].apply(list).to_dict()
    booking_sample = bookings_df.sample(frac=0.55, random_state=SEED)
    records = []
    seq = 1
    price_map = {"Extra Baggage": (30, 150), "Seat Upgrade": (25, 300), "In-flight Meal": (10, 45),
                 "Wi-Fi": (5, 25), "Priority Boarding": (15, 40), "Lounge Access": (30, 90),
                 "Travel Insurance": (10, 60), "Pet Fee": (50, 200)}
    for bid in booking_sample["booking_id"].values:
        pax_list = pax_by_booking.get(bid, [])
        if not pax_list:
            continue
        n_services = int(RNG.integers(1, 3))
        for _ in range(n_services):
            svc = RNG.choice(ANCILLARY_TYPES)
            lo, hi = price_map[svc]
            amount = round(float(RNG.uniform(lo, hi)), 2)
            status = RNG.choice(["Confirmed", "Confirmed", "Confirmed", "Cancelled"])
            pax = RNG.choice(pax_list)
            records.append((f"ANC{seq:07d}", bid, pax, svc, amount, status))
            seq += 1
    df = pd.DataFrame(records, columns=["service_id", "booking_id", "passenger_id",
                                         "service_type", "amount", "status"])
    save(df, "ancillary_services")
    return df


def gen_checkin_events(tickets_df, boarding_passes_df):
    boarded_tickets = boarding_passes_df[["ticket_id", "passenger_id", "flight_id", "boarding_time"]].copy()
    n = len(boarded_tickets)
    ids = pad_id("CHK", n, 8)
    checkin_time = []
    for bt in boarded_tickets["boarding_time"].values:
        bt_dt = datetime.strptime(bt, "%Y-%m-%d %H:%M:%S")
        ct = bt_dt - timedelta(minutes=int(RNG.integers(30, 180)))
        checkin_time.append(ct.strftime("%Y-%m-%d %H:%M:%S"))
    method = choice(["Online", "Mobile App", "Airport Kiosk", "Counter"], n, p=[0.45, 0.25, 0.2, 0.1])
    df = pd.DataFrame({
        "checkin_id": ids, "ticket_id": boarded_tickets["ticket_id"].values,
        "passenger_id": boarded_tickets["passenger_id"].values,
        "flight_id": boarded_tickets["flight_id"].values,
        "checkin_time": checkin_time, "checkin_method": method,
    })
    save(df, "check_in_events")
    return df


def gen_fuel_usage(flights_df, routes_df):
    n = len(flights_df)
    ids = pad_id("FUEL", n, 7)
    route_lookup = routes_df.set_index("route_id")["distance_km"]
    distances = flights_df["route_id"].map(route_lookup).values
    fuel_liters = np.round(distances.astype(float) * RNG.uniform(3.0, 4.2, n), 1)
    fuel_cost = np.round(fuel_liters * RNG.uniform(0.75, 1.1, n), 2)
    df = pd.DataFrame({
        "fuel_id": ids, "flight_id": flights_df["flight_id"].values,
        "aircraft_id": flights_df["aircraft_id"].values,
        "fuel_liters": fuel_liters, "fuel_cost": fuel_cost,
    })
    save(df, "fuel_usage")
    return df


# ----------------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------------

def main():
    global OUT_DIR
    parser = argparse.ArgumentParser()
    parser.add_argument("--outdir", default="../data")
    args = parser.parse_args()
    OUT_DIR = os.path.abspath(args.outdir)
    os.makedirs(OUT_DIR, exist_ok=True)

    print("== Reference / Dimension tables ==")
    airlines_df = gen_airlines()
    models_df = gen_aircraft_models()
    airports_df = gen_airports()
    aircraft_df = gen_aircraft(models_df, airlines_df)
    crew_df = gen_crew(airlines_df, airports_df)
    gates_df = gen_gates(airports_df)
    routes_df = gen_routes(airports_df)
    schedules_df = gen_schedules(airlines_df, routes_df, models_df)
    customers_df = gen_customers()
    loyalty_df = gen_loyalty(customers_df)

    print("== Flights & operations ==")
    flights_raw = gen_flights(schedules_df, aircraft_df, gates_df, airports_df)
    flights_df = finalize_flights(flights_raw, routes_df, gates_df, airports_df)

    flights_out = flights_df.drop(columns=["_delay_minutes"])
    save(flights_out, "flights")

    gen_flight_status_logs(flights_df)
    gen_crew_assignments(flights_df, crew_df)
    gen_flight_delays(flights_df)
    gen_flight_cancellations(flights_df)
    gen_fuel_usage(flights_df, routes_df)

    print("== Bookings, passengers, tickets ==")
    bookings_df = gen_bookings(customers_df, flights_df)
    passengers_df = gen_passengers(bookings_df, loyalty_df)
    tickets_df = gen_tickets(passengers_df, bookings_df)
    boarding_passes_df, seat_assign_df = gen_boarding_passes_and_seats(
        tickets_df, flights_df, aircraft_df, models_df)
    gen_baggage(tickets_df)
    gen_checkin_events(tickets_df, boarding_passes_df)

    print("== Payments & loyalty activity ==")
    payments_df = gen_payments(bookings_df)
    gen_refunds(payments_df, bookings_df)
    gen_loyalty_transactions(loyalty_df, flights_df, bookings_df, passengers_df)

    print("== Weather & maintenance ==")
    gen_weather(airports_df)
    gen_maintenance_logs(aircraft_df)
    gen_aircraft_maintenance_history(aircraft_df)

    print("== Customer experience ==")
    gen_support_tickets(customers_df, bookings_df)
    gen_feedback(customers_df, flights_df)
    gen_ancillary_services(bookings_df, passengers_df)

    total_size = sum(os.path.getsize(os.path.join(OUT_DIR, f))
                      for f in os.listdir(OUT_DIR) if f.endswith(".csv"))
    print(f"\nTOTAL DATASET SIZE: {total_size / (1024*1024):.2f} MB across "
          f"{len([f for f in os.listdir(OUT_DIR) if f.endswith('.csv')])} files")


if __name__ == "__main__":
    main()
