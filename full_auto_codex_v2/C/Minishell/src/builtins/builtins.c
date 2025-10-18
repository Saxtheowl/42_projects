#include "builtins.h"
#include "env.h"
#include <ctype.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void	free_snapshot(char **snapshot)
{
	size_t i;

	if (!snapshot)
		return ;
	i = 0;
	while (snapshot[i])
		free(snapshot[i++]);
	free(snapshot);
}

static int	is_n_flag(const char *arg)
{
	size_t	i;

	if (!arg || arg[0] != '-')
		return (0);
	i = 1;
	if (arg[i] != 'n')
		return (0);
	while (arg[i] == 'n')
		i++;
	return (arg[i] == '\0');
}

int	ms_builtin_echo(t_ms *ms, t_command *cmd, int in_child)
{
	size_t	i;
	int		first;
	int		print_newline;

	(void)ms;
	(void)in_child;
	print_newline = 1;
	i = 1;
	while (cmd->argv[i] && is_n_flag(cmd->argv[i]))
	{
		print_newline = 0;
		i++;
	}
	first = 1;
	while (cmd->argv[i])
	{
		if (!first)
			write(STDOUT_FILENO, " ", 1);
		write(STDOUT_FILENO, cmd->argv[i], strlen(cmd->argv[i]));
		first = 0;
		i++;
	}
	if (print_newline)
		write(STDOUT_FILENO, "\n", 1);
	return (0);
}

int	ms_builtin_pwd(t_ms *ms, t_command *cmd, int in_child)
{
	char	*cwd;

	(void)ms;
	(void)cmd;
	(void)in_child;
	cwd = getcwd(NULL, 0);
	if (!cwd)
	{
		perror("pwd");
		return (1);
	}
	printf("%s\n", cwd);
	free(cwd);
	return (0);
}

int	ms_builtin_env(t_ms *ms, t_command *cmd, int in_child)
{
	size_t	i;

	(void)in_child;
	if (cmd->argv[1])
	{
		fprintf(stderr, "minishell: env: too many arguments\n");
		return (1);
	}
	i = 0;
	while (ms->envp && ms->envp[i])
	{
		if (strchr(ms->envp[i], '='))
			printf("%s\n", ms->envp[i]);
		i++;
	}
	return (0);
}

static int	is_numeric_argument(const char *arg)
{
	size_t	i;

	if (!arg || *arg == '\0')
		return (0);
	i = 0;
	if (arg[i] == '+' || arg[i] == '-')
		i++;
	if (!isdigit((unsigned char)arg[i]))
		return (0);
	while (arg[i])
	{
		if (!isdigit((unsigned char)arg[i]))
			return (0);
		i++;
	}
	return (1);
}

static int	exit_status_from_argument(const char *arg)
{
	long long	value;

	errno = 0;
	value = strtoll(arg, NULL, 10);
	if (errno != 0)
		return (2);
	return ((unsigned char)value);
}

int	ms_builtin_exit(t_ms *ms, t_command *cmd, int in_child)
{
	int	status;

	if (!in_child)
		write(STDOUT_FILENO, "exit\n", 5);
	if (!cmd->argv[1])
	{
		status = ms->last_status;
		if (!in_child)
			ms->running = false;
		return (status);
	}
	if (!is_numeric_argument(cmd->argv[1]))
	{
		fprintf(stderr, "minishell: exit: %s: numeric argument required\n",
			cmd->argv[1]);
		if (!in_child)
			ms->running = false;
		return (2);
	}
	if (cmd->argv[2])
	{
		fprintf(stderr, "minishell: exit: too many arguments\n");
		return (1);
	}
	status = exit_status_from_argument(cmd->argv[1]);
	if (!in_child)
		ms->running = false;
	return (status);
}

typedef struct s_builtin_entry
{
	const char	*name;
	t_builtin_fn	fn;
}	t_builtin_entry;

static const t_builtin_entry	g_builtins[] = {
{"echo", ms_builtin_echo},
{"pwd", ms_builtin_pwd},
{"env", ms_builtin_env},
{"exit", ms_builtin_exit},
{"export", ms_builtin_export},
{"unset", ms_builtin_unset},
{"cd", ms_builtin_cd},
{NULL, NULL}
};

t_builtin_fn	ms_builtin_get(const char *name)
{
	size_t	i;

	if (!name)
		return (NULL);
	i = 0;
	while (g_builtins[i].name)
	{
		if (strcmp(g_builtins[i].name, name) == 0)
			return (g_builtins[i].fn);
		i++;
	}
	return (NULL);
}
static int	compare_export_entries(const void *a, const void *b)
{
	const char	*sa;
	const char	*sb;

	sa = *(const char *const *)a;
	sb = *(const char *const *)b;
	return (strcmp(sa, sb));
}

