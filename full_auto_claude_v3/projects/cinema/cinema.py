#!/usr/bin/env python3
"""
cinema - Movie Theater Booking System
Complete cinema management with seats, movies, and reservations
"""

import sys
import json
from datetime import datetime, timedelta
from typing import List, Dict, Optional
from dataclasses import dataclass, field, asdict
from enum import Enum
import os


class SeatStatus(Enum):
    AVAILABLE = "available"
    RESERVED = "reserved"
    OCCUPIED = "occupied"
    BLOCKED = "blocked"


@dataclass
class Seat:
    """A seat in a theater."""
    row: str
    number: int
    status: SeatStatus = SeatStatus.AVAILABLE
    price_tier: str = "standard"  # standard, premium, vip

    def __str__(self) -> str:
        return f"{self.row}{self.number}"


@dataclass
class Movie:
    """A movie."""
    id: int
    title: str
    duration: int  # minutes
    genre: str
    rating: str  # PG, PG-13, R, etc.
    description: str = ""

    def __str__(self) -> str:
        return f"{self.title} ({self.rating}, {self.duration}min)"


@dataclass
class Screen:
    """A movie screen/theater room."""
    id: int
    name: str
    rows: int
    seats_per_row: int
    screen_type: str = "standard"  # standard, imax, 3d

    def get_total_seats(self) -> int:
        return self.rows * self.seats_per_row


@dataclass
class Showtime:
    """A movie showing."""
    id: int
    movie_id: int
    screen_id: int
    start_time: datetime
    prices: Dict[str, float] = field(default_factory=dict)
    seats: Dict[str, SeatStatus] = field(default_factory=dict)

    def __post_init__(self):
        if not self.prices:
            self.prices = {"standard": 10.0, "premium": 15.0, "vip": 20.0}


@dataclass
class Reservation:
    """A ticket reservation."""
    id: int
    showtime_id: int
    seats: List[str]
    customer_name: str
    customer_email: str
    total_price: float
    created_at: datetime
    confirmed: bool = False


