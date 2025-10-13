"""Wordle game logic."""

from __future__ import annotations

from dataclasses import dataclass, field
from enum import Enum
from typing import Iterable, List, Sequence, Tuple


class TileStatus(str, Enum):
    """Possible evaluation outcomes for a single letter."""

    CORRECT = "correct"
    PRESENT = "present"
    ABSENT = "absent"


@dataclass
class WordleGame:
    """Encapsulates the Wordle game state and rules."""

    target: str
    allowed_words: Iterable[str]
    max_attempts: int = 6
    history: list[Tuple[str, list[TileStatus]]] = field(default_factory=list)

    def __post_init__(self) -> None:
        self.target = self.target.lower()
        if len(self.target) != 5 or not self.target.isalpha():
            raise ValueError("Target word must be a five-letter alphabetic string.")
        self._allowed_set = {word.lower() for word in self.allowed_words}
        if self.target not in self._allowed_set:
            self._allowed_set.add(self.target)
        if self.max_attempts <= 0:
            raise ValueError("max_attempts must be a positive integer.")

    @property
    def attempts_used(self) -> int:
        return len(self.history)

    @property
    def attempts_remaining(self) -> int:
        return self.max_attempts - self.attempts_used

    @property
    def is_over(self) -> bool:
        return self.has_won or self.attempts_used >= self.max_attempts

    @property
    def has_won(self) -> bool:
        return any(all(status is TileStatus.CORRECT for status in statuses) for _, statuses in self.history)

    def is_valid_guess(self, guess: str) -> bool:
        normalized = guess.lower()
        return len(normalized) == 5 and normalized.isalpha() and normalized in self._allowed_set

    def evaluate_guess(self, guess: str) -> list[TileStatus]:
        normalized = guess.lower()
        if len(normalized) != len(self.target):
            raise ValueError("Guess must have the same length as the target word.")
        if not normalized.isalpha():
            raise ValueError("Guess must contain only alphabetic characters.")

        statuses: list[TileStatus] = [TileStatus.ABSENT] * len(self.target)
        remaining_letters: list[str] = []

        # First pass: mark exact matches and collect remaining letters.
        for index, (guess_char, target_char) in enumerate(zip(normalized, self.target)):
            if guess_char == target_char:
                statuses[index] = TileStatus.CORRECT
            else:
                remaining_letters.append(target_char)

        # Second pass: mark present letters using remaining pool (handles duplicates).
        for index, guess_char in enumerate(normalized):
            if statuses[index] is TileStatus.CORRECT:
                continue
            if guess_char in remaining_letters:
                statuses[index] = TileStatus.PRESENT
                remaining_letters.remove(guess_char)

        return statuses

    def apply_guess(self, guess: str) -> list[TileStatus]:
        normalized = guess.lower()
        if not self.is_valid_guess(normalized):
            raise ValueError("Guess must be a valid dictionary word of five letters.")
        if self.is_over:
            raise RuntimeError("No attempts remaining.")

        statuses = self.evaluate_guess(normalized)
        self.history.append((normalized, statuses))
        return statuses


def render_feedback(guess: str, statuses: Sequence[TileStatus]) -> str:
    """Return an ASCII representation of the feedback for a guess."""
    mapping = {
        TileStatus.CORRECT: "G",
        TileStatus.PRESENT: "Y",
        TileStatus.ABSENT: "_",
    }
    parts = [f"[{mapping[status]}]" for status in statuses]
    return f"{guess.upper()} {' '.join(parts)}"
