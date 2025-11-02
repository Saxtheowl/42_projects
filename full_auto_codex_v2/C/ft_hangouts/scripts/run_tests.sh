#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
CLI="${PROJECT_ROOT}/src/mock_app.py"
DATA_DIR="${PROJECT_ROOT}/data"
STORE="${DATA_DIR}/store.json"

rm -f "${STORE}"
mkdir -p "${DATA_DIR}"

python3 "${CLI}" --lang fr contacts add \
  --first-name Alice --last-name Mentor --phone 0611223344 \
  --email alice@42.fr --campus Paris --notes "Mentor piscine" \
  --tags Mentor Piscine >/tmp/ft_hangouts_cli.log
python3 "${CLI}" contacts add --first-name Ben --last-name Mentor --phone 0611002200 \
  --email ben@42.fr --campus Lyon --notes "Staff" --tags Staff >/tmp/ft_hangouts_cli.log
python3 "${CLI}" contacts list >/tmp/ft_hangouts_cli.log
python3 "${CLI}" messages send --contact-id 1 --body "Salut" >/tmp/ft_hangouts_cli.log
python3 "${CLI}" messages receive --contact-id 1 --body "Hey" >/tmp/ft_hangouts_cli.log
python3 "${CLI}" messages list --contact-id 1 >/tmp/ft_hangouts_cli.log

python3 "${CLI}" --lang en contacts edit --contact-id 1 --notes "Updated"
python3 "${CLI}" --lang en contacts delete --contact-id 2

echo "CLI tests OK. Store snapshot:"
cat "${STORE}"
