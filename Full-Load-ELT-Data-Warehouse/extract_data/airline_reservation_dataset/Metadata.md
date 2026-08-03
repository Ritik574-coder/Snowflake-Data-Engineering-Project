# Metadata — Airline Reservation System Dataset

## 1. Business Overview

This dataset simulates the operational and commercial data systems of a
mid-to-large airline group operating scheduled passenger flights across a
global route network. It spans five business areas:

1. **Network & Assets** — airlines, airports, aircraft, aircraft models, gates,
   routes, and the schedules that define recurring service between airports.
2. **Flight Operations** — the actual dated flight instances, their status
   history, crew staffing, delays, cancellations, weather at origin/destination
   airports, aircraft maintenance, and fuel consumption.
3. **Customers & Loyalty** — the customer master, loyalty program membership,
   and loyalty point activity.
4. **Reservations & Commerce** — bookings, passengers traveling on a booking,
   tickets, boarding passes, seat assignments, baggage, check-in events,
   ancillary service purchases, payments, and refunds.
5. **Customer Experience** — support tickets and post-flight feedback.

All 32 tables are referentially consistent with each other and are intended
to be loaded as a **Bronze (raw)** layer, then cleaned into **Silver**, then
modeled into a **Gold** Kimball star schema.

## 2. Table List & Approximate Row Counts

| # | Table | Rows | Grain |
|---|-------|------|-------|
| 1 | airlines | 20 | one row per airline |
| 2 | aircraft_models | 25 | one row per aircraft model/variant |
| 3 | airports | 250 | one row per airport |
| 4 | aircraft | 600 | one row per physical aircraft (tail number) |
| 5 | crew_members | 2,500 | one row per crew member |
| 6 | gate_information | 600 | one row per gate |
| 7 | flight_routes | 900 | one row per origin–destination pair |
| 8 | flight_schedules | 2,500 | one row per recurring scheduled service |
| 9 | customers | 60,000 | one row per customer |
| 10 | loyalty_members | 33,000 | one row per loyalty enrollment |
| 11 | flights | 80,000 | one row per dated flight instance |
| 12 | flight_status_logs | 304,640 | one row per status event per flight |
| 13 | crew_assignments | 320,000 | one row per crew member per flight |
| 14 | flight_delays | 10,057 | one row per delayed flight |
| 15 | flight_cancellations | 3,873 | one row per cancelled flight |
| 16 | fuel_usage | 80,000 | one row per flight |
| 17 | bookings | 150,000 | one row per reservation |
| 18 | passengers | 277,250 | one row per traveler on a booking |
| 19 | tickets | 277,250 | one row per passenger's ticket |
| 20 | boarding_passes | 232,755 | one row per passenger who boarded |
| 21 | seat_assignments | 232,755 | one row per occupied seat per flight |
| 22 | baggage | 349,384 | one row per bag |
| 23 | check_in_events | 232,755 | one row per passenger check-in |
| 24 | payments | 150,000 | one row per booking payment |
| 25 | refunds | 749 | one row per refunded payment |
| 26 | loyalty_transactions | 85,800 | one row per points-earning/redeeming event |
| 27 | weather_conditions | 40,000 | one row per airport weather observation |
| 28 | maintenance_logs | 6,000 | one row per maintenance event |
| 29 | aircraft_maintenance_history | 8,000 | one row per scheduled maintenance check |
| 30 | customer_support_tickets | 15,000 | one row per support case |
| 31 | feedback | 25,000 | one row per submitted feedback |
| 32 | ancillary_services | 123,654 | one row per purchased add-on service |

Total dataset size: **~196 MB** across 32 CSV files.

## 3. Table Dictionaries

Legend: **PK** = primary key, **FK** = foreign key, **N** = nullable.

### airlines
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| airline_id | string | PK | | Unique airline identifier (`AL####`) |
| airline_name | string | | | Airline name |
| iata_code | string | | | 2-letter IATA airline code |
| country | string | | | Country of registration |
| active_flag | boolean | | | Whether the airline is currently operating |

