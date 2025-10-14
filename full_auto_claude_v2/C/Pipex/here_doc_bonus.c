/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   here_doc_bonus.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

void	read_here_doc(char *limiter, int *pipefd)
{
	char	*line;
	size_t	limiter_len;

	limiter_len = ft_strlen(limiter);
	close(pipefd[0]);
	while (1)
	{
		ft_putstr_fd("heredoc> ", 1);
		line = NULL;
		if (getline(&line, &limiter_len, stdin) == -1)
			break ;
		if (ft_strncmp(line, limiter, ft_strlen(limiter)) == 0
			&& line[ft_strlen(limiter)] == '\n')
		{
			free(line);
			break ;
		}
		ft_putstr_fd(line, pipefd[1]);
		free(line);
	}
	close(pipefd[1]);
	exit(EXIT_SUCCESS);
}

void	execute_here_doc(char **argv, char **envp)
{
	int		pipefd[2];
	int		pipe2fd[2];
	pid_t	pid;
	int		outfile;

	if (!argv[2] || !argv[3] || !argv[4] || !argv[5])
	{
		ft_putstr_fd(ERR_ARGS_HEREDOC, 2);
		exit(EXIT_FAILURE);
	}
	outfile = open(argv[5], O_WRONLY | O_CREAT | O_APPEND, 0644);
	if (outfile == -1)
		error_exit(argv[5]);
	if (pipe(pipefd) == -1)
		error_exit(ERR_PIPE);
	pid = fork();
	if (pid == -1)
		error_exit(ERR_FORK);
	if (pid == 0)
		read_here_doc(argv[2], pipefd);
	close(pipefd[1]);
	waitpid(pid, NULL, 0);
	if (pipe(pipe2fd) == -1)
		error_exit(ERR_PIPE);
	pid = fork();
	if (pid == -1)
		error_exit(ERR_FORK);
	if (pid == 0)
	{
		dup2(pipefd[0], STDIN_FILENO);
		dup2(pipe2fd[1], STDOUT_FILENO);
		close(pipefd[0]);
		close(pipe2fd[0]);
		close(pipe2fd[1]);
		execute_command(argv[3], envp);
	}
	close(pipefd[0]);
	close(pipe2fd[1]);
	waitpid(pid, NULL, 0);
	pid = fork();
	if (pid == -1)
		error_exit(ERR_FORK);
	if (pid == 0)
	{
		dup2(pipe2fd[0], STDIN_FILENO);
		dup2(outfile, STDOUT_FILENO);
		close(pipe2fd[0]);
		close(outfile);
		execute_command(argv[4], envp);
	}
	close(pipe2fd[0]);
	close(outfile);
	waitpid(pid, NULL, 0);
	exit(EXIT_SUCCESS);
}
