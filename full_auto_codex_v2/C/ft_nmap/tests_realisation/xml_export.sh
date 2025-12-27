#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_xml="$(mktemp)"
trap 'rm -f "$out_xml"' EXIT

echo "Checking XML export..."
./ft_nmap -t 127.0.0.1 -p 22,80 -T 200 -q -Z "$out_xml"

if [ ! -s "$out_xml" ]; then
	echo "XML report not generated" >&2
	exit 1
fi

python3 - <<'PY' "$out_xml"
import sys
import xml.etree.ElementTree as ET

path = sys.argv[1]
tree = ET.parse(path)
root = tree.getroot()
assert root.tag == "ft_nmap", f"Unexpected root tag: {root.tag}"
stats = root.find("stats")
assert stats is not None, "Missing <stats> node"
for key in ("requested", "scanned", "open", "closed", "timeouts"):
    assert key in stats.attrib, f"Missing stats attribute: {key}"
ports = root.find("ports")
assert ports is not None, "Missing <ports> node"
port_nodes = ports.findall("port")
assert len(port_nodes) == 2, f"Expected 2 port entries, got {len(port_nodes)}"
for node in port_nodes:
    for attr in ("id", "status", "duration_ms", "retries_used"):
        assert attr in node.attrib, f"Missing port attribute: {attr}"
print("XML parsed OK.")
PY

echo "XML export test OK."
