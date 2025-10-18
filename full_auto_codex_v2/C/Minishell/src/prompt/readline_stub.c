#include "minishell.h"
#if !MS_USE_READLINE
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <unistd.h>

char	*ms_rl_readline(const char *prompt)
{
	char	*line;
	size_t	n;
	ssize_t	len;

	line = NULL;
	n = 0;
	if (prompt && *prompt)
	{
		if (write(STDOUT_FILENO, prompt, strlen(prompt)) < 0)
			return (NULL);
	}
	len = getline(&line, &n, stdin);
	if (len == -1)
	{
		free(line);
		return (NULL);
	}
	if (len > 0 && line[len - 1] == '\n')
		line[len - 1] = '\0';
	return (line);
}

void	ms_rl_add_history(const char *line)
{
	(void)line;
}
#endif
