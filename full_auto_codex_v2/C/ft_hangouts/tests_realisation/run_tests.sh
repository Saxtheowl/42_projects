#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STORE="data/store.json"
rm -f "$STORE"

echo "== Add contacts"
python3 src/mock_app.py --lang fr contacts add --first-name Alice --last-name V --phone 0600000001 --email alice@42.fr --campus Paris --tags dev staff
python3 src/mock_app.py --lang en contacts add --first-name Bob --last-name W --phone 0600000002 --email bob@42.fr --campus Lyon --tags dev

echo "== Send/receive messages"
python3 src/mock_app.py --lang fr messages receive --contact-id 1 --body "Ping ?"
python3 src/mock_app.py --lang en messages receive --contact-id 2 --body "Hi there"
python3 src/mock_app.py --lang fr messages send --contact-id 1 --body "Coucou"

echo "== List unread notifications"
python3 src/mock_app.py --lang fr notifications

echo "== Notifications JSON"
python3 src/mock_app.py --lang en notifications --json

echo "== Mark contact #1 as read"
python3 src/mock_app.py --lang fr messages mark-read --contact-id 1

echo "== List unread notifications after mark-read"
python3 src/mock_app.py --lang en notifications

echo "== List messages for contact #1"
python3 src/mock_app.py --lang en messages list --contact-id 1

echo "== List unread only for contact #2"
python3 src/mock_app.py --lang en messages list --contact-id 2 --unread-only

echo "== Filter contacts by tag"
python3 src/mock_app.py --lang en contacts list --tag dev

echo "== Export unread messages for contact #2"
python3 src/mock_app.py --lang en messages export --contact-id 2 --unread-only --output /tmp/ft_hangouts_messages_2.json
echo "Exported file size:"
stat -c%s /tmp/ft_hangouts_messages_2.json

echo "== Conversations summary"
python3 src/mock_app.py --lang en conversations
python3 src/mock_app.py --lang en conversations --json

echo "== Delete first message for contact #2"
first_msg_id=$(python3 -c "import json;print(json.load(open('/tmp/ft_hangouts_messages_2.json'))[0]['id'])")
python3 src/mock_app.py --lang en messages delete --message-id "$first_msg_id"
echo "== Unread notifications after delete"
python3 src/mock_app.py --lang en notifications --json

echo "== Send new unread message to contact #2"
python3 src/mock_app.py --lang en messages receive --contact-id 2 --body "New ping"

echo "== Mute contact #2 and check notifications (should be empty)"
python3 src/mock_app.py --lang en contacts mute --contact-id 2
python3 src/mock_app.py --lang en notifications --json

echo "== Unmute contact #2 and check notifications (should reappear)"
python3 src/mock_app.py --lang en contacts unmute --contact-id 2
python3 src/mock_app.py --lang en notifications --json

echo "== Search messages containing 'ping'"
python3 src/mock_app.py --lang en messages search --query ping

echo "== Export store"
python3 src/mock_app.py --lang en storage export --output /tmp/ft_hangouts_store.json
echo "Store size:"
stat -c%s /tmp/ft_hangouts_store.json

echo "== Reset store and re-import"
rm -f data/store.json
python3 src/mock_app.py --lang en storage import --input /tmp/ft_hangouts_store.json
python3 src/mock_app.py --lang en conversations

echo "== Pin contact #1 and check ordering"
python3 src/mock_app.py --lang en contacts pin --contact-id 1
python3 src/mock_app.py --lang en conversations

echo "== Stats summary"
python3 src/mock_app.py --lang en stats
python3 src/mock_app.py --lang en stats --json
