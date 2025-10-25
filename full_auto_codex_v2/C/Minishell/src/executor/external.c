#include "executor_internal.h"
#include "env.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define EXIT_CMD_NOT_FOUND 127
#define EXIT_NO_PERMISSION 126

static int	build_candidate(const char *dir, const char *cmd, char **out)
{
	size_t	len;
	char	*candidate;

	len = strlen(dir) + strlen(cmd) + 2;
	candidate = malloc(len);
	if (!candidate)
		return (1);
	snprintf(candidate, len, "%s/%s", dir, cmd);
	if (access(candidate, X_OK) == 0)
	{
		*out = candidate;
		return (0);
	}
	free(candidate);
	*out = NULL;
	return (0);
}

static char	*resolve_command_path(t_ms *ms, const char *cmd)
{
	const char	*path_env = ms_env_get(ms, "PATH");
	char		*dup;
	char		*token;
	if (!cmd || *cmd == '\0')
		return (NULL);
	if (strchr(cmd, '/'))
		return (strdup(cmd));
	if (!path_env || *path_env == '\0')
		return (NULL);
	dup = strdup(path_env);
	if (!dup)
		return (NULL);
	for (token = strtok(dup, ":"); token; token = strtok(NULL, ":"))
	{
		char	*candidate;
		if (build_candidate(token, cmd, &candidate))
			return (free(dup), NULL);
		if (candidate)
			return (free(dup), candidate);
	}
	free(dup);
	return (NULL);
}

static void	execve_with_error(t_ms *ms, t_command *cmd)
{
	char	*path;
	int		err;

	if (!cmd->argv || !cmd->argv[0])
		_exit(0);
	path = resolve_command_path(ms, cmd->argv[0]);
	if (!path)
	{
		if (strchr(cmd->argv[0], '/'))
			perror(cmd->argv[0]);
		else
			fprintf(stderr, "minishell: %s: command not found\n", cmd->argv[0]);
		_exit(EXIT_CMD_NOT_FOUND);
	}
	execve(path, cmd->argv, ms->envp);
	err = errno;
	perror(path);
	free(path);
	if (err == ENOENT)
		_exit(EXIT_CMD_NOT_FOUND);
	if (err == EACCES)
		_exit(EXIT_NO_PERMISSION);
	_exit(EXIT_NO_PERMISSION);
}

static int	run_external_child(t_ms *ms, t_command *cmd)
{
	ms_configure_signals_child();
	if (ms_apply_redirects(cmd->redirects))
		_exit(1);
	execve_with_error(ms, cmd);
	_exit(1);
	return (1);
}

int	ms_execute_external(t_ms *ms, t_command *cmd, int in_child)
{
	pid_t	pid;

	if (in_child)
		return (run_external_child(ms, cmd));
	pid = fork();
	if (pid < 0)
		return (perror("fork"), 1);
	if (pid == 0)
		run_external_child(ms, cmd);
	return (ms_wait_for_pid(pid));
}
