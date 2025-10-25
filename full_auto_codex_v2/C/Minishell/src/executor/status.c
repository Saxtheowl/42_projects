#include "executor_internal.h"
#include <stdio.h>
#include <sys/wait.h>

int	ms_wait_status_to_exit(int status)
{
	if (WIFEXITED(status))
		return (WEXITSTATUS(status));
	if (WIFSIGNALED(status))
		return (128 + WTERMSIG(status));
	return (status);
}

int	ms_wait_for_pid(pid_t pid)
{
	int	status;

	if (waitpid(pid, &status, 0) < 0)
		return (perror("waitpid"), 1);
	return (ms_wait_status_to_exit(status));
}
