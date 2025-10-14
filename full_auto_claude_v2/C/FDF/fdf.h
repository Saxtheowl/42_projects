/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   fdf.h                                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FDF_H
# define FDF_H

# include <stdlib.h>
# include <unistd.h>
# include <fcntl.h>
# include <math.h>
# include <stdio.h>

# define WIN_WIDTH 1920
# define WIN_HEIGHT 1080
# define KEY_ESC 65307

typedef struct s_point
{
	int	x;
	int	y;
	int	z;
	int	color;
}	t_point;

typedef struct s_map
{
	int			width;
	int			height;
	t_point		**points;
}	t_map;

typedef struct s_fdf
{
	void	*mlx;
	void	*win;
	void	*img;
	char	*addr;
	int		bits_per_pixel;
	int		line_length;
	int		endian;
	t_map	*map;
	int		zoom;
	int		offset_x;
	int		offset_y;
	int		z_scale;
}	t_fdf;

/* Parsing */
t_map	*parse_map(char *filename);
void	free_map(t_map *map);
char	*get_next_line(int fd);
char	**ft_split(char const *s, char c);
int		ft_atoi(const char *str);

/* Drawing */
void	draw_line(t_fdf *fdf, t_point p1, t_point p2);
void	put_pixel(t_fdf *fdf, int x, int y, int color);
void	render_map(t_fdf *fdf);

/* Projection */
t_point	project(t_point p, t_fdf *fdf);
t_point	isometric(t_point p, int z_scale);

/* Utils */
void	error_exit(char *message);
int		ft_strlen(char *str);
void	ft_putstr_fd(char *s, int fd);

/* Events */
int		handle_keypress(int keycode, t_fdf *fdf);
int		handle_close(t_fdf *fdf);

#endif
