#include "Game.hpp"

#include <sstream>

Game::Game(int rows, int cols)
    : m_rows(rows), m_cols(cols), m_board(rows, std::vector<Cell>(cols, EMPTY)), m_current(PLAYER1)
{
}

void Game::reset()
{
    for (int r = 0; r < m_rows; ++r)
        for (int c = 0; c < m_cols; ++c)
            m_board[r][c] = EMPTY;
    m_current = PLAYER1;
}

bool Game::dropToken(int column)
{
    if (column < 0 || column >= m_cols)
        return false;
    for (int r = m_rows - 1; r >= 0; --r)
    {
        if (m_board[r][column] == EMPTY)
        {
            m_board[r][column] = m_current;
            return true;
        }
    }
    return false;
}

bool Game::isBoardFull() const
{
    for (int r = 0; r < m_rows; ++r)
        for (int c = 0; c < m_cols; ++c)
            if (m_board[r][c] == EMPTY)
                return false;
    return true;
}

Game::Cell Game::checkWinner() const
{
    const int directions[4][2] = {
        {0, 1},  // horizontal
        {1, 0},  // vertical
        {1, 1},  // diagonal down-right
        {1, -1}  // diagonal down-left
    };

    for (int r = 0; r < m_rows; ++r)
    {
        for (int c = 0; c < m_cols; ++c)
        {
            if (m_board[r][c] == EMPTY)
                continue;
            for (int d = 0; d < 4; ++d)
            {
                int dr = directions[d][0];
                int dc = directions[d][1];
                int count = 0;
                int rr = r;
                int cc = c;
                while (rr >= 0 && rr < m_rows && cc >= 0 && cc < m_cols && m_board[rr][cc] == m_board[r][c])
                {
                    ++count;
                    if (count == 4)
                        return m_board[r][c];
                    rr += dr;
                    cc += dc;
                }
            }
        }
    }
    return EMPTY;
}

Game::Cell Game::currentPlayer() const
{
    return m_current;
}

void Game::switchPlayer()
{
    m_current = (m_current == PLAYER1) ? PLAYER2 : PLAYER1;
}

std::string Game::boardString() const
{
    std::ostringstream oss;
    for (int r = 0; r < m_rows; ++r)
    {
        oss << "|";
        for (int c = 0; c < m_cols; ++c)
        {
            char ch = ' ';
            if (m_board[r][c] == PLAYER1)
                ch = 'X';
            else if (m_board[r][c] == PLAYER2)
                ch = 'O';
            oss << ch << "|";
        }
        oss << "\n";
    }
    oss << " ";
    for (int c = 0; c < m_cols; ++c)
        oss << c << " ";
    oss << "\n";
    return oss.str();
}

int Game::rows() const
{
    return m_rows;
}

int Game::cols() const
{
    return m_cols;
}

Game::Cell Game::cellAt(int r, int c) const
{
    return m_board[r][c];
}

void Game::setCell(int r, int c, Cell value)
{
    m_board[r][c] = value;
}

static int lowestAvailableRow(const Game &game, int column)
{
    for (int r = game.rows() - 1; r >= 0; --r)
    {
        if (game.cellAt(r, column) == Game::EMPTY)
            return r;
    }
    return -1;
}

static bool winningMove(Game game, int column)
{
    int row = lowestAvailableRow(game, column);
    if (row < 0)
        return false;
    game.setCell(row, column, game.currentPlayer());
    return game.checkWinner() == game.currentPlayer();
}

int aiChooseColumn(const Game &game)
{
    // Winning move
    for (int c = 0; c < game.cols(); ++c)
    {
        Game copy = game;
        if (winningMove(copy, c))
            return c;
    }

    // Block opponent
    Game switched = game;
    switched.switchPlayer();
    for (int c = 0; c < game.cols(); ++c)
    {
        Game copy = switched;
        if (winningMove(copy, c))
            return c;
    }

    // Prefer center
    int center = game.cols() / 2;
    if (lowestAvailableRow(game, center) >= 0)
        return center;

    // Fallback to first available
    for (int c = 0; c < game.cols(); ++c)
        if (lowestAvailableRow(game, c) >= 0)
            return c;
    return 0;
}
