import subprocess
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BIN_NM = ROOT / "ft_nm"
BIN_OTOOL = ROOT / "ft_otool"
FIXTURE = ROOT / "tests_realisation" / "fixtures" / "sample64.macho"


def ensure_fixture() -> None:
    from tests_realisation.create_fixture import create_fixture

    create_fixture(FIXTURE)


class NmOtoolTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        ensure_fixture()

    def test_ft_nm_output(self) -> None:
        result = subprocess.run(
            [str(BIN_NM), str(FIXTURE)],
            text=True,
            capture_output=True,
            check=False,
            cwd=ROOT,
        )
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        expected = (
            "                 U _helper\n"
            "0000000000001000 T _main\n"
        )
        self.assertEqual(result.stdout, expected)

    def test_ft_otool_output(self) -> None:
        result = subprocess.run(
            [str(BIN_OTOOL), str(FIXTURE)],
            text=True,
            capture_output=True,
            check=False,
            cwd=ROOT,
        )
        self.assertEqual(result.returncode, 0, msg=result.stderr)
        expected = (
            f"{FIXTURE}:\n"
            "Contents of (__TEXT,__text) section\n"
            "0000000000001000\t554889e5 4883ec10 488d3d12 000000c3\n"
        )
        self.assertEqual(result.stdout, expected)


if __name__ == "__main__":
    unittest.main()
