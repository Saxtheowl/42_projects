#!/usr/bin/env python3
"""
Wordle - Word guessing game
Guess the 5-letter word in 6 tries
"""

import sys
import random
from typing import List, Tuple

# Common 5-letter words
WORDS = [
    "about", "above", "abuse", "actor", "acute", "admit", "adopt", "adult",
    "after", "again", "agent", "agree", "ahead", "alarm", "album", "alert",
    "alike", "alive", "allow", "alone", "along", "alter", "among", "anger",
    "angle", "angry", "apart", "apple", "apply", "arena", "argue", "arise",
    "array", "aside", "asset", "avoid", "award", "aware", "badly", "baker",
    "bases", "basic", "basis", "beach", "began", "begin", "begun", "being",
    "below", "bench", "billy", "birth", "black", "blame", "blank", "blast",
    "blind", "block", "blood", "board", "boost", "booth", "bound", "brain",
    "brand", "bread", "break", "breed", "brief", "bring", "broad", "broke",
    "brown", "build", "built", "buyer", "cable", "calif", "carry", "catch",
    "cause", "chain", "chair", "chart", "chase", "cheap", "check", "chest",
    "chief", "child", "china", "chose", "civil", "claim", "class", "clean",
    "clear", "click", "clock", "close", "coach", "coast", "could", "count",
    "court", "cover", "craft", "crash", "cream", "crime", "cross", "crowd",
    "crown", "curve", "cycle", "daily", "dance", "dated", "dealt", "death",
    "debut", "delay", "depth", "doing", "doubt", "dozen", "draft", "drama",
    "drawn", "dream", "dress", "drink", "drive", "drove", "dying", "eager",
    "early", "earth", "eight", "elite", "empty", "enemy", "enjoy", "enter",
    "entry", "equal", "error", "event", "every", "exact", "exist", "extra",
    "faith", "false", "fault", "fiber", "field", "fifth", "fifty", "fight",
    "final", "first", "fixed", "flash", "fleet", "floor", "fluid", "focus",
    "force", "forth", "found", "frame", "frank", "fraud", "fresh", "front",
    "fruit", "fully", "funny", "giant", "given", "glass", "globe", "going",
    "grace", "grade", "grain", "grand", "grant", "grass", "grave", "great",
    "green", "gross", "group", "grown", "guard", "guess", "guest", "guide",
    "happy", "harry", "heart", "heavy", "hence", "henry", "horse", "hotel",
    "house", "human", "ideal", "image", "index", "inner", "input", "issue",
    "japan", "jimmy", "joint", "jones", "judge", "juice", "known", "label",
    "large", "laser", "later", "laugh", "layer", "learn", "lease", "least",
    "leave", "legal", "level", "lewis", "light", "limit", "links", "lives",
    "local", "logic", "loose", "lower", "lucky", "lunch", "lying", "magic",
    "major", "maker", "march", "maria", "match", "maybe", "mayor", "meant",
    "media", "metal", "might", "minor", "minus", "mixed", "model", "money",
    "month", "moral", "motor", "mount", "mouse", "mouth", "movie", "music",
    "needs", "never", "newly", "night", "noise", "north", "noted", "novel",
    "nurse", "occur", "ocean", "offer", "often", "order", "other", "ought",
    "paint", "panel", "paper", "party", "peace", "peter", "phase", "phone",
    "photo", "piece", "pilot", "pitch", "place", "plain", "plane", "plant",
    "plate", "point", "pound", "power", "press", "price", "pride", "prime",
    "print", "prior", "prize", "proof", "proud", "prove", "queen", "quick",
    "quiet", "quite", "radio", "raise", "range", "rapid", "ratio", "reach",
    "ready", "refer", "right", "river", "robin", "roger", "roman", "rough",
    "round", "route", "royal", "rural", "scale", "scene", "scope", "score",
    "sense", "serve", "seven", "shall", "shape", "share", "sharp", "sheet",
    "shelf", "shell", "shift", "shirt", "shock", "shoot", "short", "shown",
    "sight", "since", "sixth", "sixty", "sized", "skill", "sleep", "slide",
    "small", "smart", "smile", "smith", "smoke", "solid", "solve", "sorry",
    "sound", "south", "space", "spare", "speak", "speed", "spend", "spent",
    "split", "spoke", "sport", "staff", "stage", "stake", "stand", "start",
    "state", "steam", "steel", "steep", "stick", "still", "stock", "stone",
    "stood", "store", "storm", "story", "strip", "stuck", "study", "stuff",
    "style", "sugar", "suite", "super", "sweet", "table", "taken", "taste",
    "taxes", "teach", "teeth", "terry", "texas", "thank", "theft", "their",
    "theme", "there", "these", "thick", "thing", "think", "third", "those",
    "three", "threw", "throw", "tight", "times", "tired", "title", "today",
    "token", "tommy", "total", "touch", "tough", "tower", "track", "trade",
    "train", "treat", "trend", "trial", "tribe", "trick", "tried", "tries",
    "truck", "truly", "trust", "truth", "twice", "under", "undue", "union",
    "unity", "until", "upper", "upset", "urban", "usage", "usual", "valid",
    "value", "video", "virus", "visit", "vital", "voice", "waste", "watch",
    "water", "wheel", "where", "which", "while", "white", "whole", "whose",
    "woman", "women", "world", "worry", "worse", "worst", "worth", "would",
    "wound", "write", "wrong", "wrote", "yield", "young", "youth", "zebra"
]

