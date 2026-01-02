#!/usr/bin/env python3
"""Minimal CLI prototype for ft_hangouts.

Usage examples:
  python src/mock_app.py contacts add --first-name Alice --last-name V --phone 0612345678 --email alice@42.fr --campus Paris --lang fr
  python src/mock_app.py contacts list
  python src/mock_app.py messages send --contact-id 1 --body "Hello" --lang en
  python src/mock_app.py messages receive --contact-id 1 --body "Hi" --lang fr
"""
import argparse
import csv
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

DATA_PATH = Path(__file__).resolve().parent.parent / "data" / "store.json"
DATE_FMT = "%Y-%m-%d %H:%M:%S"

TRANSLATIONS = {
    "fr": {
        "contact_added": "Contact ajouté",
        "contact_updated": "Contact mis à jour",
        "contact_deleted": "Contact supprimé",
        "contact_not_found": "Contact introuvable",
        "contact_muted": "Contact mis en sourdine",
        "contact_unmuted": "Contact réactivé",
        "contact_pinned": "Contact épinglé",
        "contact_unpinned": "Contact désépinglé",
        "contacts_header": "Liste des contacts",
        "messages_header": "Messages pour le contact {id}",
        "contacts_exported": "Contacts exportés",
        "contacts_imported": "Contacts importés",
        "call_logged": "Appel enregistré",
        "call_deleted": "Appel supprimé",
        "call_not_found": "Appel introuvable",
        "calls_exported": "Appels exportés",
        "calls_imported": "Appels importés",
        "no_calls": "Aucun appel",
        "message_sent": "Message envoyé",
        "message_received": "Message reçu",
        "messages_marked": "{count} message(s) marqués comme lus",
        "message_deleted": "Message supprimé",
        "message_not_found": "Message introuvable",
        "contact_auto_created": "Contact créé automatiquement",
        "contact_required": "Contact requis (id ou téléphone)",
        "settings_header": "Paramètres",
        "theme_set": "Thème mis à jour",
        "avatar_set": "Avatar mis à jour",
        "unread_header": "Notifications non lues",
        "no_unread": "Aucune notification non lue",
        "background_saved": "Sync arrière-plan enregistrée à {ts}",
        "no_contacts": "Aucun contact",
        "no_messages": "Aucun message",
    },
    "en": {
        "contact_added": "Contact added",
        "contact_updated": "Contact updated",
        "contact_deleted": "Contact deleted",
        "contact_not_found": "Contact not found",
        "contact_muted": "Contact muted",
        "contact_unmuted": "Contact unmuted",
        "contact_pinned": "Contact pinned",
        "contact_unpinned": "Contact unpinned",
        "contacts_header": "Contacts",
        "messages_header": "Messages for contact {id}",
        "contacts_exported": "Contacts exported",
        "contacts_imported": "Contacts imported",
        "call_logged": "Call logged",
        "call_deleted": "Call deleted",
        "call_not_found": "Call not found",
        "calls_exported": "Calls exported",
        "calls_imported": "Calls imported",
        "no_calls": "No calls",
        "message_sent": "Message sent",
        "message_received": "Message received",
        "messages_marked": "{count} message(s) marked as read",
        "message_deleted": "Message deleted",
        "message_not_found": "Message not found",
        "contact_auto_created": "Contact auto-created",
        "contact_required": "Contact required (id or phone)",
        "settings_header": "Settings",
        "theme_set": "Theme updated",
        "avatar_set": "Avatar updated",
        "unread_header": "Unread notifications",
        "no_unread": "No unread notifications",
        "background_saved": "Background sync saved at {ts}",
        "no_contacts": "No contacts",
        "no_messages": "No messages",
    },
}


