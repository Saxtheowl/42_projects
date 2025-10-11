#include <ncurses.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#include "game.h"

#define MIN_REQUIRED_HEIGHT 15
#define MIN_REQUIRED_WIDTH 45
#define CELL_WIDTH 7

static void	init_terminal(void)
{
	initscr();
	if (has_colors())
	{
		start_color();
		use_default_colors();
		init_pair(1, COLOR_CYAN, -1);
		init_pair(2, COLOR_GREEN, -1);
		init_pair(3, COLOR_YELLOW, -1);
		init_pair(4, COLOR_MAGENTA, -1);
		init_pair(5, COLOR_RED, -1);
		init_pair(6, COLOR_WHITE, -1);
	}
	cbreak();
	noecho();
	keypad(stdscr, TRUE);
	curs_set(0);
	timeout(-1);
}

static int	select_color(int value)
{
	if (!has_colors() || value == 0)
		return (0);
	if (value <= 4)
		return (1);
	if (value <= 16)
		return (2);
	if (value <= 64)
		return (3);
	if (value <= 256)
		return (4);
	if (value <= 1024)
		return (5);
	return (6);
}

static void	draw_cell(int y, int x, int value)
{
	char	buffer[CELL_WIDTH + 1];
	int		color;

	if (value == 0)
		memset(buffer, ' ', CELL_WIDTH);
	else
		snprintf(buffer, sizeof(buffer), "%*d", CELL_WIDTH, value);
	buffer[CELL_WIDTH] = '\0';
	color = select_color(value);
	if (color > 0)
		attron(COLOR_PAIR(color));
	mvprintw(y, x, "%s", buffer);
	if (color > 0)
		attroff(COLOR_PAIR(color));
}

static void	draw_separator(int y, int start_x)
{
	int	col;

	mvaddch(y, start_x, '+');
	for (col = 0; col < BOARD_SIZE; ++col)
	{
		mvhline(y, start_x + 1 + col * (CELL_WIDTH + 1), '-', CELL_WIDTH);
		mvaddch(y, start_x + (col + 1) * (CELL_WIDTH + 1), '+');
	}
}

static void	draw_row(const t_game *game, int row, int y, int start_x)
{
	int	col;

	mvaddch(y, start_x, '|');
	for (col = 0; col < BOARD_SIZE; ++col)
	{
		draw_cell(y, start_x + 1 + col * (CELL_WIDTH + 1),
			game->board[row][col]);
		mvaddch(y, start_x + (col + 1) * (CELL_WIDTH + 1), '|');
	}
}

static void	draw_board(const t_game *game, int start_y, int start_x)
{
	int	row;

	for (row = 0; row <= BOARD_SIZE; ++row)
	{
		if (row > 0)
			draw_row(game, row - 1, start_y + row * 2 - 1, start_x);
		draw_separator(start_y + row * 2, start_x);
	}
}

static void	render(const t_game *game, bool no_more_moves)
{
	int	max_y;
	int	max_x;
	int	board_width;
	int	board_height;
	int	start_y;
	int	start_x;

	getmaxyx(stdscr, max_y, max_x);
	erase();
	if (max_y < MIN_REQUIRED_HEIGHT || max_x < MIN_REQUIRED_WIDTH)
	{
		mvprintw(0, 0, "Increase the terminal size to play 2048.");
		refresh();
		return ;
	}
	mvprintw(0, (max_x - 4) / 2, "2048");
	mvprintw(2, 2, "Score: %d", game->score);
	mvprintw(3, 2, "Max tile: %d", game_max_tile(game));
	mvprintw(5, 2, "Use arrow keys to move. ESC or q to quit.");
	if (game->won)
		mvprintw(7, 2, "Congratulations! You reached %d.", WIN_VALUE);
	if (no_more_moves)
		mvprintw(8, 2, "No more moves available.");
	board_width = BOARD_SIZE * (CELL_WIDTH + 1) + 1;
	board_height = BOARD_SIZE * 2 + 1;
	start_y = (max_y - board_height) / 2;
	if (start_y < 10)
		start_y = 10;
	start_x = (max_x - board_width) / 2;
	draw_board(game, start_y, start_x);
	if (no_more_moves)
		mvprintw(start_y + board_height + 2, (max_x - 32) / 2,
			"Press ESC or q to leave the game.");
	refresh();
}

static int	handle_input(int key, t_game *game)
{
	if (key == KEY_UP)
		return (game_move(game, DIR_UP));
	if (key == KEY_DOWN)
		return (game_move(game, DIR_DOWN));
	if (key == KEY_LEFT)
		return (game_move(game, DIR_LEFT));
	if (key == KEY_RIGHT)
		return (game_move(game, DIR_RIGHT));
	return (0);
}

int	main(void)
{
	t_game	game;
	int		key;

	srand((unsigned int)time(NULL));
	game_init(&game);
	init_terminal();
	while (1)
	{
		int	can_move;

		can_move = game_can_move(&game);
		render(&game, !can_move);
		if (!can_move)
		{
			key = getch();
			if (key == 'r' || key == 'R')
			{
				game_init(&game);
				continue ;
			}
			break ;
		}
		key = getch();
		if (key == 27 || key == 'q' || key == 'Q')
			break ;
		if (key == KEY_RESIZE)
			continue ;
		if (handle_input(key, &game))
			game_add_random_tile(&game);
	}
	endwin();
	return (0);
}