class CinemaSystem:
    """Cinema management system."""

    def __init__(self):
        self.movies: Dict[int, Movie] = {}
        self.screens: Dict[int, Screen] = {}
        self.showtimes: Dict[int, Showtime] = {}
        self.reservations: Dict[int, Reservation] = {}
        self.next_id = {"movie": 1, "screen": 1, "showtime": 1, "reservation": 1}

    def add_movie(self, title: str, duration: int, genre: str, rating: str,
                  description: str = "") -> Movie:
        """Add a new movie."""
        movie_id = self.next_id["movie"]
        self.next_id["movie"] += 1

        movie = Movie(movie_id, title, duration, genre, rating, description)
        self.movies[movie_id] = movie
        return movie

    def add_screen(self, name: str, rows: int, seats_per_row: int,
                   screen_type: str = "standard") -> Screen:
        """Add a new screen."""
        screen_id = self.next_id["screen"]
        self.next_id["screen"] += 1

        screen = Screen(screen_id, name, rows, seats_per_row, screen_type)
        self.screens[screen_id] = screen
        return screen

    def add_showtime(self, movie_id: int, screen_id: int, start_time: datetime,
                     prices: Optional[Dict[str, float]] = None) -> Optional[Showtime]:
        """Schedule a movie showing."""
        if movie_id not in self.movies or screen_id not in self.screens:
            return None

        showtime_id = self.next_id["showtime"]
        self.next_id["showtime"] += 1

        screen = self.screens[screen_id]

        # Initialize seats
        seats = {}
        for r in range(screen.rows):
            row_letter = chr(ord('A') + r)
            for s in range(1, screen.seats_per_row + 1):
                seat_id = f"{row_letter}{s}"
                seats[seat_id] = SeatStatus.AVAILABLE

        showtime = Showtime(
            showtime_id, movie_id, screen_id, start_time,
            prices or {"standard": 10.0, "premium": 15.0, "vip": 20.0},
            seats
        )
        self.showtimes[showtime_id] = showtime
        return showtime

    def get_seat_map(self, showtime_id: int) -> str:
        """Get visual seat map for a showtime."""
        if showtime_id not in self.showtimes:
            return "Showtime not found"

        showtime = self.showtimes[showtime_id]
        screen = self.screens[showtime.screen_id]

        lines = ["                    SCREEN", "=" * 50, ""]

        status_chars = {
            SeatStatus.AVAILABLE: "[ ]",
            SeatStatus.RESERVED: "[R]",
            SeatStatus.OCCUPIED: "[X]",
            SeatStatus.BLOCKED: "[#]",
        }

        for r in range(screen.rows):
            row_letter = chr(ord('A') + r)
            row_str = f"{row_letter} "

            for s in range(1, screen.seats_per_row + 1):
                seat_id = f"{row_letter}{s}"
                status = showtime.seats.get(seat_id, SeatStatus.AVAILABLE)
                row_str += status_chars[status] + " "

            lines.append(row_str)

        lines.append("")
        lines.append("Legend: [ ] Available  [R] Reserved  [X] Occupied  [#] Blocked")

        return "\n".join(lines)

    def make_reservation(self, showtime_id: int, seat_ids: List[str],
                         customer_name: str, customer_email: str) -> Optional[Reservation]:
        """Make a reservation."""
        if showtime_id not in self.showtimes:
            print("Showtime not found")
            return None

        showtime = self.showtimes[showtime_id]
        screen = self.screens[showtime.screen_id]

        # Validate seats
        total_price = 0.0
        for seat_id in seat_ids:
            if seat_id not in showtime.seats:
                print(f"Invalid seat: {seat_id}")
                return None

            if showtime.seats[seat_id] != SeatStatus.AVAILABLE:
                print(f"Seat {seat_id} is not available")
                return None

            # Determine price tier based on row
            row = seat_id[0]
            row_num = ord(row) - ord('A')

            if row_num < screen.rows // 3:
                tier = "standard"
            elif row_num < 2 * screen.rows // 3:
                tier = "premium"
            else:
                tier = "vip"

            total_price += showtime.prices.get(tier, 10.0)

        # Create reservation
        res_id = self.next_id["reservation"]
        self.next_id["reservation"] += 1

        reservation = Reservation(
            res_id, showtime_id, seat_ids, customer_name, customer_email,
            total_price, datetime.now()
        )

        # Mark seats as reserved
        for seat_id in seat_ids:
            showtime.seats[seat_id] = SeatStatus.RESERVED

        self.reservations[res_id] = reservation
        return reservation

    def confirm_reservation(self, reservation_id: int) -> bool:
        """Confirm a reservation."""
        if reservation_id not in self.reservations:
            return False

        reservation = self.reservations[reservation_id]
        reservation.confirmed = True

        # Mark seats as occupied
        showtime = self.showtimes[reservation.showtime_id]
        for seat_id in reservation.seats:
            showtime.seats[seat_id] = SeatStatus.OCCUPIED

        return True

    def cancel_reservation(self, reservation_id: int) -> bool:
        """Cancel a reservation."""
        if reservation_id not in self.reservations:
            return False

        reservation = self.reservations[reservation_id]

        # Free seats
        showtime = self.showtimes[reservation.showtime_id]
        for seat_id in reservation.seats:
            showtime.seats[seat_id] = SeatStatus.AVAILABLE

        del self.reservations[reservation_id]
        return True

    def get_movie_showtimes(self, movie_id: int) -> List[Showtime]:
        """Get all showtimes for a movie."""
        return [s for s in self.showtimes.values()
                if s.movie_id == movie_id and s.start_time > datetime.now()]

    def get_screen_schedule(self, screen_id: int, date: datetime) -> List[Showtime]:
        """Get schedule for a screen on a specific date."""
        return [s for s in self.showtimes.values()
                if s.screen_id == screen_id and
                s.start_time.date() == date.date()]

    def get_available_seats(self, showtime_id: int) -> List[str]:
        """Get list of available seats for a showtime."""
        if showtime_id not in self.showtimes:
            return []

        showtime = self.showtimes[showtime_id]
        return [seat_id for seat_id, status in showtime.seats.items()
                if status == SeatStatus.AVAILABLE]

    def print_reservation_ticket(self, reservation_id: int) -> str:
        """Generate a ticket for a reservation."""
        if reservation_id not in self.reservations:
            return "Reservation not found"

        reservation = self.reservations[reservation_id]
        showtime = self.showtimes[reservation.showtime_id]
        movie = self.movies[showtime.movie_id]
        screen = self.screens[showtime.screen_id]

        lines = [
            "=" * 50,
            "             CINEMA TICKET",
            "=" * 50,
            "",
            f"Movie:    {movie.title}",
            f"Rating:   {movie.rating}",
            f"Duration: {movie.duration} min",
            "",
            f"Screen:   {screen.name}",
            f"Date:     {showtime.start_time.strftime('%Y-%m-%d')}",
            f"Time:     {showtime.start_time.strftime('%H:%M')}",
            "",
            f"Seats:    {', '.join(reservation.seats)}",
            "",
            f"Customer: {reservation.customer_name}",
            f"Email:    {reservation.customer_email}",
            "",
            f"Total:    ${reservation.total_price:.2f}",
            f"Status:   {'CONFIRMED' if reservation.confirmed else 'PENDING'}",
            "",
            f"Reservation ID: {reservation.id}",
            "=" * 50,
        ]

        return "\n".join(lines)

    def generate_report(self) -> str:
        """Generate a sales report."""
        lines = [
            "=" * 60,
            "              CINEMA SALES REPORT",
            "=" * 60,
            "",
        ]

        total_revenue = 0.0
        total_tickets = 0

        for res in self.reservations.values():
            if res.confirmed:
                total_revenue += res.total_price
                total_tickets += len(res.seats)

        lines.append(f"Total Confirmed Reservations: {sum(1 for r in self.reservations.values() if r.confirmed)}")
        lines.append(f"Total Tickets Sold: {total_tickets}")
        lines.append(f"Total Revenue: ${total_revenue:.2f}")
        lines.append("")

        # Per movie breakdown
        lines.append("Revenue by Movie:")
        lines.append("-" * 40)

        for movie in self.movies.values():
            movie_revenue = 0.0
            movie_tickets = 0

            for res in self.reservations.values():
                if res.confirmed:
                    showtime = self.showtimes[res.showtime_id]
                    if showtime.movie_id == movie.id:
                        movie_revenue += res.total_price
                        movie_tickets += len(res.seats)

            if movie_tickets > 0:
                lines.append(f"  {movie.title}: {movie_tickets} tickets, ${movie_revenue:.2f}")

        lines.append("")
        lines.append("=" * 60)

        return "\n".join(lines)


