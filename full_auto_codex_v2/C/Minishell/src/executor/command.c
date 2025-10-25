#include "executor_internal.h"
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>

static int	execute_redirection_only(t_command *cmd)
{
	const t_redirect	*redir;
	int					fd;
	int					flags;

	redir = cmd->redirects;
	while (redir)
	{
		if (redir->type != REDIR_HEREDOC)
		{
			if (redir->type == REDIR_INPUT)
				flags = O_RDONLY;
			else if (redir->type == REDIR_OUTPUT)
				flags = O_CREAT | O_WRONLY | O_TRUNC;
			else
				flags = O_CREAT | O_WRONLY | O_APPEND;
			fd = open(redir->target, flags, 0644);
			if (fd < 0)
				return (perror(redir->target), 1);
			close(fd);
		}
		redir = redir->next;
	}
	return (0);
}

int	ms_execute_command(t_ms *ms, t_command *cmd, int in_child)
{
	t_builtin_fn	builtin;

	if (!cmd->argv || !cmd->argv[0])
		return (execute_redirection_only(cmd));
	builtin = ms_builtin_get(cmd->argv[0]);
	if (builtin)
		return (ms_execute_builtin(ms, cmd, builtin, in_child));
	return (ms_execute_external(ms, cmd, in_child));
}
