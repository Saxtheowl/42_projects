#!/usr/bin/env python3
"""Minimal CLI prototype for ft_hangouts.

Usage examples:
  python src/mock_app.py contacts add --first-name Alice --last-name V --phone 0612345678 --email alice@42.fr --campus Paris --lang fr
  python src/mock_app.py contacts list
  python src/mock_app.py messages send --contact-id 1 --body "Hello" --lang en
  python src/mock_app.py messages receive --contact-id 1 --body "Hi" --lang fr
"""
import argparse
import json
import sys
from datetime import datetime
from pathlib import Path

DATA_PATH = Path(__file__).resolve().parent.parent / "data" / "store.json"
DATE_FMT = "%Y-%m-%d %H:%M:%S"

TRANSLATIONS = {
    "fr": {
        "contact_added": "Contact ajouté",
        "contact_updated": "Contact mis à jour",
        "contact_deleted": "Contact supprimé",
        "contact_not_found": "Contact introuvable",
        "contacts_header": "Liste des contacts",
        "messages_header": "Messages pour le contact {id}",
        "message_sent": "Message envoyé",
        "message_received": "Message reçu",
        "no_contacts": "Aucun contact",
        "no_messages": "Aucun message",
    },
    "en": {
        "contact_added": "Contact added",
        "contact_updated": "Contact updated",
        "contact_deleted": "Contact deleted",
        "contact_not_found": "Contact not found",
        "contacts_header": "Contacts",
        "messages_header": "Messages for contact {id}",
        "message_sent": "Message sent",
        "message_received": "Message received",
        "no_contacts": "No contacts",
        "no_messages": "No messages",
    },
}


def _load_data():
    if not DATA_PATH.exists():
        return {"contacts": [], "messages": [], "settings": {"last_background": None}}
    with DATA_PATH.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def _save_data(data):
    DATA_PATH.parent.mkdir(parents=True, exist_ok=True)
    with DATA_PATH.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, indent=2, ensure_ascii=False)


def _next_id(items):
    return (max((item["id"] for item in items), default=0) + 1)