def run_demo():
    """Run demonstration."""
    print("Cinema Booking System Demo")
    print("=" * 50)

    cinema = CinemaSystem()

    # Add movies
    movie1 = cinema.add_movie(
        "The Matrix Resurrections", 148, "Sci-Fi", "R",
        "Return to the world of two realities"
    )
    movie2 = cinema.add_movie(
        "Spider-Man: No Way Home", 148, "Action", "PG-13",
        "Peter Parker seeks help from Doctor Strange"
    )
    movie3 = cinema.add_movie(
        "Dune", 155, "Sci-Fi", "PG-13",
        "A mythic and emotionally charged hero's journey"
    )

    print("\nMovies added:")
    for m in cinema.movies.values():
        print(f"  - {m}")

    # Add screens
    screen1 = cinema.add_screen("Screen 1", 8, 12, "standard")
    screen2 = cinema.add_screen("Screen 2 IMAX", 10, 15, "imax")
    screen3 = cinema.add_screen("Screen 3 3D", 6, 10, "3d")

    print("\nScreens added:")
    for s in cinema.screens.values():
        print(f"  - {s.name}: {s.get_total_seats()} seats ({s.screen_type})")

    # Add showtimes
    today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)

    showtime1 = cinema.add_showtime(movie1.id, screen2.id,
                                    today + timedelta(hours=14))
    showtime2 = cinema.add_showtime(movie2.id, screen1.id,
                                    today + timedelta(hours=16, minutes=30))
    showtime3 = cinema.add_showtime(movie3.id, screen3.id,
                                    today + timedelta(hours=19))
    showtime4 = cinema.add_showtime(movie1.id, screen2.id,
                                    today + timedelta(hours=20, minutes=30))

    print("\nShowtimes scheduled:")
    for st in cinema.showtimes.values():
        movie = cinema.movies[st.movie_id]
        screen = cinema.screens[st.screen_id]
        print(f"  - {movie.title} @ {screen.name}: {st.start_time.strftime('%H:%M')}")

    # Show seat map
    print("\n" + "=" * 50)
    print(f"Seat Map for Showtime {showtime1.id}:")
    print(cinema.get_seat_map(showtime1.id))

    # Make reservations
    print("\n" + "=" * 50)
    print("Making reservations...")

    res1 = cinema.make_reservation(
        showtime1.id, ["E7", "E8", "E9"],
        "John Doe", "john@email.com"
    )
    if res1:
        print(f"\nReservation {res1.id} created for {res1.customer_name}")
        print(f"  Seats: {', '.join(res1.seats)}")
        print(f"  Total: ${res1.total_price:.2f}")

    res2 = cinema.make_reservation(
        showtime2.id, ["D5", "D6"],
        "Jane Smith", "jane@email.com"
    )
    if res2:
        print(f"\nReservation {res2.id} created for {res2.customer_name}")

    # Confirm reservations
    cinema.confirm_reservation(res1.id)
    cinema.confirm_reservation(res2.id)

    print("\nReservations confirmed!")

    # Print ticket
    print("\n" + cinema.print_reservation_ticket(res1.id))

    # Updated seat map
    print("\nUpdated Seat Map:")
    print(cinema.get_seat_map(showtime1.id))

    # Available seats
    available = cinema.get_available_seats(showtime1.id)
    print(f"\nAvailable seats: {len(available)}")

    # Generate report
    print("\n" + cinema.generate_report())


