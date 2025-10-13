"""Dictionary helpers for the Wordle project."""

from __future__ import annotations

from pathlib import Path


PACKAGE_ROOT = Path(__file__).resolve().parent
DEFAULT_DICTIONARY_PATH = PACKAGE_ROOT.parent / "data" / "allowed_words.txt"


def load_dictionary(path: Path | str = DEFAULT_DICTIONARY_PATH) -> list[str]:
    """Return the list of allowed five-letter words from the given file."""
    dictionary_path = Path(path)
    if not dictionary_path.exists():
        raise FileNotFoundError(f"Dictionary file not found: {dictionary_path}")

    words: list[str] = []
    with dictionary_path.open("r", encoding="utf-8") as handle:
        for line in handle:
            word = line.strip().lower()
            if not word:
                continue
            if len(word) != 5 or not word.isalpha():
                raise ValueError(f"Invalid dictionary entry (expected five letters): {word!r}")
            words.append(word)

    if not words:
        raise ValueError(f"Dictionary is empty: {dictionary_path}")

    return words
