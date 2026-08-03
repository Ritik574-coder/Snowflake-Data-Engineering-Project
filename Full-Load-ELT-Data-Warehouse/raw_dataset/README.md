# Airline Reservation System — Synthetic Dataset

A production-inspired, synthetic dataset simulating the operational systems of an
airline reservation company. Built for practicing **Snowflake / SQL / Python data
engineering**: ingestion, medallion architecture (Bronze → Silver → Gold), Kimball
dimensional modeling, data cleaning, validation, transformation, and analytics.

This dataset is **not** intended for machine learning.

## Contents

```
airline_reservation_dataset/
├── README.md              <- you are here
├── Metadata.md             <- full data dictionary, PK/FK map, business rules
├── generator/
│   └── generate_data.py    <- the Python script that generates everything below
└── data/
    └── *.csv                <- 32 CSV files, ~196 MB total
```

## Regenerating the data

The dataset was generated with a fixed random seed (42), so re-running the
generator reproduces byte-identical output.

```bash
cd generator
pip install pandas numpy
python generate_data.py --outdir ../data
```

## What's in the dataset

32 tables covering the full airline operational and commercial lifecycle:

- **Reference / dimension data:** Airlines, Airports, Aircraft, Aircraft Models,
  Crew Members, Gate Information, Flight Routes, Flight Schedules
- **Customer data:** Customers, Loyalty Members, Loyalty Transactions
- **Flight operations:** Flights, Flight Status Logs, Crew Assignments,
  Flight Delays, Flight Cancellations, Weather Conditions, Maintenance Logs,
  Aircraft Maintenance History, Fuel Usage
- **Reservations:** Bookings, Passengers, Tickets, Boarding Passes,
  Seat Assignments, Baggage, Check-in Events, Ancillary Services
- **Payments:** Payments, Refunds
- **Customer experience:** Customer Support Tickets, Feedback

See **Metadata.md** for the full data dictionary (columns, types, keys,
nullability, and business rules).

## Data quality — by design

This is meant to feel like a real export from an operational system, not a
polished analytics table. It intentionally contains:

- Missing values (middle names, gates, baggage weight, remarks, passports)
- Leading/trailing whitespace and inconsistent casing in text fields
- Inconsistent country naming (e.g. "United States" / "USA" / "U.S.A.")
- Multiple phone number formats
- A small percentage of duplicate customer emails and phone numbers
- Inactive customers, inactive/retired assets, cancelled bookings, delayed and
  cancelled flights, and refunded payments

At the same time, the data is **never impossible**: no negative prices, ages,
weights, or durations; no arrivals before departures; no orphaned foreign
keys; all dates are valid ISO `YYYY-MM-DD` / `YYYY-MM-DD HH:MM:SS`.

## Suggested Medallion flow

- **Bronze:** raw CSV ingestion into Snowflake staging tables, as-is (dirty).
- **Silver:** cleaning, standardization, deduplication, type enforcement,
  referential validation.
- **Gold:** Kimball star schema — conformed dimensions (Customer, Passenger,
  Airport, Aircraft, Airline, Route, Date, Time, Flight, Weather, Loyalty) and
  fact tables (Flights, Bookings, Payments, Baggage, Flight Performance,
  Customer Support).

See `Metadata.md` for the detailed dictionary this build-out should rely on.
