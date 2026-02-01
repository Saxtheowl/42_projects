/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   executor.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	count_cmds(t_cmd *cmd)
{
	int	count;

	count = 0;
	while (cmd)
	{
		count++;
		cmd = cmd->next;
	}
	return (count);
}

static void	exec_child(t_cmd *cmd, t_shell *shell, int in_fd, int out_fd)
{
	char	*path;

	setup_signals_child();
	if (in_fd != STDIN_FILENO)
	{
		dup2(in_fd, STDIN_FILENO);
		close(in_fd);
	}
	if (out_fd != STDOUT_FILENO)
	{
		dup2(out_fd, STDOUT_FILENO);
		close(out_fd);
	}
	if (setup_redirections(cmd->redir) < 0)
		exit(1);
	if (!cmd->args || !cmd->args[0])
		exit(0);
	if (is_builtin(cmd->args[0]))
		exit(exec_builtin(cmd, shell));
	path = find_command(cmd->args[0], shell);
	if (!path)
	{
		fprintf(stderr, "minishell: %s: command not found\n", cmd->args[0]);
		exit(127);
	}
	execve(path, cmd->args, shell->env);
	perror("minishell");
	free(path);
	exit(126);
}

static int	exec_pipeline(t_cmd *cmd, t_shell *shell)
{
	int		pfd[2];
	int		in_fd;
	pid_t	pid;
	int		status;

	in_fd = STDIN_FILENO;
	status = 0;
	while (cmd)
	{
		if (cmd->next && pipe(pfd) < 0)
			return (1);
		pid = fork();
		if (pid < 0)
			return (1);
		if (pid == 0)
			exec_child(cmd, shell, in_fd,
				cmd->next ? pfd[1] : STDOUT_FILENO);
		if (in_fd != STDIN_FILENO)
			close(in_fd);
		if (cmd->next)
		{
			close(pfd[1]);
			in_fd = pfd[0];
		}
		cmd = cmd->next;
	}
	while (waitpid(-1, &status, 0) > 0)
		;
	if (WIFEXITED(status))
		return (WEXITSTATUS(status));
	if (WIFSIGNALED(status))
		return (128 + WTERMSIG(status));
	return (0);
}

static int	exec_single(t_cmd *cmd, t_shell *shell)
{
	pid_t	pid;
	int		status;
	int		saved_stdin;
	int		saved_stdout;
	int		ret;

	if (!cmd->args || !cmd->args[0])
		return (0);
	if (is_builtin(cmd->args[0]))
	{
		saved_stdin = dup(STDIN_FILENO);
		saved_stdout = dup(STDOUT_FILENO);
		if (setup_redirections(cmd->redir) < 0)
		{
			dup2(saved_stdin, STDIN_FILENO);
			dup2(saved_stdout, STDOUT_FILENO);
			close(saved_stdin);
			close(saved_stdout);
			return (1);
		}
		ret = exec_builtin(cmd, shell);
		dup2(saved_stdin, STDIN_FILENO);
		dup2(saved_stdout, STDOUT_FILENO);
		close(saved_stdin);
		close(saved_stdout);
		return (ret);
	}
	pid = fork();
	if (pid < 0)
		return (1);
	if (pid == 0)
		exec_child(cmd, shell, STDIN_FILENO, STDOUT_FILENO);
	waitpid(pid, &status, 0);
	if (WIFEXITED(status))
		return (WEXITSTATUS(status));
	if (WIFSIGNALED(status))
	{
		if (WTERMSIG(status) == SIGQUIT)
			printf("Quit (core dumped)\n");
		else if (WTERMSIG(status) == SIGINT)
			printf("\n");
		return (128 + WTERMSIG(status));
	}
	return (0);
}

int	execute(t_cmd *cmd, t_shell *shell)
{
	if (!cmd)
		return (0);
	if (count_cmds(cmd) == 1)
		return (exec_single(cmd, shell));
	return (exec_pipeline(cmd, shell));
}
