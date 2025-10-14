/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fractol.h"
#include <mlx.h>

static int	parse_fractal_type(char *arg)
{
	if (ft_strcmp(arg, "mandelbrot") == 0)
		return (MANDELBROT);
	else if (ft_strcmp(arg, "julia") == 0)
		return (JULIA);
	else if (ft_strcmp(arg, "burning_ship") == 0)
		return (BURNING_SHIP);
	return (0);
}

static void	setup_hooks(t_fractol *f)
{
	mlx_key_hook(f->win, key_press, f);
	mlx_mouse_hook(f->win, mouse_press, f);
	mlx_hook(f->win, 17, 0, close_window, f);
}

static void	validate_args(int argc, char **argv, int *type)
{
	*type = parse_fractal_type(argv[1]);
	if (*type == 0)
	{
		print_usage();
		exit(1);
	}
	if (*type == JULIA && argc != 4)
	{
		ft_putstr_fd("Error: Julia set requires 2 parameters (r and i)\n", 2);
		print_usage();
		exit(1);
	}
}

int	main(int argc, char **argv)
{
	t_fractol	f;
	int			type;

	if (argc < 2)
	{
		print_usage();
		return (1);
	}
	validate_args(argc, argv, &type);
	f.mlx = mlx_init();
	if (!f.mlx)
		error_exit("Failed to initialize MLX");
	f.win = mlx_new_window(f.mlx, WIDTH, HEIGHT, "fract'ol");
	if (!f.win)
		error_exit("Failed to create window");
	f.img = mlx_new_image(f.mlx, WIDTH, HEIGHT);
	if (!f.img)
		error_exit("Failed to create image");
	f.addr = mlx_get_data_addr(f.img, &f.bits_per_pixel,
			&f.line_length, &f.endian);
	init_fractol(&f, type);
	if (type == JULIA)
		init_julia(&f, ft_atof(argv[2]), ft_atof(argv[3]));
	render_fractal(&f);
	mlx_put_image_to_window(f.mlx, f.win, f.img, 0, 0);
	setup_hooks(&f);
	mlx_loop(f.mlx);
	return (0);
}
