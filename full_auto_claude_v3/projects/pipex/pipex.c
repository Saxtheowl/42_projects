/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

void	error_exit(char *msg)
{
	perror(msg);
	exit(EXIT_FAILURE);
}

static char	*get_env_path(char **envp)
{
	int	i;

	i = 0;
	while (envp[i])
	{
		if (ft_strnstr(envp[i], "PATH=", 5))
			return (envp[i] + 5);
		i++;
	}
	return (NULL);
}

char	*find_path(char *cmd, char **envp)
{
	char	**paths;
	char	*path;
	char	*full_path;
	char	*tmp;
	int		i;

	if (access(cmd, X_OK) == 0)
		return (ft_strdup(cmd));
	path = get_env_path(envp);
	if (!path)
		return (NULL);
	paths = ft_split(path, ':');
	if (!paths)
		return (NULL);
	i = 0;
	while (paths[i])
	{
		tmp = ft_strjoin(paths[i], "/");
		full_path = ft_strjoin(tmp, cmd);
		free(tmp);
		if (access(full_path, X_OK) == 0)
		{
			while (paths[i])
				free(paths[i++]);
			free(paths);
			return (full_path);
		}
		free(full_path);
		free(paths[i]);
		i++;
	}
	free(paths);
	return (NULL);
}

void	execute_cmd(char *cmd, char **envp)
{
	char	**args;
	char	*path;

	args = ft_split(cmd, ' ');
	if (!args)
		error_exit("split");
	path = find_path(args[0], envp);
	if (!path)
	{
		write(2, "pipex: command not found: ", 26);
		write(2, args[0], ft_strlen(args[0]));
		write(2, "\n", 1);
		exit(127);
	}
	execve(path, args, envp);
	error_exit("execve");
}

void	child_process(t_pipex *pipex)
{
	close(pipex->pipe_fd[0]);
	if (dup2(pipex->infile, STDIN_FILENO) < 0)
		error_exit("dup2");
	if (dup2(pipex->pipe_fd[1], STDOUT_FILENO) < 0)
		error_exit("dup2");
	close(pipex->pipe_fd[1]);
	close(pipex->infile);
	execute_cmd(pipex->cmd1[0], pipex->envp);
}

void	parent_process(t_pipex *pipex)
{
	close(pipex->pipe_fd[1]);
	if (dup2(pipex->pipe_fd[0], STDIN_FILENO) < 0)
		error_exit("dup2");
	if (dup2(pipex->outfile, STDOUT_FILENO) < 0)
		error_exit("dup2");
	close(pipex->pipe_fd[0]);
	close(pipex->outfile);
	execute_cmd(pipex->cmd2[0], pipex->envp);
}

int	main(int argc, char **argv, char **envp)
{
	t_pipex	pipex;
	pid_t	pid;

	if (argc != 5)
	{
		write(2, "Usage: ./pipex file1 cmd1 cmd2 file2\n", 37);
		return (1);
	}
	pipex.infile = open(argv[1], O_RDONLY);
	if (pipex.infile < 0)
		error_exit(argv[1]);
	pipex.outfile = open(argv[4], O_WRONLY | O_CREAT | O_TRUNC, 0644);
	if (pipex.outfile < 0)
		error_exit(argv[4]);
	pipex.cmd1 = &argv[2];
	pipex.cmd2 = &argv[3];
	pipex.envp = envp;
	if (pipe(pipex.pipe_fd) < 0)
		error_exit("pipe");
	pid = fork();
	if (pid < 0)
		error_exit("fork");
	if (pid == 0)
		child_process(&pipex);
	waitpid(pid, NULL, 0);
	parent_process(&pipex);
	return (0);
}
