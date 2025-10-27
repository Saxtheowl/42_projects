#include "minitalk.h"

#include <stdlib.h>
#include <unistd.h>

static volatile sig_atomic_t	g_ack_received = 0;
static volatile sig_atomic_t	g_message_done = 0;

static void	signal_handler(int signo, siginfo_t *info, void *context)
{
	(void)info;
	(void)context;
	if (signo == SIGUSR1)
		g_ack_received = 1;
	else if (signo == SIGUSR2)
		g_message_done = 1;
}

static void	configure_signals(void)
{
	struct sigaction	action;

	action.sa_sigaction = signal_handler;
	sigemptyset(&action.sa_mask);
	action.sa_flags = SA_SIGINFO;
	if (sigaction(SIGUSR1, &action, NULL) == -1)
	{
		ft_putstr_fd("Error: sigaction\n", 2);
		exit(EXIT_FAILURE);
	}
	if (sigaction(SIGUSR2, &action, NULL) == -1)
	{
		ft_putstr_fd("Error: sigaction\n", 2);
		exit(EXIT_FAILURE);
	}
}

static int	dispatch_signal(pid_t pid, int signal)
{
	g_ack_received = 0;
	if (kill(pid, signal) == -1)
		return (0);
	while (!g_ack_received)
		pause();
	return (1);
}

static int	send_char(pid_t pid, unsigned char c)
{
	int	bit;

	bit = 7;
	while (bit >= 0)
	{
		if ((c >> bit) & 1)
		{
			if (!dispatch_signal(pid, SIGUSR2))
				return (0);
		}
		else if (!dispatch_signal(pid, SIGUSR1))
			return (0);
		bit--;
	}
	return (1);
}

static int	send_message(pid_t pid, const char *message)
{
	size_t	index;

	index = 0;
	while (message[index] != '\0')
	{
		if (!send_char(pid, (unsigned char)message[index]))
			return (0);
		index++;
	}
	if (!send_char(pid, '\0'))
		return (0);
	return (1);
}

int	main(int argc, char **argv)
{
	pid_t	server_pid;

	if (argc != 3)
	{
		ft_putstr_fd("Usage: ./client <server_pid> <message>\n", 2);
		return (EXIT_FAILURE);
	}
	if (!parse_pid(argv[1], &server_pid))
	{
		ft_putstr_fd("Error: invalid server PID\n", 2);
		return (EXIT_FAILURE);
	}
	if (kill(server_pid, 0) == -1)
	{
		ft_putstr_fd("Error: cannot reach server\n", 2);
		return (EXIT_FAILURE);
	}
	configure_signals();
	g_message_done = 0;
	if (!send_message(server_pid, argv[2]))
	{
		ft_putstr_fd("Error: failed to send message\n", 2);
		return (EXIT_FAILURE);
	}
	while (!g_message_done)
		pause();
	return (EXIT_SUCCESS);
}
