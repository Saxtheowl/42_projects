#include "game.h"

#include <stdlib.h>
#include <string.h>

#define TILE_TWO_WEIGHT 9

static int	slide_line(int line[BOARD_SIZE], int *score, bool *won)
{
	int		tmp[BOARD_SIZE] = {0};
	int		final_line[BOARD_SIZE] = {0};
	int		index;
	int		i;
	int		changed;

	index = 0;
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		if (line[i] != 0)
			tmp[index++] = line[i];
	}
	while (index < BOARD_SIZE)
		tmp[index++] = 0;
	changed = 0;
	for (i = 0; i < BOARD_SIZE - 1; ++i)
	{
		if (tmp[i] != 0 && tmp[i] == tmp[i + 1])
		{
			tmp[i] *= 2;
			*score += tmp[i];
			if (tmp[i] >= WIN_VALUE)
				*won = true;
			tmp[i + 1] = 0;
			changed = 1;
			++i;
		}
	}
	index = 0;
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		if (tmp[i] != 0)
			final_line[index++] = tmp[i];
	}
	while (index < BOARD_SIZE)
		final_line[index++] = 0;
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		if (line[i] != final_line[i])
			changed = 1;
		line[i] = final_line[i];
	}
	return (changed);
}

static int	process_row(t_game *game, int row, t_direction direction)
{
	int	line[BOARD_SIZE];
	int	index;
	int	changed;
	int	i;

	for (i = 0; i < BOARD_SIZE; ++i)
	{
		index = (direction == DIR_LEFT) ? i : (BOARD_SIZE - 1 - i);
		line[i] = game->board[row][index];
	}
	changed = slide_line(line, &game->score, &game->won);
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		index = (direction == DIR_LEFT) ? i : (BOARD_SIZE - 1 - i);
		game->board[row][index] = line[i];
	}
	return (changed);
}

static int	process_column(t_game *game, int column, t_direction direction)
{
	int	line[BOARD_SIZE];
	int	index;
	int	changed;
	int	i;

	for (i = 0; i < BOARD_SIZE; ++i)
	{
		index = (direction == DIR_UP) ? i : (BOARD_SIZE - 1 - i);
		line[i] = game->board[index][column];
	}
	changed = slide_line(line, &game->score, &game->won);
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		index = (direction == DIR_UP) ? i : (BOARD_SIZE - 1 - i);
		game->board[index][column] = line[i];
	}
	return (changed);
}

void	game_init(t_game *game)
{
	int	i;

	if (game == NULL)
		return ;
	memset(game->board, 0, sizeof(game->board));
	game->score = 0;
	game->won = false;
	i = 0;
	while (i < 2)
	{
		if (game_add_random_tile(game))
			++i;
		else
			break ;
	}
}

int	game_add_random_tile(t_game *game)
{
	int	positions[BOARD_SIZE * BOARD_SIZE][2];
	int	count;
	int	i;
	int	j;
	int	value;
	int	idx;

	if (game == NULL)
		return (0);
	count = 0;
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		for (j = 0; j < BOARD_SIZE; ++j)
		{
			if (game->board[i][j] == 0)
			{
				positions[count][0] = i;
				positions[count][1] = j;
				++count;
			}
		}
	}
	if (count == 0)
		return (0);
	idx = rand() % count;
	if (rand() % (TILE_TWO_WEIGHT + 1) < TILE_TWO_WEIGHT)
		value = 2;
	else
		value = 4;
	game->board[positions[idx][0]][positions[idx][1]] = value;
	return (1);
}

int	game_can_move(const t_game *game)
{
	int	i;
	int	j;

	if (game == NULL)
		return (0);
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		for (j = 0; j < BOARD_SIZE; ++j)
		{
			if (game->board[i][j] == 0)
				return (1);
			if (j + 1 < BOARD_SIZE && game->board[i][j] == game->board[i][j + 1])
				return (1);
			if (i + 1 < BOARD_SIZE && game->board[i][j] == game->board[i + 1][j])
				return (1);
		}
	}
	return (0);
}

int	game_move(t_game *game, t_direction direction)
{
	int	i;
	int	changed;

	if (game == NULL)
		return (0);
	changed = 0;
	if (direction == DIR_LEFT || direction == DIR_RIGHT)
	{
		for (i = 0; i < BOARD_SIZE; ++i)
			if (process_row(game, i, direction))
				changed = 1;
	}
	else if (direction == DIR_UP || direction == DIR_DOWN)
	{
		for (i = 0; i < BOARD_SIZE; ++i)
			if (process_column(game, i, direction))
				changed = 1;
	}
	return (changed);
}

int	game_max_tile(const t_game *game)
{
	int	max;
	int	i;
	int	j;

	if (game == NULL)
		return (0);
	max = 0;
	for (i = 0; i < BOARD_SIZE; ++i)
	{
		for (j = 0; j < BOARD_SIZE; ++j)
		{
			if (game->board[i][j] > max)
				max = game->board[i][j];
		}
	}
	return (max);
}
