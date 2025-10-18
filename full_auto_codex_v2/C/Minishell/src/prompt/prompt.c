#include "minishell.h"

char	*ms_readline(t_ms *ms)
{
	const char	*prompt;

	prompt = "minishell$ ";
	if (!ms || !ms->interactive)
		prompt = NULL;
	return (readline(prompt));
}
