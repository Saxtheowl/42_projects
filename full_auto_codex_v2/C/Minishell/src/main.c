#include "minishell.h"
#include <stdio.h>

int	main(int argc, char **argv, char **envp)
{
	t_ms	ms;
	int		status;

	(void)argc;
	(void)argv;
	status = ms_init(&ms, envp);
	if (status != 0)
	{
		fprintf(stderr, "minishell: initialization failed\n");
		return (status);
	}
	status = ms_run(&ms);
	ms_cleanup(&ms);
	return (status);
}
