#include "executor_internal.h"
#include <stdio.h>
#include <unistd.h>

static int	save_stdio(int saved[2], const t_redirect *redir)
{
	int	need_in;
	int	need_out;

	need_in = 0;
	need_out = 0;
	while (redir)
	{
		if (redir->type == REDIR_INPUT || redir->type == REDIR_HEREDOC)
			need_in = 1;
		if (redir->type == REDIR_OUTPUT || redir->type == REDIR_APPEND)
			need_out = 1;
		redir = redir->next;
	}
	saved[0] = -1;
	saved[1] = -1;
	if (need_in)
	{
		saved[0] = dup(STDIN_FILENO);
		if (saved[0] < 0)
			return (perror("dup"), 1);
	}
	if (need_out)
	{
		saved[1] = dup(STDOUT_FILENO);
		if (saved[1] < 0)
		{
			perror("dup");
			if (saved[0] >= 0)
				close(saved[0]);
			return (1);
		}
	}
	return (0);
}

static void	restore_stdio(const int saved[2])
{
	if (saved[0] >= 0)
	{
		if (dup2(saved[0], STDIN_FILENO) < 0)
			perror("dup2");
		close(saved[0]);
	}
	if (saved[1] >= 0)
	{
		if (dup2(saved[1], STDOUT_FILENO) < 0)
			perror("dup2");
		close(saved[1]);
	}
}

int	ms_execute_builtin(t_ms *ms, t_command *cmd,
			t_builtin_fn builtin, int in_child)
{
	int	saved[2];
	int	status;

	saved[0] = -1;
	saved[1] = -1;
	if (!in_child && save_stdio(saved, cmd->redirects))
		return (1);
	if (ms_apply_redirects(cmd->redirects))
	{
		if (!in_child)
			restore_stdio(saved);
		return (1);
	}
	status = builtin(ms, cmd, in_child);
	if (!in_child)
		restore_stdio(saved);
	return (status);
}
