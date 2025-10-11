#include "game.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void	fail(const char *message)
{
	fprintf(stderr, "Test failure: %s\n", message);
	exit(EXIT_FAILURE);
}

static void	test_initial_tiles(void)
{
	t_game	game;
	int		count;
	int		i;
	int		j;

	srand(0);
	game_init(&game);
	count = 0;
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		for (j = 0; j < BOARD_SIZE; ++j)
		{
			if (game.board[i][j] != 0)
			{
				if (game.board[i][j] != 2 && game.board[i][j] != 4)
					fail("initial tiles must be 2 or 4");
				++count;
			}
		}
	}
	if (count != 2)
		fail("initial board must contain exactly two tiles");
}

static void	test_merge_left(void)
{
	t_game	game;

	memset(&game, 0, sizeof(game));
	game.board[0][0] = 2;
	game.board[0][1] = 2;
	if (!game_move(&game, DIR_LEFT))
		fail("expected a successful move to the left");
	if (game.board[0][0] != 4 || game.board[0][1] != 0)
		fail("left merge produced unexpected board state");
	if (game.score != 4)
		fail("score was not updated after merge");
}

static void	test_no_move_when_blocked(void)
{
	t_game	game;
	int		values[BOARD_SIZE][BOARD_SIZE] = {
		{2, 4, 8, 16},
		{32, 64, 128, 256},
		{512, 1024, 2, 4},
		{8, 16, 32, 64}
	};
	int		i;
	int		j;

	memset(&game, 0, sizeof(game));
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		for (j = 0; j < BOARD_SIZE; ++j)
			game.board[i][j] = values[i][j];
	}
	if (game_can_move(&game))
		fail("board incorrectly marked as having valid moves");
	if (game_move(&game, DIR_LEFT))
		fail("blocked board should not move");
}

static void	test_win_flag(void)
{
	t_game	game;

	memset(&game, 0, sizeof(game));
	game.board[0][0] = WIN_VALUE / 2;
	game.board[0][1] = WIN_VALUE / 2;
	if (!game_move(&game, DIR_LEFT))
		fail("expected merge to happen");
	if (game.board[0][0] != WIN_VALUE)
		fail("merge should produce the winning tile");
	if (!game.won)
		fail("winning tile should set the win flag");
}

int	main(void)
{
	test_initial_tiles();
	test_merge_left();
	test_no_move_when_blocked();
	test_win_flag();
	return (0);
}
