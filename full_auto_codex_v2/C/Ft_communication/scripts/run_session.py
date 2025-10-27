#!/usr/bin/env python3
import argparse
import datetime as _dt
import json
import sys
import textwrap
from pathlib import Path
from typing import List, Optional


EXERCISES = [
    (
        "Exercice 00 – Présentation",
        [
            "Présente-toi en trois minutes.",
            "Mentionne un élément marquant de ton parcours.",
            "Partage un centre d'intérêt ou un projet personnel.",
        ],
    ),
    (
        "Exercice 01 – Le passé",
        [
            "Pourquoi as-tu rejoint 42 ?",
            "Quelles étaient tes attentes au départ ?",
            "Une anecdote marquante depuis ton entrée ?",
        ],
    ),
    (
        "Exercice 02 – Le futur",
        [
            "Que souhaites-tu faire après 42 ?",
            "Quelles compétences veux-tu développer ?",
            "Avec qui aimerais-tu collaborer ?",
        ],
    ),
]


def _wrap(text: str) -> str:
    return textwrap.fill(text, width=78)


def _print_header(title: str) -> None:
    separator = "=" * len(title)
    print(f"\n{title}\n{separator}")


def _sanitize_participants(raw: Optional[str]) -> List[str]:
    if not raw:
        return []
    return [item.strip() for item in raw.split(",") if item.strip()]


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Assistant de session pour le projet ft_communication.",
    )
    parser.add_argument(
        "--participants",
        help="Liste des participants séparés par des virgules (ex: Alice,Bob).",
    )
    parser.add_argument(
        "--log",
        help="Chemin d'un fichier Markdown pour consigner des notes (optionnel).",
    )
    parser.add_argument(
        "--non-interactif",
        dest="non_interactif",
        action="store_true",
        help="Affiche simplement le déroulé sans interaction (usage doc/tests).",
    )
    parser.add_argument(
        "--json",
        dest="json_dump",
        help="Écrit un récapitulatif JSON à l'emplacement indiqué.",
    )
    return parser


def _prompt(prompt: str) -> None:
    try:
        input(prompt)
    except KeyboardInterrupt:
        print("\nInterruption demandée. Bonne continuation !")
        sys.exit(0)


def _dump_markdown(path: Path, participants: List[str], notes: List[str]) -> None:
    timestamp = _dt.datetime.now().strftime("%Y-%m-%d %H:%M")
    lines = [
        f"# Session ft_communication — {timestamp}",
        "",
        f"Participants : {', '.join(participants) if participants else 'non renseigné'}",
        "",
        "## Notes",
    ]
    lines.extend(notes)
    lines.append("")
    path.write_text("\n".join(lines), encoding="utf-8")


def _dump_json(path: Path, participants: List[str], exercises: List[str]) -> None:
    payload = {
        "timestamp": _dt.datetime.now().isoformat(timespec="minutes"),
        "participants": participants,
        "exercises": exercises,
    }
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def run_session(args: argparse.Namespace) -> int:
    participants = _sanitize_participants(args.participants)
    notes: List[str] = []

    _print_header("ft_communication — assistant de session")
    if participants:
        print(_wrap(f"Participants : {', '.join(participants)}"))
    else:
        print(_wrap("Participants : à renseigner"))
    print(_wrap("Durée conseillée : 35 à 40 minutes."))
    print(_wrap("Conseil : gardez cette fenêtre comme guide, sans lire mot à mot."))

    if args.non_interactif:
        for title, questions in EXERCISES:
            _print_header(title)
            for question in questions:
                print(f"- {question}")
        return 0

    _prompt("\nAppuie sur Entrée lorsque tout le monde est connecté…")
    for title, questions in EXERCISES:
        _print_header(title)
        print(_wrap("Objectif : laisser chaque participant s'exprimer librement."))
        for question in questions:
            print(f"- {question}")
        _prompt("\nAppuie sur Entrée une fois l'exercice terminé.")
        notes.append(f"- {title} : points clés à renseigner après la session.")

    print("\nSession terminée. Pense à partager les coordonnées si souhaité, "
          "et à écrire un court bilan.")

    if args.log:
        path = Path(args.log)
        try:
            _dump_markdown(path, participants, notes)
            print(f"Notes enregistrées dans {path}")
        except OSError as exc:
            print(f"Impossible d'écrire {path}: {exc}", file=sys.stderr)
            return 1

    if args.json_dump:
        path = Path(args.json_dump)
        try:
            _dump_json(path, participants, [item[0] for item in EXERCISES])
            print(f"Récapitulatif JSON écrit dans {path}")
        except OSError as exc:
            print(f"Impossible d'écrire {path}: {exc}", file=sys.stderr)
            return 1

    return 0


def main() -> int:
    parser = _build_parser()
    args = parser.parse_args()
    return run_session(args)


if __name__ == "__main__":
    sys.exit(main())
