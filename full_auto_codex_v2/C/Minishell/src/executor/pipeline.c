#include "executor_internal.h"
#include <stdio.h>
#include <sys/wait.h>
#include <unistd.h>

typedef struct s_pipe_role
{
	int	from;
	int	to;
	int	close_fd;
}	t_pipe_role;

static t_pipe_role	pipeline_role(int pipefd[2], int is_left)
{
	t_pipe_role	role;

	if (is_left)
	{
		role.from = pipefd[1];
		role.to = STDOUT_FILENO;
		role.close_fd = pipefd[0];
		return (role);
	}
	role.from = pipefd[0];
	role.to = STDIN_FILENO;
	role.close_fd = pipefd[1];
	return (role);
}

static void	run_pipeline_child(t_ms *ms, t_ast *node,
				int pipefd[2], int is_left)
{
	t_pipe_role	role;
	int			status;

	role = pipeline_role(pipefd, is_left);
	ms_configure_signals_child();
	if (dup2(role.from, role.to) < 0)
	{
		perror("dup2");
		_exit(1);
	}
	close(role.from);
	close(role.close_fd);
	status = ms_execute_ast_node(ms, node, 1);
	if (status < 0)
		status = 1;
	_exit(status);
}

static pid_t	launch_pipeline_child(t_ms *ms, t_ast *node,
				int pipefd[2], int is_left)
{
	pid_t	pid;

	pid = fork();
	if (pid < 0)
	{
		perror("fork");
		return (-1);
	}
	if (pid == 0)
		run_pipeline_child(ms, node, pipefd, is_left);
	return (pid);
}

static int	wait_pipeline_children(pid_t left_pid, pid_t right_pid,
				int *status_right)
{
	int	status_left;

	if (waitpid(left_pid, &status_left, 0) < 0)
		perror("waitpid");
	if (waitpid(right_pid, status_right, 0) < 0)
	{
		perror("waitpid");
		return (1);
	}
	return (0);
}

int	ms_execute_pipeline(t_ms *ms, t_ast *left, t_ast *right)
{
	int		pipefd[2];
	pid_t	left_pid;
	pid_t	right_pid;
	int		status_right;

	if (pipe(pipefd) < 0)
		return (perror("pipe"), 1);
	left_pid = launch_pipeline_child(ms, left, pipefd, 1);
	if (left_pid < 0)
		return (close(pipefd[0]), close(pipefd[1]), 1);
	right_pid = launch_pipeline_child(ms, right, pipefd, 0);
	if (right_pid < 0)
		return (close(pipefd[0]), close(pipefd[1]), 1);
	close(pipefd[0]);
	close(pipefd[1]);
	if (wait_pipeline_children(left_pid, right_pid, &status_right))
		return (1);
	return (ms_wait_status_to_exit(status_right));
}
