import sys


def state():
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

    capital = sys.argv[1]
    match = None
    for abbreviation, city in capital_cities.items():
        if city == capital:
            match = abbreviation
            break

    if match is None:
        print("Unknown capital city")
        return

    for state_name, abbreviation in states.items():
        if abbreviation == match:
            print(state_name)
            break


if __name__ == "__main__":
    state()
