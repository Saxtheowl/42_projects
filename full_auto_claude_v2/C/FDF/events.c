/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   events.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fdf.h"

int	handle_close(t_fdf *fdf)
{
	free_map(fdf->map);
	exit(0);
	return (0);
}

int	handle_keypress(int keycode, t_fdf *fdf)
{
	if (keycode == KEY_ESC)
	{
		free_map(fdf->map);
		exit(0);
	}
	return (0);
}
