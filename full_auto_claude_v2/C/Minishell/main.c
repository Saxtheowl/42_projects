/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

int	g_signal_received = 0;

static void	process_line(char *line, t_shell *shell)
{
	t_token	*tokens;
	t_cmd	*cmds;

	if (!line || !*line)
		return ;
	add_history(line);
	tokens = lexer(line);
	if (!tokens)
		return ;
	cmds = parser(tokens);
	free_tokens(tokens);
	if (!cmds)
		return ;
	executor(cmds, shell);
	free_cmds(cmds);
}

int	main(int argc, char **argv, char **envp)
{
	char	*line;
	t_shell	shell;

	(void)argc;
	(void)argv;
	shell.env = init_env(envp);
	shell.last_exit_status = 0;
	shell.in_heredoc = 0;
	setup_signals();
	while (1)
	{
		line = readline(PROMPT);
		if (!line)
		{
			ft_putendl_fd("exit", 1);
			break ;
		}
		if (g_signal_received)
		{
			shell.last_exit_status = 130;
			g_signal_received = 0;
		}
		process_line(line, &shell);
		free(line);
	}
	free_env(shell.env);
	return (shell.last_exit_status);
}
