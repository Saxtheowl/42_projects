#include "executor_internal.h"
#include <stdio.h>
#include <unistd.h>

static int	redirects_need_dup(const t_redirect *redir, t_redirect_type a,
			t_redirect_type b)
{
	while (redir)
	{
		if (redir->type == a || redir->type == b)
			return (1);
		redir = redir->next;
	}
	return (0);
}

static int	dup_fd(int *dst, int fd)
{
	*dst = dup(fd);
	if (*dst < 0)
		return (perror("dup"), 1);
	return (0);
}

static int	save_stdio(int saved[2], const t_redirect *redir)
{
	const int	need_in = redirects_need_dup(redir, REDIR_INPUT, REDIR_HEREDOC);
	const int	need_out = redirects_need_dup(redir, REDIR_OUTPUT,
			REDIR_APPEND);

	saved[0] = -1;
	saved[1] = -1;
	if (need_in && dup_fd(&saved[0], STDIN_FILENO))
		return (1);
	if (need_out && dup_fd(&saved[1], STDOUT_FILENO))
	{
		if (saved[0] >= 0)
			close(saved[0]);
		return (1);
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
