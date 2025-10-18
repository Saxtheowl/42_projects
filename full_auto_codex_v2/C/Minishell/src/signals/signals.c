#include "minishell.h"
#include <signal.h>
#include <unistd.h>

static void	sigint_interactive(int signo)
{
	(void)signo;
	write(STDOUT_FILENO, "\n", 1);
	rl_on_new_line();
	rl_replace_line("", 0);
	rl_redisplay();
}

void	ms_configure_signals_interactive(void)
{
	signal(SIGINT, sigint_interactive);
	(void)signal(SIGQUIT, SIG_IGN);
}

void	ms_configure_signals_child(void)
{
	(void)signal(SIGINT, SIG_DFL);
	(void)signal(SIGQUIT, SIG_DFL);
}
