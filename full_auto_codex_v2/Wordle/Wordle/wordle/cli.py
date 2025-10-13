"""Command-line interface for playing Wordle."""

from __future__ import annotations

import argparse
import random
import sys
from typing import Iterable

from .dictionary import DEFAULT_DICTIONARY_PATH, load_dictionary
from .game import TileStatus, WordleGame, render_feedback


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Play a local Wordle clone.")
    parser.add_argument(
        "--dictionary",
        type=str,
        default=str(DEFAULT_DICTIONARY_PATH),
        help="Path to the allowed words list (default: data/allowed_words.txt).",
    )
    parser.add_argument(
        "--target",
        type=str,
        help="Force the target word (must exist in the dictionary).",
    )
    parser.add_argument(
        "--seed",
        type=int,
        help="Seed for the random generator when choosing the target word.",
    )
    parser.add_argument(
        "--max-attempts",
        type=int,
        default=6,
        help="Maximum number of guesses allowed (default: 6).",
    )
    parser.add_argument(
        "--quiet",
        action="store_true",
        help="Suppress introductory text (useful for automated testing).",
    )
    return parser


def choose_target(words: Iterable[str], seed: int | None) -> str:
    word_list = list(words)
    rng = random.Random(seed)
    return rng.choice(word_list)


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        words = load_dictionary(args.dictionary)
    except (FileNotFoundError, ValueError) as error:
        parser.error(str(error))

    word_set = set(words)

    if args.target:
        target = args.target.lower()
        if target not in word_set:
            parser.error(f"Provided target '{args.target}' is not in the dictionary.")
    else:
        target = choose_target(words, args.seed)

    try:
        game = WordleGame(target=target, allowed_words=words, max_attempts=args.max_attempts)
    except ValueError as error:
        parser.error(str(error))

    if not args.quiet:
        print("Welcome to Wordle!")
        print("Guess the five-letter word within six attempts.")
        print("Feedback legend: [G]=correct spot, [Y]=misplaced, [_]=absent.")

    while not game.is_over:
        prompt = f"Attempt {game.attempts_used + 1}/{game.max_attempts} > "
        try:
            guess = input(prompt).strip().lower()
        except EOFError:
            print("\nInput terminated. Exiting game.")
            return 1
        except KeyboardInterrupt:
            print("\nGame interrupted. Goodbye.")
            return 1

        if not guess:
            print("Please enter a five-letter word.")
            continue

        if not game.is_valid_guess(guess):
            print("Invalid guess. Use a five-letter dictionary word.")
            continue

        statuses = game.apply_guess(guess)
        print(render_feedback(guess, statuses))

        if all(status is TileStatus.CORRECT for status in statuses):
            print(f"Congratulations! You solved it in {game.attempts_used} attempts.")
            return 0

    print(f"Game over. The word was {game.target.upper()}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