# ANSI colors
GREEN = '\033[42m'
YELLOW = '\033[43m'
GRAY = '\033[100m'
RESET = '\033[0m'
BOLD = '\033[1m'


def check_guess(guess: str, target: str) -> List[Tuple[str, str]]:
    """
    Check guess against target word.
    Returns list of (letter, color) tuples.
    """
    result = []
    target_chars = list(target)
    guess_chars = list(guess)

    # First pass: mark exact matches (green)
    for i in range(5):
        if guess_chars[i] == target_chars[i]:
            result.append((guess_chars[i], 'green'))
            target_chars[i] = None
            guess_chars[i] = None
        else:
            result.append((guess_chars[i], None))

    # Second pass: mark wrong position (yellow)
    for i in range(5):
        if result[i][1] is None and guess[i] in target_chars:
            result[i] = (guess[i], 'yellow')
            target_chars[target_chars.index(guess[i])] = None
        elif result[i][1] is None:
            result[i] = (guess[i], 'gray')

    return result


def display_result(result: List[Tuple[str, str]]):
    """Display colored result."""
    output = ""
    for letter, color in result:
        if color == 'green':
            output += f"{GREEN}{BOLD} {letter.upper()} {RESET}"
        elif color == 'yellow':
            output += f"{YELLOW}{BOLD} {letter.upper()} {RESET}"
        else:
            output += f"{GRAY}{BOLD} {letter.upper()} {RESET}"
    print(output)


def display_keyboard(guessed: dict):
    """Display keyboard with used letters."""
    rows = [
        "qwertyuiop",
        "asdfghjkl",
        "zxcvbnm"
    ]

    print("\nKeyboard:")
    for row in rows:
        line = ""
        for letter in row:
            if letter in guessed:
                color = guessed[letter]
                if color == 'green':
                    line += f"{GREEN} {letter.upper()} {RESET}"
                elif color == 'yellow':
                    line += f"{YELLOW} {letter.upper()} {RESET}"
                else:
                    line += f"{GRAY} {letter.upper()} {RESET}"
            else:
                line += f" {letter.upper()} "
        print(line)


def play_game():
    """Play one game of Wordle."""
    target = random.choice(WORDS)
    guesses = []
    guessed_letters = {}
    max_attempts = 6

    print("\n" + "=" * 40)
    print("WORDLE - Guess the 5-letter word!")
    print("=" * 40)
    print(f"You have {max_attempts} attempts.\n")

    for attempt in range(max_attempts):
        while True:
            try:
                guess = input(f"Attempt {attempt + 1}/{max_attempts}: ").strip().lower()
            except EOFError:
                print(f"\nThe word was: {target.upper()}")
                return False

            if len(guess) != 5:
                print("Please enter a 5-letter word.")
                continue
            if not guess.isalpha():
                print("Please use only letters.")
                continue
            break

        result = check_guess(guess, target)
        guesses.append((guess, result))

        # Update keyboard
        for letter, color in result:
            if letter not in guessed_letters or color == 'green':
                guessed_letters[letter] = color
            elif guessed_letters[letter] != 'green' and color == 'yellow':
                guessed_letters[letter] = color

        # Display all guesses
        print()
        for g, r in guesses:
            display_result(r)

        display_keyboard(guessed_letters)

        if guess == target:
            print(f"\n🎉 Congratulations! You got it in {attempt + 1} attempt(s)!")
            return True

    print(f"\n😔 Game over! The word was: {target.upper()}")
    return False


def play_demo():
    """Run automated demo."""
    print("Wordle Demo Mode")
    print("=" * 40)

    target = "crane"
    guesses = ["audio", "stern", "crane"]

    print(f"\nTarget word: {target.upper()} (hidden in real game)\n")

    for i, guess in enumerate(guesses):
        print(f"Guess {i + 1}: {guess.upper()}")
        result = check_guess(guess, target)
        display_result(result)
        print()

        if guess == target:
            print(f"🎉 Found in {i + 1} attempts!")
            break


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--demo':
            play_demo()
        elif sys.argv[1] == '--help':
            print("Wordle - Word Guessing Game")
            print("\nUsage:")
            print("  python wordle.py        - Play game")
            print("  python wordle.py --demo - Watch demo")
            print("\nRules:")
            print("  - Guess the 5-letter word in 6 tries")
            print("  - Green: correct letter, correct position")
            print("  - Yellow: correct letter, wrong position")
            print("  - Gray: letter not in word")
        else:
            print(f"Unknown option: {sys.argv[1]}")
    else:
        while True:
            play_game()
            try:
                again = input("\nPlay again? (y/n): ").strip().lower()
            except EOFError:
                break
            if again != 'y':
                break
        print("Thanks for playing!")


if __name__ == "__main__":
    main()