def interactive_mode():
    """Run interactive mode."""
    cinema = CinemaSystem()

    # Setup demo data
    cinema.add_movie("The Matrix", 136, "Sci-Fi", "R")
    cinema.add_movie("Inception", 148, "Sci-Fi", "PG-13")
    cinema.add_screen("Main Theater", 8, 12)

    today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
    cinema.add_showtime(1, 1, today + timedelta(hours=18))
    cinema.add_showtime(2, 1, today + timedelta(hours=21))

    while True:
        print("\n" + "=" * 40)
        print("Cinema Booking System")
        print("=" * 40)
        print("1. View Movies")
        print("2. View Showtimes")
        print("3. View Seat Map")
        print("4. Make Reservation")
        print("5. View Reservations")
        print("6. Generate Report")
        print("0. Exit")

        choice = input("\nChoice: ").strip()

        if choice == "0":
            break
        elif choice == "1":
            print("\nMovies:")
            for m in cinema.movies.values():
                print(f"  {m.id}. {m}")
        elif choice == "2":
            print("\nShowtimes:")
            for st in cinema.showtimes.values():
                movie = cinema.movies[st.movie_id]
                screen = cinema.screens[st.screen_id]
                avail = len(cinema.get_available_seats(st.id))
                print(f"  {st.id}. {movie.title} @ {st.start_time.strftime('%H:%M')} ({screen.name}) - {avail} seats")
        elif choice == "3":
            st_id = int(input("Showtime ID: "))
            print(cinema.get_seat_map(st_id))
        elif choice == "4":
            st_id = int(input("Showtime ID: "))
            seats = input("Seats (comma separated, e.g., E5,E6): ").split(",")
            seats = [s.strip().upper() for s in seats]
            name = input("Your name: ")
            email = input("Your email: ")
            res = cinema.make_reservation(st_id, seats, name, email)
            if res:
                cinema.confirm_reservation(res.id)
                print(cinema.print_reservation_ticket(res.id))
        elif choice == "5":
            print("\nReservations:")
            for r in cinema.reservations.values():
                movie = cinema.movies[cinema.showtimes[r.showtime_id].movie_id]
                print(f"  {r.id}. {r.customer_name}: {movie.title} - {', '.join(r.seats)}")
        elif choice == "6":
            print(cinema.generate_report())


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--help':
            print("cinema - Movie Theater Booking System")
            print("\nUsage:")
            print("  python cinema.py          - Run demo")
            print("  python cinema.py -i       - Interactive mode")
            return
        elif sys.argv[1] == '-i':
            interactive_mode()
            return

    run_demo()


if __name__ == "__main__":
    main()
