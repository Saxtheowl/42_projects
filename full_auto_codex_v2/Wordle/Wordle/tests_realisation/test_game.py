import subprocess
import sys
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

    def test_feedback_renderer(self) -> None:
        game = WordleGame(target="stone", allowed_words=self.words)
        statuses = game.evaluate_guess("scale")
        feedback = render_feedback("scale", statuses)
        self.assertEqual(feedback, "SCALE [G] [_] [_] [_] [G]")


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


if __name__ == "__main__":
    unittest.main()
