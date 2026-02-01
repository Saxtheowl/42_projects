/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

volatile sig_atomic_t	g_signal = 0;

void	init_shell(t_shell *shell, char **envp)
{
	shell->env = copy_env(envp);
	shell->env_count = 0;
	while (shell->env && shell->env[shell->env_count])
		shell->env_count++;
	shell->exit_status = 0;
	shell->running = 1;
}

void	cleanup_shell(t_shell *shell)
{
	free_env(shell->env);
}

static void	process_line(char *line, t_shell *shell)
{
	t_token	*tokens;
	t_cmd	*cmds;

	if (!line || !*line)
		return ;
	add_history(line);
	tokens = lexer(line, shell);
	if (!tokens)
		return ;
	cmds = parser(tokens);
	free_tokens(tokens);
	if (!cmds)
		return ;
	shell->exit_status = execute(cmds, shell);
	free_cmds(cmds);
}

int	main(int argc, char **argv, char **envp)
{
	t_shell	shell;
	char	*line;

	(void)argc;
	(void)argv;
	init_shell(&shell, envp);
	setup_signals();
	while (shell.running)
	{
		g_signal = 0;
		line = readline(PROMPT);
		if (g_signal)
		{
			shell.exit_status = 130;
			g_signal = 0;
		}
		if (!line)
		{
			printf("exit\n");
			break ;
		}
		process_line(line, &shell);
		free(line);
	}
	cleanup_shell(&shell);
	return (shell.exit_status);
}
