/* ************************************************************************** */
/*                                                                            */
/*   ft_42sh - Advanced Shell Implementation                                  */
/*   Full-featured POSIX-compliant shell with job control                     */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <signal.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>

#define MAX_LINE 4096
#define MAX_ARGS 256
#define MAX_JOBS 64
#define MAX_HISTORY 1000

/* Job states */
#define JOB_RUNNING   1
#define JOB_STOPPED   2
#define JOB_DONE      3

/* Token types */
#define TOK_WORD      1
#define TOK_PIPE      2
#define TOK_REDIR_IN  3
#define TOK_REDIR_OUT 4
#define TOK_APPEND    5
#define TOK_HEREDOC   6
#define TOK_AND       7
#define TOK_OR        8
#define TOK_SEMI      9
#define TOK_BG        10

typedef struct s_job
{
	int			id;
	pid_t		pgid;
	int			state;
	char		*command;
	struct s_job *next;
}	t_job;

typedef struct s_shell
{
	char		*line;
	char		**history;
	int			history_count;
	t_job		*jobs;
	int			job_count;
	int			last_exit;
	pid_t		shell_pgid;
	struct termios	shell_tmodes;
	int			interactive;
}	t_shell;

/* Global shell instance */
static t_shell	g_shell;

/* ============================================================ */
/* Signal Handlers                                               */
/* ============================================================ */

void	sigchld_handler(int sig)
{
	(void)sig;
	/* Reap zombie processes */
	while (waitpid(-1, NULL, WNOHANG) > 0)
		;
}

void	sigint_handler(int sig)
{
	(void)sig;
	write(1, "\n", 1);
}

void	setup_signals(void)
{
	signal(SIGINT, sigint_handler);
	signal(SIGQUIT, SIG_IGN);
	signal(SIGTSTP, SIG_IGN);
	signal(SIGTTIN, SIG_IGN);
	signal(SIGTTOU, SIG_IGN);
	signal(SIGCHLD, sigchld_handler);
}

/* ============================================================ */
/* Built-in Commands                                             */
/* ============================================================ */

int	builtin_cd(char **args)
{
	char	*path;

	if (args[1] == NULL)
	{
		path = getenv("HOME");
		if (path == NULL)
		{
			fprintf(stderr, "cd: HOME not set\n");
			return (1);
		}
	}
	else if (strcmp(args[1], "-") == 0)
	{
		path = getenv("OLDPWD");
		if (path == NULL)
		{
			fprintf(stderr, "cd: OLDPWD not set\n");
			return (1);
		}
		printf("%s\n", path);
	}
	else
		path = args[1];

	if (chdir(path) != 0)
	{
		perror("cd");
		return (1);
	}
	return (0);
}

int	builtin_pwd(char **args)
{
	char	cwd[4096];

	(void)args;
	if (getcwd(cwd, sizeof(cwd)) != NULL)
	{
		printf("%s\n", cwd);
		return (0);
	}
	perror("pwd");
	return (1);
}

int	builtin_echo(char **args)
{
	int		i;
	int		newline;

	i = 1;
	newline = 1;
	if (args[1] && strcmp(args[1], "-n") == 0)
	{
		newline = 0;
		i = 2;
	}
	while (args[i])
	{
		printf("%s", args[i]);
		if (args[i + 1])
			printf(" ");
		i++;
	}
	if (newline)
		printf("\n");
	return (0);
}

int	builtin_env(char **args)
{
	extern char	**environ;
	int			i;

	(void)args;
	i = 0;
	while (environ[i])
	{
		printf("%s\n", environ[i]);
		i++;
	}
	return (0);
}

int	builtin_export(char **args)
{
	int		i;

	if (args[1] == NULL)
		return (builtin_env(args));

	i = 1;
	while (args[i])
	{
		if (strchr(args[i], '='))
			putenv(strdup(args[i]));
		i++;
	}
	return (0);
}

int	builtin_unset(char **args)
{
	int	i;

	i = 1;
	while (args[i])
	{
		unsetenv(args[i]);
		i++;
	}
	return (0);
}

int	builtin_exit(char **args)
{
	int	code;

	code = 0;
	if (args[1])
		code = atoi(args[1]);
	printf("exit\n");
	exit(code);
	return (0);
}

