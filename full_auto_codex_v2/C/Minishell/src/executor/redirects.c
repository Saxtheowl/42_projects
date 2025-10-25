#include "executor_internal.h"
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

static int	open_mode_from_redirect(t_redirect_type type)
{
	if (type == REDIR_OUTPUT)
		return (O_CREAT | O_WRONLY | O_TRUNC);
	if (type == REDIR_APPEND)
		return (O_CREAT | O_WRONLY | O_APPEND);
	return (O_RDONLY);
}

static int	target_fd_from_redirect(t_redirect_type type)
{
	if (type == REDIR_INPUT || type == REDIR_HEREDOC)
		return (STDIN_FILENO);
	return (STDOUT_FILENO);
}

static int	redirect_heredoc_to_stdin(const t_redirect *redir)
{
	int		pipefd[2];
	size_t	len;

	if (pipe(pipefd) < 0)
		return (perror("pipe"), 1);
	len = redir->heredoc_data ? strlen(redir->heredoc_data) : 0;
	if (len > 0 && write(pipefd[1], redir->heredoc_data, len) < 0)
	{
		perror("write");
		close(pipefd[0]);
		close(pipefd[1]);
		return (1);
	}
	close(pipefd[1]);
	if (dup2(pipefd[0], STDIN_FILENO) < 0)
	{
		perror("dup2");
		close(pipefd[0]);
		return (1);
	}
	close(pipefd[0]);
	return (0);
}

static int	handle_file_redirect(const t_redirect *redir)
{
	int	fd;
	int	target;
	int	flags;

	flags = open_mode_from_redirect(redir->type);
	fd = open(redir->target, flags, 0644);
	if (fd < 0)
		return (perror(redir->target), 1);
	target = target_fd_from_redirect(redir->type);
	if (dup2(fd, target) < 0)
	{
		perror("dup2");
		close(fd);
		return (1);
	}
	close(fd);
	return (0);
}

int	ms_apply_redirects(const t_redirect *redir)
{
	while (redir)
	{
		if (redir->type == REDIR_HEREDOC)
		{
			if (redirect_heredoc_to_stdin(redir))
				return (1);
		}
		else if (handle_file_redirect(redir))
			return (1);
		redir = redir->next;
	}
	return (0);
}
