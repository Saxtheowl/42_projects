/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   redirect.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	handle_heredoc(char *delimiter)
{
	int		pfd[2];
	char	*line;

	if (pipe(pfd) < 0)
		return (-1);
	setup_signals_heredoc();
	while (1)
	{
		line = readline("> ");
		if (!line || ft_strcmp(line, delimiter) == 0)
		{
			free(line);
			break ;
		}
		write(pfd[1], line, ft_strlen(line));
		write(pfd[1], "\n", 1);
		free(line);
	}
	setup_signals();
	close(pfd[1]);
	dup2(pfd[0], STDIN_FILENO);
	close(pfd[0]);
	return (0);
}

static int	do_redir_in(char *file)
{
	int	fd;

	fd = open(file, O_RDONLY);
	if (fd < 0)
	{
		fprintf(stderr, "minishell: %s: %s\n", file, strerror(errno));
		return (-1);
	}
	dup2(fd, STDIN_FILENO);
	close(fd);
	return (0);
}

static int	do_redir_out(char *file, int append)
{
	int	fd;
	int	flags;

	flags = O_WRONLY | O_CREAT;
	if (append)
		flags |= O_APPEND;
	else
		flags |= O_TRUNC;
	fd = open(file, flags, 0644);
	if (fd < 0)
	{
		fprintf(stderr, "minishell: %s: %s\n", file, strerror(errno));
		return (-1);
	}
	dup2(fd, STDOUT_FILENO);
	close(fd);
	return (0);
}

int	setup_redirections(t_redir *redir)
{
	while (redir)
	{
		if (redir->type == TOKEN_REDIR_IN)
		{
			if (do_redir_in(redir->file) < 0)
				return (-1);
		}
		else if (redir->type == TOKEN_REDIR_OUT)
		{
			if (do_redir_out(redir->file, 0) < 0)
				return (-1);
		}
		else if (redir->type == TOKEN_APPEND)
		{
			if (do_redir_out(redir->file, 1) < 0)
				return (-1);
		}
		else if (redir->type == TOKEN_HEREDOC)
		{
			if (handle_heredoc(redir->file) < 0)
				return (-1);
		}
		redir = redir->next;
	}
	return (0);
}
