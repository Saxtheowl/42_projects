import sys


def capital_city():
    states = {
        "Oregon": "OR",
        "Alabama": "AL",
        "New Jersey": "NJ",
        "Colorado": "CO",
    }
    capital_cities = {
        "OR": "Salem",
        "AL": "Montgomery",
        "NJ": "Trenton",
        "CO": "Denver",
    }

    if len(sys.argv) != 2:
        return

    state = sys.argv[1]
    abbreviation = states.get(state)
    if abbreviation is None:
        print("Unknown state")
        return

    capital = capital_cities.get(abbreviation)
    if capital:
        print(capital)


if __name__ == "__main__":
    capital_city()
