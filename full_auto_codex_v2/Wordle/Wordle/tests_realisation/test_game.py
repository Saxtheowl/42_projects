import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(PROJECT_ROOT))

from wordle import (  # noqa: E402  # pylint: disable=wrong-import-position
    TileStatus,
    WordleGame,
    load_dictionary,
    render_feedback,
)
from wordle.cli import choose_target  # noqa: E402  # pylint: disable=wrong-import-position


class WordleGameTests(unittest.TestCase):
    def setUp(self) -> None:
        self.words = load_dictionary(PROJECT_ROOT / "data" / "allowed_words.txt")

    def test_exact_match(self) -> None:
        game = WordleGame(target="crane", allowed_words=self.words)
        statuses = game.evaluate_guess("crane")
        self.assertTrue(all(status is TileStatus.CORRECT for status in statuses))

    def test_duplicate_letters_handled_correctly(self) -> None:
        game = WordleGame(target="array", allowed_words=self.words)
        statuses = game.evaluate_guess("allay")
        expected = [
            TileStatus.CORRECT,
            TileStatus.ABSENT,
            TileStatus.ABSENT,
            TileStatus.CORRECT,
            TileStatus.CORRECT,
        ]
        self.assertEqual(statuses, expected)

    def test_invalid_guess_rejected(self) -> None:
        game = WordleGame(target="crane", allowed_words=self.words)
        with self.assertRaises(ValueError):
            game.apply_guess("wrong")  # Not in dictionary

    def test_invalid_guess_length(self) -> None:
        game = WordleGame(target="crane", allowed_words=self.words)
        with self.assertRaises(ValueError):
            game.evaluate_guess("toolong")
        with self.assertRaises(ValueError):
            game.evaluate_guess("four")

    def test_invalid_guess_characters(self) -> None:
        game = WordleGame(target="crane", allowed_words=self.words)
        with self.assertRaises(ValueError):
            game.evaluate_guess("cr4ne")

    def test_target_added_to_dictionary(self) -> None:
        game = WordleGame(target="crane", allowed_words=["apple"])
        self.assertTrue(game.is_valid_guess("crane"))

    def test_invalid_max_attempts_rejected(self) -> None:
        with self.assertRaises(ValueError):
            WordleGame(target="crane", allowed_words=self.words, max_attempts=0)

    def test_is_valid_guess_case_insensitive(self) -> None:
        game = WordleGame(target="crane", allowed_words=["crane"])
        self.assertTrue(game.is_valid_guess("CRANE"))

    def test_game_over_after_max_attempts(self) -> None:
        game = WordleGame(target="crane", allowed_words=["crane", "apple"], max_attempts=1)
        game.apply_guess("apple")
        self.assertTrue(game.is_over)
        self.assertFalse(game.has_won)

    def test_is_valid_guess_rejects_unknown_word(self) -> None:
        game = WordleGame(target="crane", allowed_words=["crane", "apple"])
        self.assertFalse(game.is_valid_guess("delta"))

    def test_feedback_renderer(self) -> None:
        game = WordleGame(target="stone", allowed_words=self.words)
        statuses = game.evaluate_guess("scale")
        feedback = render_feedback("scale", statuses)
        self.assertEqual(feedback, "SCALE [G] [_] [_] [_] [G]")

    def test_attempt_tracking(self) -> None:
        game = WordleGame(target="crane", allowed_words=self.words, max_attempts=2)
        self.assertEqual(game.attempts_remaining, 2)
        game.apply_guess("crane")
        self.assertEqual(game.attempts_used, 1)
        self.assertTrue(game.has_won)
        self.assertTrue(game.is_over)

    def test_apply_guess_after_game_over(self) -> None:
        game = WordleGame(target="crane", allowed_words=self.words, max_attempts=1)
        game.apply_guess("crane")
        with self.assertRaises(RuntimeError):
            game.apply_guess("crane")

    def test_choose_target_deterministic(self) -> None:
        words = ["alpha", "bravo", "charlie", "delta"]
        first = choose_target(words, seed=42)
        second = choose_target(words, seed=42)
        self.assertEqual(first, second)

    def test_load_dictionary_invalid_entry(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            bad_path = Path(tmpdir) / "bad_words.txt"
            bad_path.write_text("abc\nwrong1\n", encoding="utf-8")
            with self.assertRaises(ValueError):
                load_dictionary(bad_path)

    def test_load_dictionary_missing_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            missing_path = Path(tmpdir) / "missing_words.txt"
            with self.assertRaises(FileNotFoundError):
                load_dictionary(missing_path)


class WordleCliTests(unittest.TestCase):
    def test_cli_winning_flow(self) -> None:
        command = [
            sys.executable,
            str(PROJECT_ROOT / "play.py"),
            "--target",
            "crane",
            "--dictionary",
            str(PROJECT_ROOT / "data" / "allowed_words.txt"),
            "--quiet",
        ]
        result = subprocess.run(
            command,
            input="apple\ncrane\n",
            text=True,
            capture_output=True,
            check=False,
            cwd=PROJECT_ROOT,
        )
        self.assertEqual(result.returncode, 0, msg=result.stdout + result.stderr)
        self.assertIn("APPLE", result.stdout)
        self.assertIn("CRANE", result.stdout)
        self.assertIn("Congratulations!", result.stdout)

    def test_cli_losing_flow(self) -> None:
        command = [
            sys.executable,
            str(PROJECT_ROOT / "play.py"),
            "--target",
            "crane",
            "--dictionary",
            str(PROJECT_ROOT / "data" / "allowed_words.txt"),
            "--max-attempts",
            "1",
            "--quiet",
        ]
        result = subprocess.run(
            command,
            input="apple\n",
            text=True,
            capture_output=True,
            check=False,
            cwd=PROJECT_ROOT,
        )
        self.assertEqual(result.returncode, 0, msg=result.stdout + result.stderr)
        self.assertIn("APPLE", result.stdout)
        self.assertIn("Game over. The word was CRANE.", result.stdout)

    def test_cli_invalid_input_prompt(self) -> None:
        command = [
            sys.executable,
            str(PROJECT_ROOT / "play.py"),
            "--target",
            "crane",
            "--dictionary",
            str(PROJECT_ROOT / "data" / "allowed_words.txt"),
            "--quiet",
        ]
        result = subprocess.run(
            command,
            input="\ncrane\n",
            text=True,
            capture_output=True,
            check=False,
            cwd=PROJECT_ROOT,
        )
        self.assertEqual(result.returncode, 0, msg=result.stdout + result.stderr)
        self.assertIn("Please enter a five-letter word.", result.stdout)
        self.assertIn("CRANE", result.stdout)

    def test_cli_invalid_word_rejected(self) -> None:
        command = [
            sys.executable,
            str(PROJECT_ROOT / "play.py"),
            "--target",
            "crane",
            "--dictionary",
            str(PROJECT_ROOT / "data" / "allowed_words.txt"),
            "--quiet",
        ]
        result = subprocess.run(
            command,
            input="wrong\ncrane\n",
            text=True,
            capture_output=True,
            check=False,
            cwd=PROJECT_ROOT,
        )
        self.assertEqual(result.returncode, 0, msg=result.stdout + result.stderr)
        self.assertIn("Invalid guess. Use a five-letter dictionary word.", result.stdout)
        self.assertIn("CRANE", result.stdout)


if __name__ == "__main__":
    unittest.main()