static void	print_export_entry(const char *entry)
{
	const char	*eq;

	eq = strchr(entry, '=');
	if (!eq)
	{
		printf("declare -x %s\n", entry);
		return ;
	}
	printf("declare -x %.*s\"%s\"\n", (int)(eq - entry + 1), entry, eq + 1);
}

static int	export_with_no_args(t_ms *ms)
{
	char	**snapshot;
	size_t	count;

	snapshot = ms_env_export_snapshot(ms);
	if (!snapshot)
	{
		perror("minishell: export");
		return (1);
	}
	count = 0;
	while (snapshot[count])
		count++;
	qsort(snapshot, count, sizeof(char *), compare_export_entries);
	count = 0;
	while (snapshot[count])
	{
		print_export_entry(snapshot[count]);
		count++;
	}
	free_snapshot(snapshot);
	return (0);
}

static int	handle_export_assignment(t_ms *ms, const char *arg)
{
	char	*name;
	const char	*value;
	char	*plus;
	int	status;

	plus = strstr(arg, "+=");
	if (plus)
	{
		fprintf(stderr, "minishell: export: invalid operator '+=\'\n");
		return (1);
	}
	value = strchr(arg, '=');
	if (value)
	{
		name = strndup(arg, value - arg);
		if (!name)
		{
			perror("minishell: export");
			return (1);
		}
		value++;
	}
	else
	{
		name = strdup(arg);
		value = ms_env_get(ms, arg);
		if (!value)
			value = "";
	}
	if (!name)
	{
		perror("minishell: export");
		return (1);
	}
	status = ms_env_set(ms, name, value);
	free(name);
	if (status)
		perror("minishell: export");
	return (status != 0);
}

int	ms_builtin_export(t_ms *ms, t_command *cmd, int in_child)
{
	size_t	i;
	int	status;

	(void)in_child;
	if (!cmd->argv[1])
		return (export_with_no_args(ms));
	status = 0;
	i = 1;
	while (cmd->argv[i])
	{
		if (!ms_env_is_valid_identifier(cmd->argv[i]))
		{
			fprintf(stderr, "minishell: export: '%s': not a valid identifier\n",
				cmd->argv[i]);
			status = 1;
		}
		else if (handle_export_assignment(ms, cmd->argv[i]))
			status = 1;
		i++;
	}
	return (status);
}

int	ms_builtin_unset(t_ms *ms, t_command *cmd, int in_child)
{
	size_t	i;
	int	status;

	(void)in_child;
	status = 0;
	i = 1;
	while (cmd->argv[i])
	{
		if (!ms_env_is_valid_identifier(cmd->argv[i]))
		{
			fprintf(stderr, "minishell: unset: '%s': not a valid identifier\n",
				cmd->argv[i]);
			status = 1;
		}
		else if (ms_env_unset(ms, cmd->argv[i]))
			status = 1;
		i++;
	}
	return (status);
}

static int	update_pwd_vars(t_ms *ms, const char *old_pwd)
{
	char	*new_pwd;
	int	status;

	new_pwd = getcwd(NULL, 0);
	if (!new_pwd)
	{
		perror("minishell: cd");
		return (1);
	}
	status = ms_env_set(ms, "OLDPWD", old_pwd ? old_pwd : "");
	if (status == 0)
		status = ms_env_set(ms, "PWD", new_pwd);
	free(new_pwd);
	if (status)
		perror("minishell: cd");
	return (status != 0);
}

int	ms_builtin_cd(t_ms *ms, t_command *cmd, int in_child)
{
	const char	*target;
	const char	*old_pwd;
	int	status;

	(void)in_child;
	old_pwd = ms_env_get(ms, "PWD");
	if (cmd->argv[1] == NULL)
		target = ms_env_get(ms, "HOME");
	else if (strcmp(cmd->argv[1], "-") == 0)
		target = ms_env_get(ms, "OLDPWD");
	else
		target = cmd->argv[1];
	if (!target || target[0] == '\0')
	{
		fprintf(stderr, "minishell: cd: %snot set\n",
			cmd->argv[1] && strcmp(cmd->argv[1], "-") == 0 ? "OLDPWD " : "HOME ");
		return (1);
	}
	if (chdir(target) != 0)
	{
		perror("minishell: cd");
		return (1);
	}
	if (cmd->argv[1] && strcmp(cmd->argv[1], "-") == 0)
		printf("%s\n", target);
	status = update_pwd_vars(ms, old_pwd);
	return (status);
}
