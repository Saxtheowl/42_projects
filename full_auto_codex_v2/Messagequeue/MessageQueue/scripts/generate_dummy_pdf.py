#!/usr/bin/env python3
import os
import sys
from datetime import datetime

out_dir = os.environ.get("PDF_OUTPUT_DIR", "shared/pdfs")
name = os.environ.get("PDF_NAME")
if not name:
    stamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    name = f"dummy_{stamp}.pdf"

os.makedirs(out_dir, exist_ok=True)
path = os.path.join(out_dir, name)

text = os.environ.get("PDF_TEXT", "MessageQueue dummy PDF")

# Minimal PDF with one page and a single text line.
content = (
    "BT\n"
    "/F1 24 Tf\n"
    "72 720 Td\n"
    f"({text}) Tj\n"
    "ET\n"
)
content_bytes = content.encode("latin-1")

objects = []

objects.append(b"1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n")
objects.append(b"2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n")
objects.append(
    b"3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] "
    b"/Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>\nendobj\n"
)
objects.append(
    b"4 0 obj\n<< /Length %d >>\nstream\n" % len(content_bytes)
    + content_bytes
    + b"endstream\nendobj\n"
)
objects.append(
    b"5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n"
)

with open(path, "wb") as f:
    f.write(b"%PDF-1.4\n")
    xref_positions = [0]
    for obj in objects:
        xref_positions.append(f.tell())
        f.write(obj)
    xref_start = f.tell()
    f.write(b"xref\n")
    f.write(f"0 {len(xref_positions)}\n".encode("ascii"))
    f.write(b"0000000000 65535 f \n")
    for pos in xref_positions[1:]:
        f.write(f"{pos:010d} 00000 n \n".encode("ascii"))
    f.write(b"trailer\n")
    f.write(
        f"<< /Size {len(xref_positions)} /Root 1 0 R >>\n".encode("ascii")
    )
    f.write(b"startxref\n")
    f.write(f"{xref_start}\n".encode("ascii"))
    f.write(b"%%EOF\n")

print(f"Generated {path}")