### aircraft_models
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| model_id | string | PK | | Unique model identifier (`AM####`) |
| manufacturer | string | | | Boeing / Airbus / Embraer / Bombardier |
| model_name | string | | | Model/variant name |
| capacity | int | | | Typical seating capacity |
| range_km | int | | | Typical range in kilometers |
| category | string | | | Narrow-body / Wide-body / Regional Jet |

### airports
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| airport_id | string | PK | | Unique airport identifier (`APT#####`) |
| iata_code | string | | | 3-letter airport code |
| airport_name | string | | | Airport name (may contain abbreviations, casing/whitespace noise) |
| city | string | | | City served |
| country | string | | | Country |
| timezone | string | | | UTC offset label |
| active_flag | boolean | | | Whether the airport is currently active |

### aircraft
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| aircraft_id | string | PK | | Unique aircraft identifier (`ACFT#####`) |
| tail_number | string | | | Registration/tail number |
| model_id | string | FK → aircraft_models | | Aircraft model |
| airline_id | string | FK → airlines | | Owning/operating airline |
| manufacture_year | int | | | Year built |
| status | string | | | Active / In Maintenance / Retired |

### crew_members
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| crew_id | string | PK | | Unique crew identifier (`CRW######`) |
| first_name / last_name | string | | | Crew member name |
| role | string | | | Captain / First Officer / Purser / Flight Attendant |
| airline_id | string | FK → airlines | | Employing airline |
| hire_date | date | | | ISO date |
| status | string | | | Active / On Leave / Inactive |
| license_number | string | | | License identifier |
| base_airport_id | string | FK → airports | | Home base airport |

### gate_information
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| gate_id | string | PK | | Unique gate identifier (`GATE#####`) |
| airport_id | string | FK → airports | | Airport the gate belongs to |
| terminal | string | | | Terminal label |
| gate_number | int | | | Gate number |
| gate_type | string | | | Domestic / International |

### flight_routes
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| route_id | string | PK | | Unique route identifier (`RT#####`) |
| origin_airport_id | string | FK → airports | | Origin |
| destination_airport_id | string | FK → airports | | Destination |
| distance_km | int | | | Great-circle distance approximation |
| typical_duration_min | int | | | Typical block time in minutes |

### flight_schedules
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| schedule_id | string | PK | | Unique schedule identifier (`SCH######`) |
| airline_id | string | FK → airlines | | Operating airline |
| route_id | string | FK → flight_routes | | Route served |
| flight_number | string | | | Marketing flight number |
| scheduled_departure_time | time (`HH:MM:SS`) | | | Local scheduled departure |
| scheduled_arrival_time | time (`HH:MM:SS`) | | | Local scheduled arrival |
| days_of_week | string | | | Recurrence pattern (e.g. `Daily`, `Mon-Fri`) |
| aircraft_model_id | string | FK → aircraft_models | | Typical aircraft model for this schedule |
| effective_start_date | date | | | Schedule validity start |
| effective_end_date | date | | | Schedule validity end |

### customers
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| customer_id | string | PK | | Unique customer identifier (`CUS#######`) |
| first_name | string | | | May contain casing/whitespace noise |
| middle_name | string | | Y | Frequently blank |
| last_name | string | | | May contain casing/whitespace noise |
| email | string | | | ~2% duplicated across customers (data-quality simulation) |
| phone | string | | | Multiple formats; ~1.5% duplicated |
| date_of_birth | date | | | ISO date |
| gender | string | | | Male / Female / Other / Prefer not to say |
| nationality | string | | | Country name; some rows use variant spellings (USA/U.S.A./UK/etc.) |
| address | string | | | Street address |
| city / country | string | | | Residential city/country |
| signup_date | date | | | Account creation date (always ≥ birth date) |
| active_flag | boolean | | | Whether the account is active |

