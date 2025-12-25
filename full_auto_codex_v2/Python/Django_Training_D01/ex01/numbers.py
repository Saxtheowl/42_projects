from pathlib import Path


def print_numbers():
    file_path = Path(__file__).resolve().parent / "numbers.txt"
    with open(file_path, "r", encoding="utf-8") as file:
        content = file.read().strip()
    if not content:
        return
    for number in content.split(","):
        cleaned = number.strip()
        if cleaned:
            print(cleaned)


if __name__ == "__main__":
    print_numbers()