def _load_data():
    if not DATA_PATH.exists():
        return {"contacts": [], "messages": [], "settings": {"last_background": None, "theme": "blue"}}
    with DATA_PATH.open("r", encoding="utf-8") as fh:
        data = json.load(fh)
    # Backward compat: inject missing keys
    if "settings" not in data:
        data["settings"] = {"last_background": None, "theme": "blue"}
    if "theme" not in data["settings"]:
        data["settings"]["theme"] = "blue"
    if "calls" not in data:
        data["calls"] = []
    for contact in data.get("contacts", []):
        if "muted" not in contact:
            contact["muted"] = False
        if "pinned" not in contact:
            contact["pinned"] = False
        if "avatar" not in contact:
            contact["avatar"] = ""
    for message in data.get("messages", []):
        if "read" not in message:
            message["read"] = message.get("direction") == "OUT"
    return data


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
    if args.tag:
        contacts = [c for c in contacts if args.tag in (c.get("tags") or [])]
    if args.campus:
        contacts = [c for c in contacts if c.get("campus") == args.campus]
    if not contacts:
        print(lang["no_contacts"])
        return
    print(lang["contacts_header"])
    for contact in sorted(contacts, key=lambda c: (not c.get("pinned"), c.get("first_name"))):
        tags = ", ".join(contact.get("tags", [])) or "-"
        pin = "[pin]" if contact.get("pinned") else ""
        muted = "[muted]" if contact.get("muted") else ""
        avatar = contact.get("avatar") or "-"
        print(f"#{contact['id']} {contact['first_name']} {contact['last_name']} {pin}{muted} | {contact['phone']} | {contact.get('campus','')} | avatar: {avatar} | tags: {tags}")


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
        "avatar": args.avatar or "",
        "created_at": datetime.now(timezone.utc).strftime(DATE_FMT),
        "updated_at": None,
        "muted": False,
        "pinned": False,
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


def _find_contact_by_phone(data, phone):
    for contact in data["contacts"]:
        if contact.get("phone") == phone:
            return contact
    return None


def _create_contact_from_message(data, args):
    contact = {
        "id": _next_id(data["contacts"]),
        "first_name": args.first_name or "Unknown",
        "last_name": args.last_name or "",
        "phone": args.phone,
        "email": args.email or "",
        "campus": args.campus or "",
        "notes": args.notes or "",
        "tags": args.tags or [],
        "avatar": args.avatar or "",
        "created_at": datetime.now(timezone.utc).strftime(DATE_FMT),
        "updated_at": None,
        "muted": False,
        "pinned": False,
    }
    data["contacts"].append(contact)
    return contact


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
    if args.avatar is not None:
        contact["avatar"] = args.avatar
    if args.mute:
        contact["muted"] = True
    if args.unmute:
        contact["muted"] = False
    if args.pin:
        contact["pinned"] = True
    if args.unpin:
        contact["pinned"] = False
    contact["updated_at"] = datetime.now(timezone.utc).strftime(DATE_FMT)
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


def _split_tags(raw):
    if not raw:
        return []
    if ";" in raw:
        parts = raw.split(";")
    elif "," in raw:
        parts = raw.split(",")
    else:
        parts = [raw]
    return [part.strip() for part in parts if part.strip()]