### loyalty_members
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| loyalty_id | string | PK | | Unique loyalty identifier (`LOY#######`) |
| customer_id | string | FK → customers | | One customer may have zero or one loyalty enrollment |
| tier | string | | | Silver / Gold / Platinum / Blue |
| points_balance | int | | | Current point balance |
| enrollment_date | date | | | ISO date |
| status | string | | | Active / Suspended / Expired |

### flights
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| flight_id | string | PK | | Unique flight instance identifier (`FLT#######`) |
| schedule_id | string | FK → flight_schedules | | Parent schedule |
| flight_date | date | | | Date this instance operates |
| aircraft_id | string | FK → aircraft | | Assigned aircraft |
| airline_id | string | FK → airlines | | Operating airline |
| route_id | string | FK → flight_routes | | Route flown |
| scheduled_departure_time / scheduled_arrival_time | time | | | Planned local times |
| origin_airport_id / dest_airport_id | string | FK → airports | | Derived from route |
| status | string | | | Scheduled / Arrived / Delayed / Cancelled |
| actual_departure_time / actual_arrival_time | timestamp | | Y | Null for cancelled or future-scheduled flights |
| gate_id | string | FK → gate_information | Y | Null for ~4% of flights and all cancelled flights |

### flight_status_logs
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| log_id | string | PK | | Unique log identifier (`LOG########`) |
| flight_id | string | FK → flights | | Related flight |
| status | string | | | Scheduled / Boarding / Departed / Arrived / Cancelled |
| status_time | timestamp | | | When this status was recorded |
| remarks | string | | Y | Free-text remark, often blank |

### crew_assignments
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| assignment_id | string | PK | | Unique assignment identifier (`CA########`) |
| flight_id | string | FK → flights | | Flight staffed |
| crew_id | string | FK → crew_members | | Crew member assigned |
| role_on_flight | string | | | Captain / First Officer / Flight Attendant |

### flight_delays
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| delay_id | string | PK | | Unique delay identifier (`DLY######`) |
| flight_id | string | FK → flights | | Delayed flight (status = Delayed) |
| delay_minutes | int | | | Minutes delayed (15–240) |
| delay_reason | string | | | Weather / ATC / Mechanical / Crew / etc. |

### flight_cancellations
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| cancellation_id | string | PK | | Unique identifier (`CXL######`) |
| flight_id | string | FK → flights | | Cancelled flight |
| cancellation_reason | string | | | Weather / Mechanical / Crew / Demand / etc. |
| cancelled_at | timestamp | | | When the cancellation was recorded |

### fuel_usage
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| fuel_id | string | PK | | Unique identifier (`FUEL#######`) |
| flight_id | string | FK → flights | | One row per flight |
| aircraft_id | string | FK → aircraft | | Aircraft that consumed the fuel |
| fuel_liters | float | | | Estimated fuel burned |
| fuel_cost | float | | | Estimated cost |

### bookings
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| booking_id | string | PK | | Unique booking identifier (`BK########`) |
| customer_id | string | FK → customers | | Customer who made the booking |
| booking_date | date | | | Always before the flight date |
| flight_id | string | FK → flights | | Flight reserved |
| channel | string | | | Website / Mobile App / Travel Agent / Call Center / Kiosk |
| booking_status | string | | | Confirmed / Cancelled / Refunded |
| total_amount | float | | | Total booking value |
| currency | string | | | ISO currency code |

### passengers
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| passenger_id | string | PK | | Unique passenger identifier (`PAX########`) |
| booking_id | string | FK → bookings | | Parent booking (1–4 passengers per booking) |
| first_name / middle_name / last_name | string | | middle_name is Y | Traveler name |
| date_of_birth | date | | | ISO date |
| gender | string | | | Male / Female / Other |
| passport_number | string | | Y | Missing for ~10% of passengers (domestic travel) |
| loyalty_id | string | FK → loyalty_members | Y | Populated for ~35% of passengers |

