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

#include "fdf.h"
#include <mlx.h>

static void	init_fdf(t_fdf *fdf, t_map *map)
{
	int	zoom;
	int	max_dim;

	fdf->map = map;
	max_dim = map->width;
	if (map->height > max_dim)
		max_dim = map->height;
	zoom = WIN_WIDTH / max_dim / 2;
	if (zoom < 1)
		zoom = 1;
	fdf->zoom = zoom;
	fdf->z_scale = 1;
	fdf->offset_x = WIN_WIDTH / 2;
	fdf->offset_y = WIN_HEIGHT / 4;
}

static void	setup_hooks(t_fdf *fdf)
{
	mlx_key_hook(fdf->win, handle_keypress, fdf);
	mlx_hook(fdf->win, 17, 0, handle_close, fdf);
}

int	main(int argc, char **argv)
{
	t_fdf	fdf;
	t_map	*map;

	if (argc != 2)
		error_exit("Usage: ./fdf <filename.fdf>");
	map = parse_map(argv[1]);
	if (!map)
		error_exit("Failed to parse map");
	fdf.mlx = mlx_init();
	if (!fdf.mlx)
		error_exit("Failed to initialize MLX");
	fdf.win = mlx_new_window(fdf.mlx, WIN_WIDTH, WIN_HEIGHT, "FDF");
	if (!fdf.win)
		error_exit("Failed to create window");
	fdf.img = mlx_new_image(fdf.mlx, WIN_WIDTH, WIN_HEIGHT);
	if (!fdf.img)
		error_exit("Failed to create image");
	fdf.addr = mlx_get_data_addr(fdf.img, &fdf.bits_per_pixel,
			&fdf.line_length, &fdf.endian);
	init_fdf(&fdf, map);
	render_map(&fdf);
	mlx_put_image_to_window(fdf.mlx, fdf.win, fdf.img, 0, 0);
	setup_hooks(&fdf);
	mlx_loop(fdf.mlx);
	return (0);
}