def cmd_contacts_export(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = [
        "first_name",
        "last_name",
        "phone",
        "email",
        "campus",
        "notes",
        "tags",
        "avatar",
    ]
    with out_path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.DictWriter(fh, fieldnames=fieldnames)
        writer.writeheader()
        for contact in data.get("contacts", []):
            writer.writerow(
                {
                    "first_name": contact.get("first_name", ""),
                    "last_name": contact.get("last_name", ""),
                    "phone": contact.get("phone", ""),
                    "email": contact.get("email", ""),
                    "campus": contact.get("campus", ""),
                    "notes": contact.get("notes", ""),
                    "tags": ";".join(contact.get("tags") or []),
                    "avatar": contact.get("avatar", ""),
                }
            )
    print(f"{lang['contacts_exported']}: {out_path}")


def cmd_contacts_import(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    src_path = Path(args.input)
    if not src_path.exists():
        print(f"Input file not found: {src_path}", file=sys.stderr)
        sys.exit(1)
    with src_path.open("r", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        imported = 0
        for row in reader:
            contact = {
                "id": _next_id(data["contacts"]),
                "first_name": row.get("first_name", "") or "",
                "last_name": row.get("last_name", "") or "",
                "phone": row.get("phone", "") or "",
                "email": row.get("email", "") or "",
                "campus": row.get("campus", "") or "",
                "notes": row.get("notes", "") or "",
                "tags": _split_tags(row.get("tags", "")),
                "avatar": row.get("avatar", "") or "",
                "created_at": datetime.now(timezone.utc).strftime(DATE_FMT),
                "updated_at": None,
                "muted": False,
                "pinned": False,
            }
            data["contacts"].append(contact)
            imported += 1
    _save_data(data)
    print(f"{lang['contacts_imported']}: {imported}")


def _find_call(data, call_id):
    for call in data.get("calls", []):
        if call["id"] == call_id:
            return call
    return None


def _add_call(data, contact_id, direction, duration, missed):
    call = {
        "id": _next_id(data["calls"]),
        "contact_id": contact_id,
        "direction": direction,
        "duration": duration,
        "missed": missed,
        "timestamp": datetime.now(timezone.utc).strftime(DATE_FMT),
    }
    data["calls"].append(call)
    return call


def _resolve_contact_for_import(data, call_entry, auto_create):
    contact_id = call_entry.get("contact_id")
    if contact_id is not None:
        contact = _find_contact(data, contact_id)
        if contact:
            return contact
    phone = call_entry.get("phone")
    if phone:
        contact = _find_contact_by_phone(data, phone)
        if contact:
            return contact
        if auto_create:
            class Args:
                pass
            args = Args()
            args.first_name = call_entry.get("first_name") or "Unknown"
            args.last_name = call_entry.get("last_name") or ""
            args.phone = phone
            args.email = call_entry.get("email") or ""
            args.campus = call_entry.get("campus") or ""
            args.notes = call_entry.get("notes") or ""
            args.tags = call_entry.get("tags") or []
            args.avatar = call_entry.get("avatar") or ""
            return _create_contact_from_message(data, args)
    return None


def cmd_calls_log(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    contact = None
    if args.contact_id is not None:
        contact = _find_contact(data, args.contact_id)
    if not contact and args.phone:
        contact = _find_contact_by_phone(data, args.phone)
    if not contact and args.auto_create and args.phone:
        contact = _create_contact_from_message(data, args)
        print(lang["contact_auto_created"])
    if not contact:
        print(lang["contact_required"], file=sys.stderr)
        sys.exit(1)
    _add_call(data, contact["id"], args.direction, args.duration, args.missed)
    _save_data(data)
    print(lang["call_logged"])


def cmd_calls_list(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    calls = data.get("calls", [])
    if args.contact_id:
        calls = [c for c in calls if c["contact_id"] == args.contact_id]
    if args.missed_only:
        calls = [c for c in calls if c.get("missed")]
    if not calls:
        print(lang["no_calls"])
        return
    if args.json:
        print(json.dumps(calls, ensure_ascii=False))
        return
    contacts = {c["id"]: c for c in data.get("contacts", [])}
    print("Calls")
    for call in sorted(calls, key=lambda item: item["timestamp"]):
        c = contacts.get(call["contact_id"])
        label = f"{c['first_name']} {c['last_name']}" if c else f"#{call['contact_id']}"
        missed = "missed" if call.get("missed") else "ok"
        print(f"{call['timestamp']} {label} {call['direction']} {call['duration']}s {missed}")


def cmd_calls_delete(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    before = len(data.get("calls", []))
    data["calls"] = [c for c in data.get("calls", []) if c["id"] != args.call_id]
    if len(data["calls"]) == before:
        print(lang["call_not_found"], file=sys.stderr)
        sys.exit(1)
    _save_data(data)
    print(lang["call_deleted"])


def cmd_calls_stats(args):
    data = _load_data()
    calls = data.get("calls", [])
    stats = {
        "calls": len(calls),
        "calls_missed": sum(1 for c in calls if c.get("missed")),
        "calls_in": sum(1 for c in calls if c.get("direction") == "IN"),
        "calls_out": sum(1 for c in calls if c.get("direction") == "OUT"),
        "total_duration": sum(c.get("duration", 0) for c in calls),
    }
    if args.json:
        print(json.dumps(stats, ensure_ascii=False))
        return
    print(f"Calls: {stats['calls']} (missed: {stats['calls_missed']})")
    print(f"IN: {stats['calls_in']} OUT: {stats['calls_out']} total_duration: {stats['total_duration']}s")


def cmd_calls_export(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    contacts = {c["id"]: c for c in data.get("contacts", [])}
    payload = []
    for call in data.get("calls", []):
        c = contacts.get(call["contact_id"])
        payload.append(
            {
                "contact_id": call.get("contact_id"),
                "phone": c.get("phone") if c else "",
                "first_name": c.get("first_name") if c else "",
                "last_name": c.get("last_name") if c else "",
                "direction": call.get("direction"),
                "duration": call.get("duration"),
                "missed": call.get("missed"),
                "timestamp": call.get("timestamp"),
            }
        )
    with out_path.open("w", encoding="utf-8") as fh:
        json.dump(payload, fh, ensure_ascii=False, indent=2)
    print(f"{lang['calls_exported']}: {out_path}")


def cmd_calls_import(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    src_path = Path(args.input)
    if not src_path.exists():
        print(f"Input file not found: {src_path}", file=sys.stderr)
        sys.exit(1)
    with src_path.open("r", encoding="utf-8") as fh:
        payload = json.load(fh)
    imported = 0
    for entry in payload:
        contact = _resolve_contact_for_import(data, entry, args.auto_create)
        if not contact:
            continue
        data["calls"].append(
            {
                "id": _next_id(data["calls"]),
                "contact_id": contact["id"],
                "direction": entry.get("direction", "IN"),
                "duration": int(entry.get("duration") or 0),
                "missed": bool(entry.get("missed")),
                "timestamp": entry.get("timestamp") or datetime.now(timezone.utc).strftime(DATE_FMT),
            }
        )
        imported += 1
    _save_data(data)
    print(f"{lang['calls_imported']}: {imported}")

def cmd_contacts_pin(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    contact = _find_contact(data, args.contact_id)
    if not contact:
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    contact["pinned"] = True
    _save_data(data)
    print(lang["contact_pinned"])


def cmd_contacts_unpin(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    contact = _find_contact(data, args.contact_id)
    if not contact:
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    contact["pinned"] = False
    _save_data(data)
    print(lang["contact_unpinned"])


def cmd_contacts_mute(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    contact = _find_contact(data, args.contact_id)
    if not contact:
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    contact["muted"] = True
    _save_data(data)
    print(lang["contact_muted"])


def cmd_contacts_unmute(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    contact = _find_contact(data, args.contact_id)
    if not contact:
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    contact["muted"] = False
    _save_data(data)
    print(lang["contact_unmuted"])


def _add_message(data, contact_id, direction, body):
    message = {
        "id": _next_id(data["messages"]),
        "contact_id": contact_id,
        "direction": direction,
        "body": body,
        "timestamp": datetime.now(timezone.utc).strftime(DATE_FMT),
        "read": direction == "OUT",  # outgoing are considered read
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
    if args.unread_only:
        messages = [m for m in messages if not m.get("read")]
    if not messages:
        print(lang["no_messages"])
        return
    print(lang["messages_header"].format(id=args.contact_id))
    for m in sorted(messages, key=lambda item: item["timestamp"]):
        status = "✓" if m.get("read") else "•"
        print(f"{m['timestamp']} {m['direction']:<3} {status} {m['body']}")


def cmd_messages_export(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    if not _find_contact(data, args.contact_id):
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    messages = [m for m in data["messages"] if m["contact_id"] == args.contact_id]
    if args.unread_only:
        messages = [m for m in messages if not m.get("read")]
    if not messages:
        print(lang["no_messages"])
        return
    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as fh:
        json.dump(messages, fh, ensure_ascii=False, indent=2)
    print(f"Exported {len(messages)} message(s) to {out_path}")


def cmd_messages_search(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    contacts = {c["id"]: c for c in data.get("contacts", [])}
    query = args.query.lower()
    messages = data.get("messages", [])
    if args.contact_id:
        messages = [m for m in messages if m["contact_id"] == args.contact_id]
    matches = [m for m in messages if query in m["body"].lower()]
    if not matches:
        print(lang["no_messages"])
        return
    print(f"Search results ({len(matches)})")
    for m in sorted(matches, key=lambda item: item["timestamp"]):
        c = contacts.get(m["contact_id"])
        label = f"{c['first_name']} {c['last_name']}" if c else f"#{m['contact_id']}"
        status = "✓" if m.get("read") else "•"
        print(f"{m['timestamp']} [{label}] {m['direction']:<3} {status} {m['body']}")


def cmd_storage_export(args):
    data = _load_data()
    out_path = Path(args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", encoding="utf-8") as fh:
        json.dump(data, fh, ensure_ascii=False, indent=2)
    print(f"Store exported to {out_path}")


def cmd_storage_import(args):
    src_path = Path(args.input)
    if not src_path.exists():
        print(f"Input file not found: {src_path}", file=sys.stderr)
        sys.exit(1)
    with src_path.open("r", encoding="utf-8") as fh:
        data = json.load(fh)
    _save_data(data)
    print(f"Store imported from {src_path}")


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
    contact = None
    if args.contact_id is not None:
        contact = _find_contact(data, args.contact_id)
    if not contact and args.phone:
        contact = _find_contact_by_phone(data, args.phone)
    if not contact and args.auto_create and args.phone:
        contact = _create_contact_from_message(data, args)
        print(lang["contact_auto_created"])
    if not contact:
        print(lang["contact_required"], file=sys.stderr)
        sys.exit(1)
    _add_message(data, contact["id"], "IN", args.body)
    _save_data(data)
    print(lang["message_received"])


def cmd_messages_delete(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    before = len(data["messages"])
    data["messages"] = [m for m in data["messages"] if m["id"] != args.message_id]
    if len(data["messages"]) == before:
        print(lang["message_not_found"], file=sys.stderr)
        sys.exit(1)
    _save_data(data)
    print(lang["message_deleted"])


def cmd_messages_mark_read(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    if not _find_contact(data, args.contact_id):
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    count = 0
    for m in data["messages"]:
        if m["contact_id"] == args.contact_id and not m.get("read"):
            m["read"] = True
            count += 1
    _save_data(data)
    print(lang["messages_marked"].format(count=count))


def cmd_notifications_summary(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    unread_by_contact = {}
    for m in data["messages"]:
        if m.get("read"):
            continue
        cid = m["contact_id"]
        contact = next((c for c in data.get("contacts", []) if c["id"] == cid), None)
        if contact and contact.get("muted"):
            continue
        unread_by_contact.setdefault(cid, 0)
        unread_by_contact[cid] += 1
    contacts = {c["id"]: c for c in data.get("contacts", [])}
    summary = []
    for cid, count in sorted(unread_by_contact.items(), key=lambda item: item[1], reverse=True):
        c = contacts.get(cid)
        label = f"{c['first_name']} {c['last_name']}" if c else f"#{cid}"
        if c and c.get("muted"):
            label += " [muted]"
        if c and c.get("pinned"):
            label += " [pin]"
        summary.append({
            "contact_id": cid,
            "count": count,
            "label": label
        })
    if args.json:
        print(json.dumps(summary, ensure_ascii=False))
    else:
        if not summary:
            print(lang["no_unread"])
        else:
            print(lang["unread_header"])
            for item in summary:
                print(f"{item['label']}: {item['count']}")
    if args.as_background:
        data["settings"]["last_background"] = datetime.now(timezone.utc).strftime(DATE_FMT)
        _save_data(data)
        print(lang["background_saved"].format(ts=data["settings"]["last_background"]))


def cmd_conversations_summary(args):
    data = _load_data()
    contacts = {c["id"]: c for c in data.get("contacts", [])}
    conversations = {}
    for m in data.get("messages", []):
        cid = m["contact_id"]
        conv = conversations.setdefault(cid, {"last": None, "unread": 0})
        if (conv["last"] is None) or (m["timestamp"] > conv["last"]["timestamp"]):
            conv["last"] = {"timestamp": m["timestamp"], "direction": m["direction"], "body": m["body"]}
        if not m.get("read"):
            conv["unread"] += 1
    summary = []
    for cid, info in conversations.items():
        c = contacts.get(cid)
        label = f"{c['first_name']} {c['last_name']}" if c else f"#{cid}"
        if c and c.get("muted"):
            label += " [muted]"
        if c and c.get("pinned"):
            label += " [pin]"
        summary.append({
            "contact_id": cid,
            "label": label,
            "unread": info["unread"],
            "last_message": info["last"]["body"] if info["last"] else "",
            "last_timestamp": info["last"]["timestamp"] if info["last"] else "",
        })
    summary.sort(key=lambda item: (not contacts.get(item["contact_id"], {}).get("pinned", False), item["last_timestamp"]), reverse=True)
    if args.json:
        print(json.dumps(summary, ensure_ascii=False))
        return
    if not summary:
        print(TRANSLATIONS[args.lang]["no_messages"])
        return
    print("Conversations")
    for item in summary:
        badge = f"({item['unread']} unread)" if item["unread"] else "(0 unread)"
        print(f"{item['label']} {badge} — {item['last_timestamp']} {item['last_message']}")


def cmd_stats(args):
    data = _load_data()
    contacts = data.get("contacts", [])
    messages = data.get("messages", [])
    stats = {
        "contacts": len(contacts),
        "contacts_muted": sum(1 for c in contacts if c.get("muted")),
        "contacts_pinned": sum(1 for c in contacts if c.get("pinned")),
        "messages": len(messages),
        "messages_unread": sum(1 for m in messages if not m.get("read")),
    }
    if args.json:
        print(json.dumps(stats, ensure_ascii=False))
    else:
        print(f"Contacts: {stats['contacts']} (muted: {stats['contacts_muted']}, pinned: {stats['contacts_pinned']})")
        print(f"Messages: {stats['messages']} (unread: {stats['messages_unread']})")


def cmd_contacts_set_avatar(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    contact = _find_contact(data, args.contact_id)
    if not contact:
        print(lang["contact_not_found"], file=sys.stderr)
        sys.exit(1)
    contact["avatar"] = args.avatar
    contact["updated_at"] = datetime.now(timezone.utc).strftime(DATE_FMT)
    _save_data(data)
    print(lang["avatar_set"])


def cmd_settings_show(args):
    data = _load_data()
    lang = TRANSLATIONS[args.lang]
    settings = data.get("settings", {})
    if args.json:
        print(json.dumps(settings, ensure_ascii=False))
        return
    print(lang["settings_header"])
    print(f"Theme: {settings.get('theme', 'blue')}")
    print(f"Last background: {settings.get('last_background')}")


def cmd_settings_set_theme(args):
    data = _load_data()
    data.setdefault("settings", {})
    data["settings"]["theme"] = args.color
    _save_data(data)
    print(TRANSLATIONS[args.lang]["theme_set"])


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
    contacts_add.add_argument("--avatar", help="Avatar path or label", default="")
    contacts_add.set_defaults(func=cmd_contacts_add)

    contacts_list = contacts_sub.add_parser("list", help="List contacts")
    contacts_list.add_argument("--tag", help="Filter by tag")
    contacts_list.add_argument("--campus", help="Filter by campus")
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
    contacts_edit.add_argument("--avatar")
    contacts_edit.add_argument("--mute", action="store_true", help="Passer le contact en sourdine")
    contacts_edit.add_argument("--unmute", action="store_true", help="Réactiver le contact")
    contacts_edit.add_argument("--pin", action="store_true", help="Épingler le contact")
    contacts_edit.add_argument("--unpin", action="store_true", help="Désépingler le contact")
    contacts_edit.set_defaults(func=cmd_contacts_edit)

    contacts_delete = contacts_sub.add_parser("delete", help="Delete a contact")
    contacts_delete.add_argument("--contact-id", type=int, required=True)
    contacts_delete.set_defaults(func=cmd_contacts_delete)

    contacts_mute = contacts_sub.add_parser("mute", help="Mute a contact")
    contacts_mute.add_argument("--contact-id", type=int, required=True)
    contacts_mute.set_defaults(func=cmd_contacts_mute)

    contacts_unmute = contacts_sub.add_parser("unmute", help="Unmute a contact")
    contacts_unmute.add_argument("--contact-id", type=int, required=True)
    contacts_unmute.set_defaults(func=cmd_contacts_unmute)

    contacts_pin = contacts_sub.add_parser("pin", help="Pin a contact")
    contacts_pin.add_argument("--contact-id", type=int, required=True)
    contacts_pin.set_defaults(func=cmd_contacts_pin)

    contacts_unpin = contacts_sub.add_parser("unpin", help="Unpin a contact")
    contacts_unpin.add_argument("--contact-id", type=int, required=True)
    contacts_unpin.set_defaults(func=cmd_contacts_unpin)

    contacts_avatar = contacts_sub.add_parser("set-avatar", help="Set contact avatar")
    contacts_avatar.add_argument("--contact-id", type=int, required=True)
    contacts_avatar.add_argument("--avatar", required=True)
    contacts_avatar.set_defaults(func=cmd_contacts_set_avatar)

    contacts_export = contacts_sub.add_parser("export", help="Export contacts to CSV")
    contacts_export.add_argument("--output", required=True)
    contacts_export.set_defaults(func=cmd_contacts_export)

    contacts_import = contacts_sub.add_parser("import", help="Import contacts from CSV")
    contacts_import.add_argument("--input", required=True)
    contacts_import.set_defaults(func=cmd_contacts_import)

    calls = sub.add_parser("calls", help="Call operations")
    calls_sub = calls.add_subparsers(dest="subcommand")
    calls_log = calls_sub.add_parser("log", help="Log a call")
    calls_log.add_argument("--contact-id", type=int)
    calls_log.add_argument("--phone", help="Phone number (auto-create if unknown)")
    calls_log.add_argument("--first-name", help="Auto-create contact first name")
    calls_log.add_argument("--last-name", help="Auto-create contact last name")
    calls_log.add_argument("--email", help="Auto-create contact email")
    calls_log.add_argument("--campus", help="Auto-create contact campus")
    calls_log.add_argument("--notes", help="Auto-create contact notes")
    calls_log.add_argument("--tags", nargs="*", help="Auto-create contact tags")
    calls_log.add_argument("--avatar", help="Auto-create contact avatar")
    calls_log.add_argument("--auto-create", action="store_true", help="Create contact when unknown")
    calls_log.add_argument("--direction", choices=["IN", "OUT"], required=True)
    calls_log.add_argument("--duration", type=int, default=0)
    calls_log.add_argument("--missed", action="store_true")
    calls_log.set_defaults(func=cmd_calls_log)

    calls_list = calls_sub.add_parser("list", help="List calls")
    calls_list.add_argument("--contact-id", type=int)
    calls_list.add_argument("--missed-only", action="store_true")
    calls_list.add_argument("--json", action="store_true")
    calls_list.set_defaults(func=cmd_calls_list)

    calls_delete = calls_sub.add_parser("delete", help="Delete call")
    calls_delete.add_argument("--call-id", type=int, required=True)
    calls_delete.set_defaults(func=cmd_calls_delete)

    calls_stats = calls_sub.add_parser("stats", help="Calls stats")
    calls_stats.add_argument("--json", action="store_true")
    calls_stats.set_defaults(func=cmd_calls_stats)

    calls_export = calls_sub.add_parser("export", help="Export calls to JSON")
    calls_export.add_argument("--output", required=True)
    calls_export.set_defaults(func=cmd_calls_export)

    calls_import = calls_sub.add_parser("import", help="Import calls from JSON")
    calls_import.add_argument("--input", required=True)
    calls_import.add_argument("--auto-create", action="store_true")
    calls_import.set_defaults(func=cmd_calls_import)

    messages = sub.add_parser("messages", help="Message operations")
    messages_sub = messages.add_subparsers(dest="subcommand")

    messages_list = messages_sub.add_parser("list", help="List messages")
    messages_list.add_argument("--contact-id", type=int, required=True)
    messages_list.add_argument("--unread-only", action="store_true", help="Afficher uniquement les messages non lus")
    messages_list.set_defaults(func=cmd_messages_list)

    messages_send = messages_sub.add_parser("send", help="Send message")
    messages_send.add_argument("--contact-id", type=int, required=True)
    messages_send.add_argument("--body", required=True)
    messages_send.set_defaults(func=cmd_messages_send)

    messages_recv = messages_sub.add_parser("receive", help="Receive message")
    messages_recv.add_argument("--contact-id", type=int)
    messages_recv.add_argument("--phone", help="Phone number (auto-create if unknown)")
    messages_recv.add_argument("--first-name", help="Auto-create contact first name")
    messages_recv.add_argument("--last-name", help="Auto-create contact last name")
    messages_recv.add_argument("--email", help="Auto-create contact email")
    messages_recv.add_argument("--campus", help="Auto-create contact campus")
    messages_recv.add_argument("--notes", help="Auto-create contact notes")
    messages_recv.add_argument("--tags", nargs="*", help="Auto-create contact tags")
    messages_recv.add_argument("--avatar", help="Auto-create contact avatar")
    messages_recv.add_argument("--auto-create", action="store_true", help="Create contact when unknown")
    messages_recv.add_argument("--body", required=True)
    messages_recv.set_defaults(func=cmd_messages_receive)

    messages_mark = messages_sub.add_parser("mark-read", help="Mark messages as read")
    messages_mark.add_argument("--contact-id", type=int, required=True)
    messages_mark.set_defaults(func=cmd_messages_mark_read)

    messages_delete = messages_sub.add_parser("delete", help="Delete a message by id")
    messages_delete.add_argument("--message-id", type=int, required=True)
    messages_delete.set_defaults(func=cmd_messages_delete)

    messages_export = messages_sub.add_parser("export", help="Export messages to JSON")
    messages_export.add_argument("--contact-id", type=int, required=True)
    messages_export.add_argument("--output", required=True, help="Path to JSON output")
    messages_export.add_argument("--unread-only", action="store_true", help="Exporter uniquement les messages non lus")
    messages_export.set_defaults(func=cmd_messages_export)

    messages_search = messages_sub.add_parser("search", help="Search messages")
    messages_search.add_argument("--query", required=True)
    messages_search.add_argument("--contact-id", type=int)
    messages_search.set_defaults(func=cmd_messages_search)

    notifications = sub.add_parser("notifications", help="Notification summary")
    notifications.add_argument("--as-background", action="store_true", help="Enregistrer le passage en mode arrière-plan")
    notifications.add_argument("--json", action="store_true", help="Sortie JSON")
    notifications.set_defaults(func=cmd_notifications_summary)

    conversations = sub.add_parser("conversations", help="Conversations summary")
    conversations.add_argument("--json", action="store_true", help="Sortie JSON")
    conversations.set_defaults(func=cmd_conversations_summary)

    storage = sub.add_parser("storage", help="Export/import the store")
    storage_sub = storage.add_subparsers(dest="subcommand")
    storage_export = storage_sub.add_parser("export", help="Export store to JSON")
    storage_export.add_argument("--output", required=True)
    storage_export.set_defaults(func=cmd_storage_export)
    storage_import = storage_sub.add_parser("import", help="Import store from JSON")
    storage_import.add_argument("--input", required=True)
    storage_import.set_defaults(func=cmd_storage_import)

    stats = sub.add_parser("stats", help="Display store stats")
    stats.add_argument("--json", action="store_true", help="Sortie JSON")
    stats.set_defaults(func=cmd_stats)

    settings = sub.add_parser("settings", help="Settings operations")
    settings_sub = settings.add_subparsers(dest="subcommand")
    settings_show = settings_sub.add_parser("show", help="Show settings")
    settings_show.add_argument("--json", action="store_true", help="Sortie JSON")
    settings_show.set_defaults(func=cmd_settings_show)
    settings_theme = settings_sub.add_parser("set-theme", help="Set header theme color")
    settings_theme.add_argument("--color", choices=["blue", "green", "orange"], required=True)
    settings_theme.set_defaults(func=cmd_settings_set_theme)

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
    if args.command == "calls" and not getattr(args, "subcommand", None):
        parser.print_help()
        return 0
    if args.command == "messages" and not getattr(args, "subcommand", None):
        parser.print_help()
        return 0
    if args.command == "settings" and not getattr(args, "subcommand", None):
        parser.print_help()
        return 0
    args.func(args)
    return 0
if __name__ == "__main__":
    sys.exit(main())