### tickets
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| ticket_id | string | PK | | Unique ticket identifier (`TKT########`) |
| passenger_id | string | FK → passengers | | Ticket holder |
| booking_id | string | FK → bookings | | Parent booking |
| flight_id | string | FK → flights | | Flight ticketed |
| fare_class | string | | | Economy / Premium Economy / Business / First |
| ticket_price | float | | | Fare paid |
| ticket_status | string | | | Issued / Cancelled / Refunded (mirrors booking status) |

### boarding_passes
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| boarding_pass_id | string | PK | | Unique identifier (`BP########`) |
| ticket_id | string | FK → tickets | | Only issued tickets that actually boarded (~92%) |
| passenger_id | string | FK → passengers | | Passenger |
| flight_id | string | FK → flights | | Flight |
| seat_number | string | | | Assigned seat |
| boarding_time | timestamp | | | Boarding timestamp |
| boarding_group | string | | | Boarding group label (A–D) |

### seat_assignments
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| seat_assignment_id | string | PK | | Unique identifier (`SA########`) |
| flight_id | string | FK → flights | | Flight |
| aircraft_id | string | FK → aircraft | | Aircraft flown |
| seat_number | string | | | Seat |
| passenger_id | string | FK → passengers | | Occupant |
| class | string | | | Cabin class |

### baggage
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| baggage_id | string | PK | | Unique identifier (`BAG########`) |
| ticket_id | string | FK → tickets | | Associated ticket |
| passenger_id | string | FK → passengers | | Owner |
| weight_kg | float | | Y | Missing for ~3% of bags |
| baggage_type | string | | | Checked / Carry-on / Oversized |
| status | string | | | Loaded / Delayed / Lost / Damaged |

### check_in_events
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| checkin_id | string | PK | | Unique identifier (`CHK########`) |
| ticket_id | string | FK → tickets | | Ticket checked in |
| passenger_id | string | FK → passengers | | Passenger |
| flight_id | string | FK → flights | | Flight |
| checkin_time | timestamp | | | Always before boarding_time |
| checkin_method | string | | | Online / Mobile App / Kiosk / Counter |

### payments
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| payment_id | string | PK | | Unique identifier (`PAY########`) |
| booking_id | string | FK → bookings | | One payment per booking |
| payment_date | timestamp | | | Within 48 hours of booking_date |
| amount | float | | | Amount charged |
| payment_method | string | | | Credit Card / Debit Card / PayPal / Bank Transfer / Gift Card |
| payment_status | string | | | Completed / Failed / Voided / Refunded |

### refunds
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| refund_id | string | PK | | Unique identifier (`REF######`) |
| payment_id | string | FK → payments | | Only exists for payments with status = Refunded |
| booking_id | string | FK → bookings | | Related booking |
| refund_date | date | | | On/after the related payment date |
| refund_amount | float | | | Amount refunded (≤ original payment) |
| reason | string | | | Flight Cancelled / Passenger Request / etc. |

### loyalty_transactions
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| transaction_id | string | PK | | Unique identifier (`LT########`) |
| loyalty_id | string | FK → loyalty_members | | Member account |
| flight_id | string | FK → flights | Y | Populated when the activity is tied to a specific flight |
| points_earned | int | | | Nonzero for Earn/Bonus transactions |
| points_redeemed | int | | | Nonzero for Redeem transactions |
| transaction_date | date | | | ISO date |
| transaction_type | string | | | Earn / Redeem / Bonus / Adjustment |

### weather_conditions
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| weather_id | string | PK | | Unique identifier (`WX#######`) |
| airport_id | string | FK → airports | | Airport observed |
| observation_date | date | | | ISO date |
| condition | string | | | Clear / Rain / Thunderstorm / Snow / Fog / etc. |
| temperature_c | float | | | Degrees Celsius |
| wind_speed_kmh | float | | | Wind speed |
| visibility_km | float | | | Visibility |

### maintenance_logs
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| log_id | string | PK | | Unique identifier (`ML######`) |
| aircraft_id | string | FK → aircraft | | Aircraft serviced |
| log_date | date | | | ISO date |
| description | string | | | Type of work performed |
| technician | string | | | Technician name |
| status | string | | | Completed / In Progress / Scheduled |

