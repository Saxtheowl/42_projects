#include "minitalk.h"

#include <stdlib.h>
#include <unistd.h>

typedef struct s_receiver
{
	unsigned char	buffer;
	int				bits;
	pid_t			client_pid;
}	t_receiver;

static void	print_banner(pid_t pid)
{
	ft_putstr_fd("Server PID: ", 1);
	ft_putnbr_fd((int)pid, 1);
	ft_putstr_fd("\n", 1);
}

static void	reset_receiver(t_receiver *receiver, pid_t client_pid)
{
	receiver->buffer = 0;
	receiver->bits = 0;
	receiver->client_pid = client_pid;
}

static void	handle_complete_char(t_receiver *receiver)
{
	if (receiver->buffer == '\0')
	{
		write(1, "\n", 1);
		if (receiver->client_pid > 0)
			kill(receiver->client_pid, SIGUSR2);
		reset_receiver(receiver, 0);
		return ;
	}
	write(1, &receiver->buffer, 1);
	receiver->buffer = 0;
	receiver->bits = 0;
}

static void	signal_handler(int signo, siginfo_t *info, void *context)
{
	static t_receiver	receiver = {0, 0, 0};

	(void)context;
	if (info->si_pid <= 0)
		return ;
	if (receiver.client_pid == 0 || receiver.client_pid != info->si_pid)
		reset_receiver(&receiver, info->si_pid);
	receiver.buffer = (receiver.buffer << 1);
	if (signo == SIGUSR2)
		receiver.buffer |= 1;
	receiver.bits++;
	if (receiver.bits == 8)
		handle_complete_char(&receiver);
	if (info->si_pid > 0)
		kill(info->si_pid, SIGUSR1);
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

int	main(void)
{
	print_banner(getpid());
	configure_signals();
	while (1)
		pause();
	return (0);
}
