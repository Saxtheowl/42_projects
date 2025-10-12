
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
