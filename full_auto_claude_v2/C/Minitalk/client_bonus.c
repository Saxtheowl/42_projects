/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client_bonus.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk_bonus.h"

int	g_received = 0;

void	handle_ack(int sig)
{
	if (sig == SIGUSR1)
	{
		ft_putstr("Message received by server!\n");
		exit(EXIT_SUCCESS);
	}
	else if (sig == SIGUSR2)
		g_received = 1;
}

void	send_char(int pid, unsigned char c)
{
	int	bit;

	bit = 0;
	while (bit < 8)
	{
		g_received = 0;
		if (c & (1 << bit))
		{
			if (kill(pid, SIGUSR2) == -1)
				error_exit("kill failed");
		}
		else
		{
			if (kill(pid, SIGUSR1) == -1)
				error_exit("kill failed");
		}
		while (!g_received)
			usleep(10);
		bit++;
	}
}

void	send_string(int pid, char *str)
{
	int	i;

	i = 0;
	while (str[i])
	{
		send_char(pid, str[i]);
		i++;
	}
	send_char(pid, '\0');
}

int	main(int argc, char **argv)
{
	int					pid;
	struct sigaction	sa;

	if (argc != 3)
	{
		ft_putstr("Usage: ./client <server_pid> <message>\n");
		exit(EXIT_FAILURE);
	}
	pid = ft_atoi(argv[1]);
	if (pid <= 0)
		error_exit("Invalid PID");
	sa.sa_handler = handle_ack;
	sa.sa_flags = 0;
	sigemptyset(&sa.sa_mask);
	if (sigaction(SIGUSR1, &sa, NULL) == -1)
		error_exit("sigaction failed");
	if (sigaction(SIGUSR2, &sa, NULL) == -1)
		error_exit("sigaction failed");
	send_string(pid, argv[2]);
	while (1)
		pause();
	return (0);
}
