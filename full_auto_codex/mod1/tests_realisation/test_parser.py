import unittest
from pathlib import Path

from src.parser import load_control_points


class ParserTests(unittest.TestCase):
	def test_load_control_points(self):
		points = load_control_points(Path("resources") / "example.mod1")
		self.assertEqual(len(points), 4)
		self.assertAlmostEqual(points[0][0], 0.0)
		self.assertAlmostEqual(points[3][2], 10.0)


if __name__ == "__main__":
	unittest.main()