### aircraft_maintenance_history
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| history_id | string | PK | | Unique identifier (`AMH######`) |
| aircraft_id | string | FK → aircraft | | Aircraft |
| maintenance_date | date | | | ISO date |
| maintenance_type | string | | | A/B/C/D-Check / Unscheduled Repair |
| cost | float | | | Cost of maintenance |
| next_due_date | date | | | Next scheduled maintenance |

### customer_support_tickets
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| ticket_id | string | PK | | Unique identifier (`SUP######`) |
| customer_id | string | FK → customers | | Customer who filed the case |
| booking_id | string | FK → bookings | Y | Populated for ~65% of cases |
| issue_type | string | | | Booking Issue / Refund Request / Baggage Complaint / etc. |
| opened_date | date | | | ISO date |
| status | string | | | Open / In Progress / Resolved / Closed |
| priority | string | | | Low / Medium / High / Urgent |

### feedback
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| feedback_id | string | PK | | Unique identifier (`FB######`) |
| customer_id | string | FK → customers | | Customer submitting feedback |
| flight_id | string | FK → flights | Y | Populated for ~80% of feedback |
| rating | int | | | 1–5 |
| comments | string | | Y | Free text, often blank/null |
| submitted_date | date | | | ISO date |

### ancillary_services
| Column | Type | Key | N | Description |
|---|---|---|---|---|
| service_id | string | PK | | Unique identifier (`ANC#######`) |
| booking_id | string | FK → bookings | | Booking the service was purchased under |
| passenger_id | string | FK → passengers | | Passenger the service applies to |
| service_type | string | | | Extra Baggage / Seat Upgrade / Wi-Fi / Lounge Access / etc. |
| amount | float | | | Price paid |
| status | string | | | Confirmed / Cancelled |

## 4. Relationship Overview

```
airlines ─┬─< aircraft
          ├─< crew_members
          ├─< flight_schedules ─< flights
          └─< flights

airports ─┬─< gate_information
          ├─< flight_routes (origin, destination)
          └─< weather_conditions

aircraft_models ─< aircraft
aircraft ─┬─< flights
          ├─< maintenance_logs
          ├─< aircraft_maintenance_history
          └─< fuel_usage

flight_routes ─< flight_schedules ─< flights
flights ─┬─< flight_status_logs
         ├─< crew_assignments >─ crew_members
         ├─< flight_delays
         ├─< flight_cancellations
         ├─< fuel_usage
         ├─< bookings
         ├─< tickets / boarding_passes / seat_assignments / check_in_events
         └─< feedback

customers ─┬─< loyalty_members ─< loyalty_transactions
           ├─< bookings ─┬─< passengers ─┬─< tickets ─┬─< boarding_passes
           │              │                │            ├─< baggage
           │              │                │            └─< check_in_events
           │              │                └─< seat_assignments (via ticket/flight)
           │              ├─< payments ─< refunds
           │              └─< ancillary_services
           ├─< customer_support_tickets
           └─< feedback
```

## 5. Business Rules Enforced

- Every flight's `actual_arrival_time` is always after `actual_departure_time`
  (or both are null for cancelled/future flights).
- `booking_date` always precedes the associated flight's `flight_date`.
- `signup_date` for a customer is always on/after their `date_of_birth`.
- Passengers, tickets, boarding passes, and baggage only exist for bookings
  and tickets that were actually issued (cancelled bookings still have
  passenger/ticket records, but ticket_status reflects the cancellation).
- `refunds` only exist against payments whose `payment_status = 'Refunded'`.
- `flight_delays` rows only exist for flights with `status = 'Delayed'`;
  `flight_cancellations` rows only exist for `status = 'Cancelled'`.
- `gate_id` is null for all cancelled flights and for a small share of
  otherwise-normal flights (unassigned/unknown gate).
