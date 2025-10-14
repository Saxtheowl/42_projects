/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex_bonus.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

void	child_bonus(char *cmd, char **envp, int *pipefd)
{
	dup2(pipefd[1], STDOUT_FILENO);
	close(pipefd[0]);
	close(pipefd[1]);
	execute_command(cmd, envp);
}

void	middle_child(char *cmd, char **envp, int *prev_pipe, int *next_pipe)
{
	dup2(prev_pipe[0], STDIN_FILENO);
	dup2(next_pipe[1], STDOUT_FILENO);
	close(prev_pipe[0]);
	close(prev_pipe[1]);
	close(next_pipe[0]);
	close(next_pipe[1]);
	execute_command(cmd, envp);
}

void	last_child(char *cmd, char **envp, int *pipefd, int outfile)
{
	dup2(pipefd[0], STDIN_FILENO);
	dup2(outfile, STDOUT_FILENO);
	close(pipefd[0]);
	close(pipefd[1]);
	if (outfile != STDOUT_FILENO)
		close(outfile);
	execute_command(cmd, envp);
}

void	execute_pipex_bonus(char **argv, char **envp, int argc)
{
	int		infile;
	int		outfile;
	int		pipefd[2];
	int		prev_pipe[2];
	pid_t	pid;
	int		i;

	if (argc < 5)
	{
		ft_putstr_fd(ERR_ARGS_BONUS, 2);
		exit(EXIT_FAILURE);
	}
	infile = open(argv[1], O_RDONLY);
	if (infile == -1)
		perror(argv[1]);
	outfile = open(argv[argc - 1], O_WRONLY | O_CREAT | O_TRUNC, 0644);
	if (outfile == -1)
		error_exit(argv[argc - 1]);
	i = 2;
	while (i < argc - 1)
	{
		if (pipe(pipefd) == -1)
			error_exit(ERR_PIPE);
		pid = fork();
		if (pid == -1)
			error_exit(ERR_FORK);
		if (pid == 0)
		{
			if (i == 2)
			{
				dup2(infile, STDIN_FILENO);
				if (infile != STDIN_FILENO)
					close(infile);
				child_bonus(argv[i], envp, pipefd);
			}
			else if (i == argc - 2)
				last_child(argv[i], envp, prev_pipe, outfile);
			else
				middle_child(argv[i], envp, prev_pipe, pipefd);
		}
		if (i > 2)
		{
			close(prev_pipe[0]);
			close(prev_pipe[1]);
		}
		if (i == 2 && infile != STDIN_FILENO)
			close(infile);
		prev_pipe[0] = pipefd[0];
		prev_pipe[1] = pipefd[1];
		i++;
	}
	close(pipefd[0]);
	close(pipefd[1]);
	if (outfile != STDOUT_FILENO)
		close(outfile);
	while (wait(NULL) > 0)
		;
}
