#include "minishell.h"
#include "lexer.h"
#include "parser.h"
#include "token.h"
#include "executor.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static char	**dup_envp(char **envp)
{
	size_t	count;
	size_t	i;
	char	**copy;

	count = 0;
	while (envp && envp[count])
		count++;
	copy = calloc(count + 1, sizeof(char *));
	if (!copy)
		return (NULL);
	i = 0;
	while (i < count)
	{
		copy[i] = strdup(envp[i]);
		if (!copy[i])
		{
			while (i > 0)
				free(copy[--i]);
			free(copy);
			return (NULL);
		}
		i++;
	}
	return (copy);
}

int	ms_init(t_ms *ms, char **envp)
{
	if (!ms)
		return (1);
	ms->envp = dup_envp(envp);
	if (envp && !ms->envp)
		return (1);
	ms->last_status = 0;
	ms->interactive = isatty(STDIN_FILENO);
	ms->running = true;
	return (0);
}

int	ms_run(t_ms *ms)
{
	char	*line;
	t_token	*tokens;
	t_ast	*ast;

	if (ms->interactive)
		ms_configure_signals_interactive();
	while (ms->running)
	{
		line = ms_readline(ms);
		if (!line)
		{
			if (ms->interactive)
				printf("exit\n");
			ms->running = false;
			break ;
		}
		if (*line != '\0')
			add_history(line);
		tokens = ms_lex_line(line, ms);
		free(line);
		if (!tokens)
			continue ;
		ast = ms_parse(tokens, ms);
		token_clear(&tokens);
		if (!ast)
			continue ;
		ms_execute(ms, ast);
		ast_free(ast);
	}
	return (ms->last_status);
}

void	ms_cleanup(t_ms *ms)
{
	size_t	i;

	if (!ms || !ms->envp)
		return ;
	i = 0;
	while (ms->envp[i])
	{
		free(ms->envp[i]);
		i++;
	}
	free(ms->envp);
	ms->envp = NULL;
}
