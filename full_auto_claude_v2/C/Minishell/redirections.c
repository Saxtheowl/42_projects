/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   redirections.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

int	handle_heredoc(char *delimiter)
{
	int		pipe_fd[2];
	char	*line;

	if (pipe(pipe_fd) == -1)
	{
		perror("pipe");
		return (-1);
	}
	while (1)
	{
		line = readline("> ");
		if (!line || ft_strcmp(line, delimiter) == 0)
		{
			free(line);
			break ;
		}
		write(pipe_fd[1], line, ft_strlen(line));
		write(pipe_fd[1], "\n", 1);
		free(line);
	}
	close(pipe_fd[1]);
	return (pipe_fd[0]);
}

static int	handle_redir_in(char *file)
{
	int	fd;

	fd = open(file, O_RDONLY);
	if (fd == -1)
	{
		error_cmd(file, strerror(errno));
		return (-1);
	}
	if (dup2(fd, STDIN_FILENO) == -1)
	{
		perror("dup2");
		close(fd);
		return (-1);
	}
	close(fd);
	return (0);
}

static int	handle_redir_out(char *file)
{
	int	fd;

	fd = open(file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
	if (fd == -1)
	{
		error_cmd(file, strerror(errno));
		return (-1);
	}
	if (dup2(fd, STDOUT_FILENO) == -1)
	{
		perror("dup2");
		close(fd);
		return (-1);
	}
	close(fd);
	return (0);
}

static int	handle_redir_append(char *file)
{
	int	fd;

	fd = open(file, O_WRONLY | O_CREAT | O_APPEND, 0644);
	if (fd == -1)
	{
		error_cmd(file, strerror(errno));
		return (-1);
	}
	if (dup2(fd, STDOUT_FILENO) == -1)
	{
		perror("dup2");
		close(fd);
		return (-1);
	}
	close(fd);
	return (0);
}

int	setup_redirections(t_redir *redirs)
{
	int	heredoc_fd;

	while (redirs)
	{
		if (redirs->type == TOKEN_REDIR_IN)
		{
			if (handle_redir_in(redirs->file) == -1)
				return (-1);
		}
		else if (redirs->type == TOKEN_REDIR_OUT)
		{
			if (handle_redir_out(redirs->file) == -1)
				return (-1);
		}
		else if (redirs->type == TOKEN_REDIR_APPEND)
		{
			if (handle_redir_append(redirs->file) == -1)
				return (-1);
		}
		else if (redirs->type == TOKEN_REDIR_HEREDOC)
		{
			heredoc_fd = handle_heredoc(redirs->file);
			if (heredoc_fd == -1)
				return (-1);
			if (dup2(heredoc_fd, STDIN_FILENO) == -1)
			{
				perror("dup2");
				close(heredoc_fd);
				return (-1);
			}
			close(heredoc_fd);
		}
		redirs = redirs->next;
	}
	return (0);
}