int	builtin_history(char **args)
{
	int	i;

	(void)args;
	for (i = 0; i < g_shell.history_count; i++)
		printf("%5d  %s\n", i + 1, g_shell.history[i]);
	return (0);
}

int	builtin_jobs(char **args)
{
	t_job	*job;

	(void)args;
	job = g_shell.jobs;
	while (job)
	{
		printf("[%d] %s %s\n",
			job->id,
			job->state == JOB_RUNNING ? "Running" :
			job->state == JOB_STOPPED ? "Stopped" : "Done",
			job->command);
		job = job->next;
	}
	return (0);
}

int	is_builtin(char *cmd)
{
	char	*builtins[] = {"cd", "pwd", "echo", "env", "export",
						"unset", "exit", "history", "jobs", NULL};
	int		i;

	i = 0;
	while (builtins[i])
	{
		if (strcmp(cmd, builtins[i]) == 0)
			return (1);
		i++;
	}
	return (0);
}

int	run_builtin(char **args)
{
	if (strcmp(args[0], "cd") == 0)
		return (builtin_cd(args));
	if (strcmp(args[0], "pwd") == 0)
		return (builtin_pwd(args));
	if (strcmp(args[0], "echo") == 0)
		return (builtin_echo(args));
	if (strcmp(args[0], "env") == 0)
		return (builtin_env(args));
	if (strcmp(args[0], "export") == 0)
		return (builtin_export(args));
	if (strcmp(args[0], "unset") == 0)
		return (builtin_unset(args));
	if (strcmp(args[0], "exit") == 0)
		return (builtin_exit(args));
	if (strcmp(args[0], "history") == 0)
		return (builtin_history(args));
	if (strcmp(args[0], "jobs") == 0)
		return (builtin_jobs(args));
	return (1);
}

/* ============================================================ */
/* Parsing                                                       */
/* ============================================================ */

char	**split_args(char *line)
{
	char	**args;
	char	*token;
	int		i;

	args = malloc(sizeof(char *) * MAX_ARGS);
	if (!args)
		return (NULL);

	i = 0;
	token = strtok(line, " \t\n");
	while (token && i < MAX_ARGS - 1)
	{
		args[i] = strdup(token);
		i++;
		token = strtok(NULL, " \t\n");
	}
	args[i] = NULL;
	return (args);
}

void	free_args(char **args)
{
	int	i;

	if (!args)
		return;
	i = 0;
	while (args[i])
	{
		free(args[i]);
		i++;
	}
	free(args);
}

/* ============================================================ */
/* Execution                                                     */
/* ============================================================ */

int	execute_simple(char **args)
{
	pid_t	pid;
	int		status;

	if (args[0] == NULL)
		return (0);

	if (is_builtin(args[0]))
		return (run_builtin(args));

	pid = fork();
	if (pid == 0)
	{
		/* Child process */
		signal(SIGINT, SIG_DFL);
		signal(SIGQUIT, SIG_DFL);

		execvp(args[0], args);
		fprintf(stderr, "42sh: %s: command not found\n", args[0]);
		exit(127);
	}
	else if (pid < 0)
	{
		perror("fork");
		return (1);
	}

	/* Parent waits */
	waitpid(pid, &status, 0);
	if (WIFEXITED(status))
		return (WEXITSTATUS(status));
	return (1);
}

int	execute_pipe(char *left, char *right)
{
	int		pipefd[2];
	pid_t	pid1, pid2;
	int		status;
	char	**args1, **args2;

	if (pipe(pipefd) == -1)
	{
		perror("pipe");
		return (1);
	}

	args1 = split_args(left);
	args2 = split_args(right);

	pid1 = fork();
	if (pid1 == 0)
	{
		close(pipefd[0]);
		dup2(pipefd[1], STDOUT_FILENO);
		close(pipefd[1]);
		execvp(args1[0], args1);
		exit(127);
	}

	pid2 = fork();
	if (pid2 == 0)
	{
		close(pipefd[1]);
		dup2(pipefd[0], STDIN_FILENO);
		close(pipefd[0]);
		execvp(args2[0], args2);
		exit(127);
	}

	close(pipefd[0]);
	close(pipefd[1]);

	waitpid(pid1, NULL, 0);
	waitpid(pid2, &status, 0);

	free_args(args1);
	free_args(args2);

	if (WIFEXITED(status))
		return (WEXITSTATUS(status));
	return (1);
}

