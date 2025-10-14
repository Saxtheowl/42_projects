/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   fractol.h                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FRACTOL_H
# define FRACTOL_H

# include <stdlib.h>
# include <stdio.h>
# include <unistd.h>
# include <math.h>

# define WIDTH 800
# define HEIGHT 600
# define MAX_ITER 100

# define KEY_ESC 65307
# define KEY_LEFT 65361
# define KEY_RIGHT 65363
# define KEY_UP 65362
# define KEY_DOWN 65364
# define KEY_PLUS 61
# define KEY_MINUS 45
# define KEY_C 99

# define MOUSE_SCROLL_UP 4
# define MOUSE_SCROLL_DOWN 5

# define MANDELBROT 1
# define JULIA 2
# define BURNING_SHIP 3

typedef struct s_complex
{
	double	r;
	double	i;
}	t_complex;

typedef struct s_fractol
{
	void		*mlx;
	void		*win;
	void		*img;
	char		*addr;
	int			bits_per_pixel;
	int			line_length;
	int			endian;
	int			fractal_type;
	double		min_r;
	double		max_r;
	double		min_i;
	double		max_i;
	int			max_iterations;
	t_complex	julia_c;
	int			color_shift;
}	t_fractol;

/* Initialization */
void		init_fractol(t_fractol *f, int type);
void		init_julia(t_fractol *f, double r, double i);

/* Fractals */
int			mandelbrot(t_complex c, int max_iter);
int			julia(t_complex z, t_complex c, int max_iter);
int			burning_ship(t_complex c, int max_iter);

/* Rendering */
void		render_fractal(t_fractol *f);
int			get_color(int iteration, int max_iter, int shift);
void		put_pixel(t_fractol *f, int x, int y, int color);

/* Events */
int			key_press(int keycode, t_fractol *f);
int			mouse_press(int button, int x, int y, t_fractol *f);
int			close_window(t_fractol *f);

/* Utils */
void		error_exit(char *message);
double		ft_atof(char *str);
int			ft_strcmp(char *s1, char *s2);
void		ft_putstr_fd(char *s, int fd);
void		print_usage(void);

/* Math */
t_complex	complex_add(t_complex a, t_complex b);
t_complex	complex_mul(t_complex a, t_complex b);
t_complex	complex_square(t_complex z);
double		complex_abs(t_complex z);

#endif
