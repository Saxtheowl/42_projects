/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "fractol.h"

void	error_exit(char *message)
{
	ft_putstr_fd("Error: ", 2);
	ft_putstr_fd(message, 2);
	ft_putstr_fd("\n", 2);
	exit(1);
}

void	ft_putstr_fd(char *s, int fd)
{
	int	i;

	if (!s)
		return ;
	i = 0;
	while (s[i])
	{
		write(fd, &s[i], 1);
		i++;
	}
}

int	ft_strcmp(char *s1, char *s2)
{
	int	i;

	i = 0;
	while (s1[i] && s2[i] && s1[i] == s2[i])
		i++;
	return ((unsigned char)s1[i] - (unsigned char)s2[i]);
}

double	ft_atof(char *str)
{
	double	result;
	double	fraction;
	int		sign;
	int		i;

	result = 0.0;
	fraction = 0.1;
	sign = 1;
	i = 0;
	while (str[i] == ' ' || (str[i] >= 9 && str[i] <= 13))
		i++;
	if (str[i] == '-' || str[i] == '+')
	{
		if (str[i] == '-')
			sign = -1;
		i++;
	}
	while (str[i] >= '0' && str[i] <= '9')
		result = result * 10 + (str[i++] - '0');
	if (str[i] == '.')
	{
		i++;
		while (str[i] >= '0' && str[i] <= '9')
		{
			result += (str[i++] - '0') * fraction;
			fraction *= 0.1;
		}
	}
	return (result * sign);
}

void	print_usage(void)
{
	ft_putstr_fd("Usage: ./fractol <fractal_type> [parameters]\n\n", 1);
	ft_putstr_fd("Available fractals:\n", 1);
	ft_putstr_fd("  mandelbrot  - Mandelbrot set\n", 1);
	ft_putstr_fd("  julia <r> <i> - Julia set with complex parameter\n", 1);
	ft_putstr_fd("                  Example: ./fractol julia -0.7 0.27015\n", 1);
	ft_putstr_fd("  burning_ship - Burning Ship fractal\n\n", 1);
	ft_putstr_fd("Controls:\n", 1);
	ft_putstr_fd("  Mouse wheel - Zoom in/out\n", 1);
	ft_putstr_fd("  Arrow keys  - Move view\n", 1);
	ft_putstr_fd("  +/-         - Increase/decrease iterations\n", 1);
	ft_putstr_fd("  C           - Shift colors\n", 1);
	ft_putstr_fd("  ESC         - Exit\n", 1);
}
