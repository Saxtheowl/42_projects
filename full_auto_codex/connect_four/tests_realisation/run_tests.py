#!/usr/bin/env python3
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BUILD = ROOT / "build"
BIN = ROOT / "connect_four"

TEST_CPP = """
#include <cassert>
#include "Game.hpp"

int main() {
    Game game;
    // horizontal win
    game.dropToken(0);
    game.switchPlayer();
    game.dropToken(0);
    game.switchPlayer();
    game.dropToken(1);
    game.switchPlayer();
    game.dropToken(1);
    game.switchPlayer();
    game.dropToken(2);
    game.switchPlayer();
    game.dropToken(2);
    game.switchPlayer();
    game.dropToken(3);
    assert(game.checkWinner() == Game::PLAYER1);

    game.reset();
    // AI winning move should choose winning column
    game.dropToken(0); // P1
    game.switchPlayer();
    game.dropToken(1); // P2
    game.switchPlayer();
    game.dropToken(0); // P1
    game.switchPlayer();
    game.dropToken(1); // P2
    game.switchPlayer();
    game.dropToken(0); // P1
    int choice = aiChooseColumn(game);
    assert(choice == 0);
    return 0;
}
"""


def build_main():
    subprocess.run(["make"], cwd=ROOT, check=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)


def build_test():
    BUILD.mkdir(exist_ok=True)
    test_file = BUILD / "test_game.cpp"
    test_file.write_text(TEST_CPP)
    subprocess.run([
        "c++", "-std=c++98", "-Wall", "-Wextra", "-Werror",
        "-I", str(ROOT / "include"),
        str(test_file), str(ROOT / "src/Game.cpp")
    ], check=True, cwd=BUILD, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    subprocess.run(["./a.out"], check=True, cwd=BUILD, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)


def main() -> int:
    build_main()
    build_test()
    print("All tests passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
