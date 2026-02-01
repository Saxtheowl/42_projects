# cinema - Movie Theater Booking System

Complete cinema management with movies, screens, showtimes, and reservations.

## Features

- Movie management
- Screen/theater room configuration
- Showtime scheduling
- Seat selection with visual map
- Reservation system
- Ticket generation
- Sales reporting

## Usage

```bash
python3 cinema.py      # Run demo
python3 cinema.py -i   # Interactive mode
```

## System Components

### Movies
- Title, duration, genre, rating
- Description

### Screens
- Configurable rows and seats
- Screen types: standard, imax, 3d

### Showtimes
- Movie + screen + time
- Tiered pricing (standard, premium, vip)
- Seat availability tracking

### Reservations
- Multiple seat selection
- Customer information
- Confirmation workflow
- Ticket generation

## Seat Status

| Status | Display | Description |
|--------|---------|-------------|
| Available | `[ ]` | Can be reserved |
| Reserved | `[R]` | Reserved, pending confirmation |
| Occupied | `[X]` | Confirmed, sold |
| Blocked | `[#]` | Not available |

## API Example

```python
from cinema import CinemaSystem

cinema = CinemaSystem()

# Add movie
movie = cinema.add_movie("Dune", 155, "Sci-Fi", "PG-13")

# Add screen
screen = cinema.add_screen("IMAX", 10, 15, "imax")

# Schedule showtime
from datetime import datetime, timedelta
showtime = cinema.add_showtime(
    movie.id, screen.id,
    datetime.now() + timedelta(hours=2)
)

# Make reservation
reservation = cinema.make_reservation(
    showtime.id, ["E7", "E8"],
    "John Doe", "john@email.com"
)

# Confirm and print ticket
cinema.confirm_reservation(reservation.id)
print(cinema.print_reservation_ticket(reservation.id))

# Generate report
print(cinema.generate_report())
```

## Price Tiers

Seats are priced by row position:
- **Standard**: Front third of theater
- **Premium**: Middle third
- **VIP**: Back third (best view)

## Author

Implementation for 42 curriculum.
