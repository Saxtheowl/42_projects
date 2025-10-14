/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   executor.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

int	is_builtin(char *cmd)
{
	if (!cmd)
		return (0);
	if (ft_strcmp(cmd, "echo") == 0)
		return (1);
	if (ft_strcmp(cmd, "cd") == 0)
		return (1);
	if (ft_strcmp(cmd, "pwd") == 0)
		return (1);
	if (ft_strcmp(cmd, "export") == 0)
		return (1);
	if (ft_strcmp(cmd, "unset") == 0)
		return (1);
	if (ft_strcmp(cmd, "env") == 0)
		return (1);
	if (ft_strcmp(cmd, "exit") == 0)
		return (1);
	return (0);
}

int	execute_builtin(char **args, t_shell *shell)
{
	if (!args || !args[0])
		return (1);
	if (ft_strcmp(args[0], "echo") == 0)
		return (builtin_echo(args));
	if (ft_strcmp(args[0], "cd") == 0)
		return (builtin_cd(args, shell));
	if (ft_strcmp(args[0], "pwd") == 0)
		return (builtin_pwd());
	if (ft_strcmp(args[0], "export") == 0)
		return (builtin_export(args, shell));
	if (ft_strcmp(args[0], "unset") == 0)
		return (builtin_unset(args, shell));
	if (ft_strcmp(args[0], "env") == 0)
		return (builtin_env(shell));
	if (ft_strcmp(args[0], "exit") == 0)
		return (builtin_exit(args, shell));
	return (1);
}

static char	*find_executable(char *cmd, t_env *env)
{
	char	**paths;
	char	*path;
	char	*full_path;
	int		i;

	if (ft_strchr(cmd, '/'))
	{
		if (access(cmd, X_OK) == 0)
			return (ft_strdup(cmd));
		return (NULL);
	}
	path = get_env_value(env, "PATH");
	if (!path)
		return (NULL);
	paths = ft_split(path, ':');
	i = 0;
	while (paths[i])
	{
		full_path = ft_strjoin(paths[i], "/");
		path = ft_strjoin(full_path, cmd);
		free(full_path);
		if (access(path, X_OK) == 0)
		{
			ft_free_split(paths);
			return (path);
		}
		free(path);
		i++;
	}
	ft_free_split(paths);
	return (NULL);
}

static void	execute_cmd(t_cmd *cmd, t_shell *shell)
{
	char	*executable;
	char	**envp;

	if (!cmd->args || !cmd->args[0])
		exit(0);
	expand_cmd(cmd, shell);
	if (setup_redirections(cmd->redirs) == -1)
		exit(1);
	if (is_builtin(cmd->args[0]))
	{
		shell->last_exit_status = execute_builtin(cmd->args, shell);
		exit(shell->last_exit_status);
	}
	executable = find_executable(cmd->args[0], shell->env);
	if (!executable)
	{
		error_cmd(cmd->args[0], "command not found");
		exit(127);
	}
	envp = env_to_array(shell->env);
	setup_signals_exec();
	execve(executable, cmd->args, envp);
	perror("execve");
	free(executable);
	ft_free_split(envp);
	exit(1);
}

static int	count_cmds(t_cmd *cmds)
{
	int	count;

	count = 0;
	while (cmds)
	{
		count++;
		cmds = cmds->next;
	}
	return (count);
}

static void	execute_pipeline(t_cmd *cmds, t_shell *shell)
{
	int		pipe_fd[2];
	pid_t	pid;
	int		prev_fd;
	int		status;

	prev_fd = -1;
	while (cmds)
	{
		if (cmds->next)
			pipe(pipe_fd);
		pid = fork();
		if (pid == 0)
		{
			if (prev_fd != -1)
			{
				dup2(prev_fd, STDIN_FILENO);
				close(prev_fd);
			}
			if (cmds->next)
			{
				close(pipe_fd[0]);
				dup2(pipe_fd[1], STDOUT_FILENO);
				close(pipe_fd[1]);
			}
			execute_cmd(cmds, shell);
		}
		if (prev_fd != -1)
			close(prev_fd);
		if (cmds->next)
		{
			close(pipe_fd[1]);
			prev_fd = pipe_fd[0];
		}
		cmds = cmds->next;
	}
	while (wait(&status) > 0)
		;
	if (WIFEXITED(status))
		shell->last_exit_status = WEXITSTATUS(status);
	else if (WIFSIGNALED(status))
		shell->last_exit_status = 128 + WTERMSIG(status);
}

void	executor(t_cmd *cmds, t_shell *shell)
{
	int	num_cmds;

	if (!cmds || !cmds->args || !cmds->args[0])
		return ;
	num_cmds = count_cmds(cmds);
	if (num_cmds == 1 && is_builtin(cmds->args[0]))
	{
		expand_cmd(cmds, shell);
		if (ft_strcmp(cmds->args[0], "cd") == 0
			|| ft_strcmp(cmds->args[0], "export") == 0
			|| ft_strcmp(cmds->args[0], "unset") == 0
			|| ft_strcmp(cmds->args[0], "exit") == 0)
		{
			shell->last_exit_status = execute_builtin(cmds->args, shell);
			return ;
		}
	}
	execute_pipeline(cmds, shell);
}