def cmd_contacts_list(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    contacts = data["contacts"]
    if not contacts:
        print(lang["no_contacts"])
        return
    print(lang["contacts_header"])
    for contact in contacts:
        tags = ", ".join(contact.get("tags", [])) or "-"
        print(f"#{contact['id']} {contact['first_name']} {contact['last_name']} | {contact['phone']} | {contact.get('campus','')} | tags: {tags}")


def cmd_contacts_add(args):
    data = _load_data()
    contact = {
        "id": _next_id(data["contacts"]),
        "first_name": args.first_name,
        "last_name": args.last_name,
        "phone": args.phone,
        "email": args.email,
        "campus": args.campus,
        "notes": args.notes,
        "tags": args.tags or [],
        "created_at": datetime.utcnow().strftime(DATE_FMT),
        "updated_at": None,
    }
    data["contacts"].append(contact)
    _save_data(data)
    print(TRANSLATIONS[args.lang]["contact_added"])
    print(f"#{contact['id']} {contact['first_name']} {contact['last_name']}")


def _find_contact(data, contact_id):
    for contact in data["contacts"]:
        if contact["id"] == contact_id:
            return contact
    return None


def cmd_contacts_edit(args):
    data = _load_data()
    contact = _find_contact(data, args.contact_id)
    lang = TRANSLATIONS[args.lang]
    if not contact:
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    if args.first_name:
        contact["first_name"] = args.first_name
    if args.last_name:
        contact["last_name"] = args.last_name
    if args.phone:
        contact["phone"] = args.phone
    if args.email:
        contact["email"] = args.email
    if args.campus:
        contact["campus"] = args.campus
    if args.notes is not None:
        contact["notes"] = args.notes
    if args.tags is not None:
        contact["tags"] = args.tags
    contact["updated_at"] = datetime.utcnow().strftime(DATE_FMT)
    _save_data(data)
    print(lang["contact_updated"])


def cmd_contacts_delete(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    before = len(data["contacts"])
    data["contacts"] = [c for c in data["contacts"] if c["id"] != args.contact_id]
    if len(data["contacts"]) == before:
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    _save_data(data)
    print(lang["contact_deleted"])


def _add_message(data, contact_id, direction, body):
    message = {
        "id": _next_id(data["messages"]),
        "contact_id": contact_id,
        "direction": direction,
        "body": body,
        "timestamp": datetime.utcnow().strftime(DATE_FMT),
    }
    data["messages"].append(message)
    return message


def cmd_messages_list(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    if not _find_contact(data, args.contact_id):
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    messages = [m for m in data["messages"] if m["contact_id"] == args.contact_id]
    if not messages:
        print(lang["no_messages"])
        return
    print(lang["messages_header"].format(id=args.contact_id))
    for m in sorted(messages, key=lambda item: item["timestamp"]):
        print(f"{m['timestamp']} {m['direction']:<3} {m['body']}")


def cmd_messages_send(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    if not _find_contact(data, args.contact_id):
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    _add_message(data, args.contact_id, "OUT", args.body)
    _save_data(data)
    print(lang["message_sent"])


def cmd_messages_receive(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    if not _find_contact(data, args.contact_id):
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    _add_message(data, args.contact_id, "IN", args.body)
    _save_data(data)
    print(lang["message_received"])


def build_parser():
    parser = argparse.ArgumentParser(description="ft_hangouts CLI prototype")
    parser.add_argument("--lang", choices=TRANSLATIONS.keys(), default="fr")
    sub = parser.add_subparsers(dest="command")

    contacts = sub.add_parser("contacts", help="Contact operations")
    contacts_sub = contacts.add_subparsers(dest="subcommand")

    contacts_add = contacts_sub.add_parser("add", help="Add a contact")
    contacts_add.add_argument("--first-name", required=True)
    contacts_add.add_argument("--last-name", required=True)
    contacts_add.add_argument("--phone", required=True)
    contacts_add.add_argument("--email", default="")
    contacts_add.add_argument("--campus", default="")
    contacts_add.add_argument("--notes", default="")
    contacts_add.add_argument("--tags", nargs="*", default=[])
    contacts_add.set_defaults(func=cmd_contacts_add)

    contacts_list = contacts_sub.add_parser("list", help="List contacts")
    contacts_list.set_defaults(func=cmd_contacts_list)

    contacts_edit = contacts_sub.add_parser("edit", help="Edit a contact")
    contacts_edit.add_argument("--contact-id", type=int, required=True)
    contacts_edit.add_argument("--first-name")
    contacts_edit.add_argument("--last-name")
    contacts_edit.add_argument("--phone")
    contacts_edit.add_argument("--email")
    contacts_edit.add_argument("--campus")
    contacts_edit.add_argument("--notes")
    contacts_edit.add_argument("--tags", nargs="*")
    contacts_edit.set_defaults(func=cmd_contacts_edit)

    contacts_delete = contacts_sub.add_parser("delete", help="Delete a contact")
    contacts_delete.add_argument("--contact-id", type=int, required=True)
    contacts_delete.set_defaults(func=cmd_contacts_delete)

    messages = sub.add_parser("messages", help="Message operations")
    messages_sub = messages.add_subparsers(dest="subcommand")

    messages_list = messages_sub.add_parser("list", help="List messages")
    messages_list.add_argument("--contact-id", type=int, required=True)
    messages_list.set_defaults(func=cmd_messages_list)

    messages_send = messages_sub.add_parser("send", help="Send message")
    messages_send.add_argument("--contact-id", type=int, required=True)
    messages_send.add_argument("--body", required=True)
    messages_send.set_defaults(func=cmd_messages_send)

    messages_recv = messages_sub.add_parser("receive", help="Receive message")
    messages_recv.add_argument("--contact-id", type=int, required=True)
    messages_recv.add_argument("--body", required=True)
    messages_recv.set_defaults(func=cmd_messages_receive)

    return parser


def main(argv=None):
    parser = build_parser()
    args = parser.parse_args(argv)
    if not getattr(args, "command", None):
        parser.print_help()
        return 0
    if args.command == "contacts" and not getattr(args, "subcommand", None):
        parser.print_help()
        return 0
    if args.command == "messages" and not getattr(args, "subcommand", None):
        parser.print_help()
        return 0
    args.func(args)
    return 0
if __name__ == "__main__":
    sys.exit(main())
