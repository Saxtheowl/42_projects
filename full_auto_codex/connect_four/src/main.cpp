#include "Game.hpp"

#include <cstdlib>
#include <iostream>
#include <string>

static bool askYesNo(const std::string &prompt)
{
    while (true)
    {
        std::cout << prompt << " (y/n): ";
        std::string line;
        if (!std::getline(std::cin, line))
            return false;
        if (line == "y" || line == "Y")
            return true;
        if (line == "n" || line == "N")
            return false;
        std::cout << "Please answer y or n." << std::endl;
    }
}

int main()
{
    std::cout << "=== Connect Four ===" << std::endl;
    bool vsAI = askYesNo("Play against computer?");

    Game game;
    bool running = true;
    while (running)
    {
        std::cout << game.boardString();
        Game::Cell winner = game.checkWinner();
        if (winner != Game::EMPTY)
        {
            std::cout << ((winner == Game::PLAYER1) ? "Player 1" : "Player 2") << " wins!" << std::endl;
            if (!askYesNo("Play again?"))
                running = false;
            else
                game.reset();
            continue;
        }
        if (game.isBoardFull())
        {
            std::cout << "It's a draw!" << std::endl;
            if (!askYesNo("Play again?"))
                running = false;
            else
                game.reset();
            continue;
        }

        int column = -1;
        if (vsAI && game.currentPlayer() == Game::PLAYER2)
        {
            column = aiChooseColumn(game);
            std::cout << "Computer chooses column " << column << std::endl;
        }
        else
        {
            std::cout << ((game.currentPlayer() == Game::PLAYER1) ? "Player 1" : "Player 2")
                      << ", choose column: ";
            std::string line;
            if (!std::getline(std::cin, line))
                break;
            column = std::atoi(line.c_str());
        }

        if (!game.dropToken(column))
        {
            std::cout << "Invalid move. Try again." << std::endl;
            continue;
        }
        game.switchPlayer();
    }
    std::cout << "Thanks for playing!" << std::endl;
    return 0;
}