- No negative prices, weights, durations, or ages anywhere in the dataset.
- All dates/timestamps use ISO 8601 (`YYYY-MM-DD` / `YYYY-MM-DD HH:MM:SS`)
  exclusively — no ambiguous or mixed date formats.

## 6. Intentional Data Quality Issues (for cleaning practice)

| Issue | Where |
|---|---|
| Leading/trailing whitespace | customers.first_name/last_name, airports.airport_name |
| Inconsistent casing (UPPER/lower) | customers.first_name/last_name, airports.airport_name |
| Missing optional values | customers.middle_name, passengers.middle_name/passport_number, flights.gate_id, baggage.weight_kg, flight_status_logs.remarks, feedback.comments |
| Duplicate emails / phone numbers | customers.email (~2%), customers.phone (~1.5%) |
| Inconsistent country naming | customers.nationality (USA/U.S.A./United States, UK/U.K./Britain, UAE/U.A.E.) |
| Multiple phone formats | customers.phone (parenthesized, dashed, +1-prefixed, digits-only) |
| Airport name abbreviations | airports.airport_name ("... Intl" vs "... International Airport") |
| Inactive entities | customers.active_flag, airports.active_flag, airlines.active_flag, aircraft.status = 'Retired' |
| Cancelled/refunded transactions | bookings.booking_status, payments.payment_status, tickets.ticket_status, refunds |
| Delayed/cancelled flights | flights.status, flight_delays, flight_cancellations |

None of these issues break referential integrity or produce impossible
values — they are formatting/completeness issues typical of real
operational exports, suitable for a Silver-layer cleaning pass.

## 7. Data Generation Assumptions

- Random seed fixed at 42 for reproducibility; re-running the generator
  produces identical output.
- Flight instances are generated by sampling from `flight_schedules` across
  a ~13-month window (2025-08-01 to 2026-08-15); flights dated after the
  "current" date (2026-08-03) are always in `Scheduled` status, since they
  haven't operated yet.
- Aircraft are preferentially assigned to flights operated by their own
  airline where available.
- Fare prices, fuel burn, and maintenance costs are modeled with
  reasonable random distributions rather than a precise revenue-management
  or engineering model — they are directionally realistic, not
  operationally exact.
- Currency amounts are not cross-converted; `currency` is a label only.

## 8. Expected Medallion Architecture Flow

- **Bronze:** Load all 32 CSVs as-is into raw/staging tables. Preserve
  original values including whitespace/casing noise and nulls.
- **Silver:** Trim/standardize text fields, normalize country and phone
  formats, deduplicate customers where appropriate, enforce data types,
  validate foreign keys, and quarantine/flag any rows that fail validation.
- **Gold:** Conform dimensions and build fact tables per the Kimball design
  below, ready for BI/analytics consumption.

## 9. Expected Kimball Warehouse Design

**Dimensions:** Dim Customer, Dim Passenger, Dim Airport, Dim Aircraft,
Dim Airline, Dim Route, Dim Date, Dim Time, Dim Flight, Dim Weather,
Dim Loyalty, Dim Crew, Dim Gate.

**Facts:**
- **Fact Flights** — grain: one row per flight instance (status, timings,
  delay minutes, aircraft/route/airline keys).
- **Fact Bookings** — grain: one row per booking (channel, amount, status).
- **Fact Payments** — grain: one row per payment/refund event.
- **Fact Baggage** — grain: one row per bag (weight, status).
- **Fact Flight Performance** — grain: one row per flight (on-time
  performance, delay reason, cancellation reason, fuel burn).
- **Fact Customer Support** — grain: one row per support ticket or
  feedback submission.

This dataset intentionally supplies enough raw detail (status logs, crew
assignments, weather, maintenance) to build these facts and dimensions
without needing additional source data.

## 9. Important Notes

- This dataset is synthetic. Airline names, airport codes, and routes are
  fictional/randomly generated and do not represent real airline
  operations or real people.
- No SQL, transformation logic, or solved pipelines are included here by
  design — this file documents the *data*, not how to process it.
