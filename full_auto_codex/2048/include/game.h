#ifndef GAME_H
#define GAME_H

#include <stdbool.h>

#define BOARD_SIZE 4

enum e_const
{
	WIN_VALUE = 2048
};

typedef enum e_direction
{
	DIR_UP,
	DIR_DOWN,
	DIR_LEFT,
	DIR_RIGHT
}	t_direction;

typedef struct s_game
{
	int		board[BOARD_SIZE][BOARD_SIZE];
	int		score;
	bool	won;
}	t_game;

void	game_init(t_game *game);
int		game_add_random_tile(t_game *game);
int		game_can_move(const t_game *game);
int		game_move(t_game *game, t_direction direction);
int		game_max_tile(const t_game *game);

#endif