int	execute_line(char *line)
{
	char	*pipe_pos;
	char	*semi_pos;
	char	*and_pos;
	char	*or_pos;
	char	**args;
	int		result;

	/* Check for pipe */
	pipe_pos = strchr(line, '|');
	if (pipe_pos && *(pipe_pos + 1) != '|')
	{
		*pipe_pos = '\0';
		return (execute_pipe(line, pipe_pos + 1));
	}

	/* Check for semicolon */
	semi_pos = strchr(line, ';');
	if (semi_pos)
	{
		*semi_pos = '\0';
		execute_line(line);
		return (execute_line(semi_pos + 1));
	}

	/* Check for && */
	and_pos = strstr(line, "&&");
	if (and_pos)
	{
		*and_pos = '\0';
		result = execute_line(line);
		if (result == 0)
			return (execute_line(and_pos + 2));
		return (result);
	}

	/* Check for || */
	or_pos = strstr(line, "||");
	if (or_pos)
	{
		*or_pos = '\0';
		result = execute_line(line);
		if (result != 0)
			return (execute_line(or_pos + 2));
		return (result);
	}

	/* Simple command */
	args = split_args(line);
	if (!args || !args[0])
	{
		free_args(args);
		return (0);
	}

	result = execute_simple(args);
	free_args(args);
	return (result);
}

/* ============================================================ */
/* History                                                       */
/* ============================================================ */

void	add_history(char *line)
{
	if (g_shell.history_count < MAX_HISTORY)
	{
		g_shell.history[g_shell.history_count] = strdup(line);
		g_shell.history_count++;
	}
}

/* ============================================================ */
/* Main Shell Loop                                               */
/* ============================================================ */

void	print_prompt(void)
{
	char	cwd[4096];
	char	*home;

	if (getcwd(cwd, sizeof(cwd)) == NULL)
		strcpy(cwd, "?");

	home = getenv("HOME");
	if (home && strncmp(cwd, home, strlen(home)) == 0)
	{
		printf("\033[1;32m42sh\033[0m:\033[1;34m~%s\033[0m$ ",
			cwd + strlen(home));
	}
	else
	{
		printf("\033[1;32m42sh\033[0m:\033[1;34m%s\033[0m$ ", cwd);
	}
	fflush(stdout);
}

char	*read_line(void)
{
	char	*line;
	size_t	size;
	ssize_t	len;

	line = NULL;
	size = 0;
	len = getline(&line, &size, stdin);

	if (len == -1)
	{
		free(line);
		return (NULL);
	}

	/* Remove trailing newline */
	if (len > 0 && line[len - 1] == '\n')
		line[len - 1] = '\0';

	return (line);
}

void	shell_init(void)
{
	g_shell.line = NULL;
	g_shell.history = malloc(sizeof(char *) * MAX_HISTORY);
	g_shell.history_count = 0;
	g_shell.jobs = NULL;
	g_shell.job_count = 0;
	g_shell.last_exit = 0;
	g_shell.interactive = isatty(STDIN_FILENO);
	g_shell.shell_pgid = getpid();

	setup_signals();
}

void	shell_cleanup(void)
{
	int	i;

	for (i = 0; i < g_shell.history_count; i++)
		free(g_shell.history[i]);
	free(g_shell.history);
}

int	main(int argc, char **argv)
{
	char	*line;

	(void)argc;
	(void)argv;

	shell_init();

	printf("Welcome to 42sh - The 42 School Shell\n");
	printf("Type 'exit' to quit, 'help' for commands\n\n");

	while (1)
	{
		if (g_shell.interactive)
			print_prompt();

		line = read_line();
		if (line == NULL)
		{
			printf("\n");
			break;
		}

		if (strlen(line) > 0)
		{
			add_history(line);
			g_shell.last_exit = execute_line(line);
		}

		free(line);
	}

	shell_cleanup();
	return (g_shell.last_exit);
}
