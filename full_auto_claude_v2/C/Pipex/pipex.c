/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

void	execute_command(char *cmd, char **envp)
{
	char	**args;
	char	*path;

	args = ft_split(cmd, ' ');
	if (!args || !args[0])
		error_exit("Command parsing failed");
	path = find_path(args[0], envp);
	if (!path)
	{
		ft_putstr_fd(ERR_CMD, 2);
		ft_putstr_fd(args[0], 2);
		ft_putstr_fd("\n", 2);
		free_split(args);
		exit(127);
	}
	if (execve(path, args, envp) == -1)
	{
		free(path);
		free_split(args);
		error_exit("execve failed");
	}
}

void	child_process(char *cmd, char **envp, int *pipefd, int infile)
{
	dup2(infile, STDIN_FILENO);
	dup2(pipefd[1], STDOUT_FILENO);
	close(pipefd[0]);
	close(pipefd[1]);
	if (infile != STDIN_FILENO)
		close(infile);
	execute_command(cmd, envp);
}

void	parent_process(char *cmd, char **envp, int *pipefd, int outfile)
{
	dup2(pipefd[0], STDIN_FILENO);
	dup2(outfile, STDOUT_FILENO);
	close(pipefd[0]);
	close(pipefd[1]);
	if (outfile != STDOUT_FILENO)
		close(outfile);
	execute_command(cmd, envp);
}

void	execute_pipex(char **argv, char **envp, int argc)
{
	int		pipefd[2];
	pid_t	pid;
	int		infile;
	int		outfile;

	if (argc != 5)
	{
		ft_putstr_fd(ERR_ARGS, 2);
		exit(EXIT_FAILURE);
	}
	infile = open(argv[1], O_RDONLY);
	if (infile == -1)
		perror(argv[1]);
	outfile = open(argv[4], O_WRONLY | O_CREAT | O_TRUNC, 0644);
	if (outfile == -1)
		error_exit(argv[4]);
	if (pipe(pipefd) == -1)
		error_exit(ERR_PIPE);
	pid = fork();
	if (pid == -1)
		error_exit(ERR_FORK);
	if (pid == 0)
		child_process(argv[2], envp, pipefd, infile);
	waitpid(pid, NULL, 0);
	parent_process(argv[3], envp, pipefd, outfile);
}

int	main(int argc, char **argv, char **envp)
{
	if (argc >= 2 && ft_strncmp(argv[1], "here_doc", 9) == 0)
		execute_here_doc(argv, envp);
	else if (argc >= 5)
		execute_pipex_bonus(argv, envp, argc);
	else
		execute_pipex(argv, envp, argc);
	return (0);
}
