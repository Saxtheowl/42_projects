#ifndef GAME_HPP
#define GAME_HPP

#include <vector>
#include <string>

class Game
{
public:
    enum Cell { EMPTY, PLAYER1, PLAYER2 };

private:
    int m_rows;
    int m_cols;
    std::vector<std::vector<Cell> > m_board;
    Cell m_current;

public:
    Game(int rows = 6, int cols = 7);

    void reset();
    bool dropToken(int column);
    bool isBoardFull() const;
    Cell checkWinner() const;
    Cell currentPlayer() const;
    void switchPlayer();
    std::string boardString() const;
    int rows() const;
    int cols() const;
    Cell cellAt(int r, int c) const;
    void setCell(int r, int c, Cell value);
};

int aiChooseColumn(const Game &game);

#endif
