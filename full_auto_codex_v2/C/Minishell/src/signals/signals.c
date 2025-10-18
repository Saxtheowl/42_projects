#include "minishell.h"
#include <signal.h>
#include <unistd.h>

static volatile sig_atomic_t	g_sigint_flag = 0;

static void	sigint_interactive(int signo)
{
	(void)signo;
	g_sigint_flag = 1;
	write(STDOUT_FILENO, "\n", 1);
	rl_on_new_line();
	rl_replace_line("", 0);
	rl_redisplay();
}

void	ms_configure_signals_interactive(void)
{
	g_sigint_flag = 0;
	signal(SIGINT, sigint_interactive);
	(void)signal(SIGQUIT, SIG_IGN);
}

void	ms_configure_signals_child(void)
{
	(void)signal(SIGINT, SIG_DFL);
	(void)signal(SIGQUIT, SIG_DFL);
}

int	ms_signals_consume_sigint(void)
{
	int	flag;

	flag = g_sigint_flag;
	g_sigint_flag = 0;
	return (flag);
}
