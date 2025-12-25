from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent


def parse_element(line):
    name_part, data_part = line.split("=", 1)
    attributes = {"name": name_part.strip()}
    for raw in data_part.split(","):
        if ":" not in raw:
            continue
        key, value = raw.split(":", 1)
        attributes[key.strip()] = value.strip()
    return attributes


def load_elements():
    elements = []
    with open(BASE_DIR / "periodic_table.txt", "r", encoding="utf-8") as file:
        for line in file:
            striped = line.strip()
            if striped:
                elements.append(parse_element(striped))
    return elements


def build_rows(elements):
    rows = {}
    for element in elements:
        row_index = int(element.get("row", 0))
        rows.setdefault(row_index, []).append(element)

    ordered_rows = []
    for row_index in sorted(index for index in rows if index != 0):
        cells = [None] * 18
        for element in rows[row_index]:
            position = int(element.get("position", 0))
            cells[position] = element
        ordered_rows.append(cells)
    return ordered_rows


def element_cell(element):
    number = element.get("number", "")
    symbol = element.get("small", "")
    mass = element.get("molar", "")
    electrons = element.get("electron", "")
    try:
        electron_count = int(float(electrons))
    except (TypeError, ValueError):
        electron_count = None
    electron_label = "electron" if electron_count == 1 else "electrons"
    if electrons == "":
        electron_text = ""
    else:
        electron_text = f"<li>{electrons} {electron_label}</li>"

    return (
        '<td style="border: 1px solid black; padding:10px">'
        f"<h4>{element.get('name', '')}</h4>"
        "<ul>"
        f"<li>No {number}</li>"
        f"<li>{symbol}</li>"
        f"<li>{mass}</li>"
        f"{electron_text}"
        "</ul>"
        "</td>"
    )


def periodic_table():
    elements = load_elements()
    rows = build_rows(elements)

    html_parts = ["<!DOCTYPE html>", "<html>", "<head><meta charset='utf-8'><title>Periodic Table</title></head>", "<body>", "<table>"]
    for row in rows:
        html_parts.append("<tr>")
        for element in row:
            if element is None:
                html_parts.append("<td></td>")
            else:
                html_parts.append(element_cell(element))
        html_parts.append("</tr>")
    html_parts.extend(["</table>", "</body>", "</html>"])

    output_path = BASE_DIR / "periodic_table.html"
    with open(output_path, "w", encoding="utf-8") as file:
        file.write("\n".join(html_parts))


if __name__ == "__main__":
    periodic_table()
