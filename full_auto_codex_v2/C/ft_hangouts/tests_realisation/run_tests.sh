#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

STORE="data/store.json"
rm -f "$STORE"

echo "== Add contacts"
python3 src/mock_app.py --lang fr contacts add --first-name Alice --last-name V --phone 0600000001 --email alice@42.fr --campus Paris --tags dev staff --avatar alice.png
python3 src/mock_app.py --lang en contacts add --first-name Bob --last-name W --phone 0600000002 --email bob@42.fr --campus Lyon --tags dev --avatar bob.jpg

echo "== Send/receive messages"
python3 src/mock_app.py --lang fr messages receive --contact-id 1 --body "Ping ?"
python3 src/mock_app.py --lang en messages receive --contact-id 2 --body "Hi there"
python3 src/mock_app.py --lang fr messages send --contact-id 1 --body "Coucou"

echo "== Receive message from unknown number (auto-create contact)"
python3 src/mock_app.py --lang fr messages receive --phone 0600000003 --first-name Chloe --last-name Z --avatar chloe.png --auto-create --body "Salut"
python3 src/mock_app.py --lang fr contacts list

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

echo "== Settings theme change"
python3 src/mock_app.py --lang en settings set-theme --color green
python3 src/mock_app.py --lang en settings show

echo "== Update avatar for contact #2"
python3 src/mock_app.py --lang en contacts set-avatar --contact-id 2 --avatar bob_new.jpg
python3 src/mock_app.py --lang en contacts list

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

echo "== Export contacts to CSV"
python3 src/mock_app.py --lang en contacts export --output /tmp/ft_hangouts_contacts.csv
echo "Contacts CSV size:"
stat -c%s /tmp/ft_hangouts_contacts.csv

echo "== Log calls"
python3 src/mock_app.py --lang en calls log --contact-id 1 --direction OUT --duration 120
python3 src/mock_app.py --lang en calls log --contact-id 2 --direction IN --duration 0 --missed
python3 src/mock_app.py --lang en calls log --phone 0600000004 --first-name Denis --last-name K --auto-create --direction IN --duration 45
python3 src/mock_app.py --lang en calls list
python3 src/mock_app.py --lang en calls list --missed-only
python3 src/mock_app.py --lang en calls stats
python3 src/mock_app.py --lang en calls stats --json

echo "== Export calls to JSON"
python3 src/mock_app.py --lang en calls export --output /tmp/ft_hangouts_calls.json
echo "Calls JSON size:"
stat -c%s /tmp/ft_hangouts_calls.json

echo "== Reset store and import contacts CSV"
rm -f data/store.json
python3 src/mock_app.py --lang en contacts import --input /tmp/ft_hangouts_contacts.csv
python3 src/mock_app.py --lang en contacts list

echo "== Import calls JSON (auto-create disabled)"
python3 src/mock_app.py --lang en calls import --input /tmp/ft_hangouts_calls.json
python3 src/mock_app.py --lang en calls stats --json
