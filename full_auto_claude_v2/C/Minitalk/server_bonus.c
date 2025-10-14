/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server_bonus.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk_bonus.h"

typedef struct s_server
{
	unsigned char	c;
	int				bit_count;
}	t_server;

t_server	g_server = {0, 0};

void	handle_signal(int sig, siginfo_t *info, void *context)
{
	(void)context;
	if (sig == SIGUSR2)
		g_server.c |= (1 << g_server.bit_count);
	g_server.bit_count++;
	if (g_server.bit_count == 8)
	{
		if (g_server.c == '\0')
		{
			ft_putchar('\n');
			kill(info->si_pid, SIGUSR1);
		}
		else
			ft_putchar(g_server.c);
		g_server.c = 0;
		g_server.bit_count = 0;
	}
	kill(info->si_pid, SIGUSR2);
}

int	main(void)
{
	struct sigaction	sa;

	ft_putstr("Server PID: ");
	ft_putnbr(getpid());
	ft_putchar('\n');
	sa.sa_sigaction = handle_signal;
	sa.sa_flags = SA_SIGINFO;
	sigemptyset(&sa.sa_mask);
	if (sigaction(SIGUSR1, &sa, NULL) == -1)
		error_exit("sigaction failed");
	if (sigaction(SIGUSR2, &sa, NULL) == -1)
		error_exit("sigaction failed");
	while (1)
		pause();
	return (0);
}
