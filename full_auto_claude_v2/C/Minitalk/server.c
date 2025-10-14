/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"

typedef struct s_server
{
	unsigned char	c;
	int				bit_count;
}	t_server;

t_server	g_server = {0, 0};

void	handle_signal(int sig)
{
	if (sig == SIGUSR2)
		g_server.c |= (1 << g_server.bit_count);
	g_server.bit_count++;
	if (g_server.bit_count == 8)
	{
		ft_putchar(g_server.c);
		g_server.c = 0;
		g_server.bit_count = 0;
	}
}

int	main(void)
{
	struct sigaction	sa;

	ft_putstr("Server PID: ");
	ft_putnbr(getpid());
	ft_putchar('\n');
	sa.sa_handler = handle_signal;
	sa.sa_flags = 0;
	sigemptyset(&sa.sa_mask);
	if (sigaction(SIGUSR1, &sa, NULL) == -1)
		error_exit("sigaction failed");
	if (sigaction(SIGUSR2, &sa, NULL) == -1)
		error_exit("sigaction failed");
	while (1)
		pause();
	return (0);
}
