import sys


def normalize(value):
    return " ".join(value.strip().split()).lower()


def all_in():
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

    expressions = [part.strip() for part in sys.argv[1].split(",")]
    if any(not expr for expr in expressions):
        return

    states_lookup = {normalize(state): abbr for state, abbr in states.items()}
    capitals_lookup = {normalize(city): abbr for abbr, city in capital_cities.items()}
    abbr_to_state = {abbr: state for state, abbr in states.items()}

    for original in expressions:
        key = normalize(original)
        if key in states_lookup:
            abbr = states_lookup[key]
            capital = capital_cities.get(abbr)
            state_name = abbr_to_state.get(abbr)
            print(f"{capital} is the capital of {state_name}")
        elif key in capitals_lookup:
            abbr = capitals_lookup[key]
            capital = capital_cities.get(abbr)
            state_name = abbr_to_state.get(abbr)
            print(f"{capital} is the capital of {state_name}")
        else:
            print(f"{original} is neither a capital city nor a state")


if __name__ == "__main__":
    all_in()
