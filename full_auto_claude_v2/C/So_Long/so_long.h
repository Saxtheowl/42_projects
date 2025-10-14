/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   so_long.h                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef SO_LONG_H
# define SO_LONG_H

# include <stdlib.h>
# include <unistd.h>
# include <fcntl.h>
# include <stdio.h>

# define TILE_SIZE 64
# define KEY_ESC 65307
# define KEY_W 119
# define KEY_A 97
# define KEY_S 115
# define KEY_D 100
# define KEY_UP 65362
# define KEY_DOWN 65364
# define KEY_LEFT 65361
# define KEY_RIGHT 65363

# define COLOR_WALL 0x2C3E50
# define COLOR_FLOOR 0xECF0F1
# define COLOR_PLAYER 0x3498DB
# define COLOR_COLLECTIBLE 0xF39C12
# define COLOR_EXIT 0x27AE60

typedef struct s_img
{
	void	*img;
	char	*addr;
	int		bits_per_pixel;
	int		line_length;
	int		endian;
	int		width;
	int		height;
}	t_img;

typedef struct s_map
{
	char	**grid;
	int		width;
	int		height;
	int		collectibles;
	int		exits;
	int		players;
	int		player_x;
	int		player_y;
	int		exit_x;
	int		exit_y;
}	t_map;

typedef struct s_game
{
	void	*mlx;
	void	*win;
	t_map	map;
	t_img	img;
	int		collected;
	int		moves;
	int		game_over;
}	t_game;

/* Map parsing and validation */
int		parse_map(char *filename, t_game *game);
int		validate_map(t_game *game);
void	free_map(t_map *map);
char	*get_next_line(int fd);

/* Game initialization */
int		init_game(t_game *game);
void	init_mlx(t_game *game);

/* Game logic */
void	move_player(t_game *game, int dx, int dy);
void	check_collectible(t_game *game);
void	check_exit(t_game *game);

/* Rendering */
void	render_game(t_game *game);
void	draw_tile(t_game *game, int x, int y, int color);
void	put_pixel(t_img *img, int x, int y, int color);

/* Event handlers */
int		handle_keypress(int keycode, t_game *game);
int		handle_close(t_game *game);

/* Utils */
int		ft_strlen(char *str);
char	*ft_strdup(char *s);
char	*ft_strchr(char *s, int c);
void	ft_putstr_fd(char *s, int fd);
void	ft_putnbr_fd(int n, int fd);
void	error_exit(char *message);

#endif
