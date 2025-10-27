#include "libunit.h"

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

static const char	*signal_to_string(int sig)
{
	if (sig == SIGSEGV)
		return ("SIGSEGV");
	if (sig == SIGBUS)
		return ("SIGBUS");
	if (sig == SIGABRT)
		return ("SIGABRT");
	if (sig == SIGFPE)
		return ("SIGFPE");
	if (sig == SIGILL)
		return ("SIGILL");
	if (sig == SIGALRM)
		return ("SIGALRM");
	return ("SIGNAL");
}

static void	print_ok(const char *name)
{
	printf("  %s[OK]%s %s\n", LIBUNIT_COLOR_GREEN, LIBUNIT_COLOR_RESET, name);
	fflush(stdout);
}

static void	print_ko(const char *name, const char *reason)
{
	printf("  %s[KO]%s %s (%s)\n", LIBUNIT_COLOR_RED, LIBUNIT_COLOR_RESET, name, reason);
	fflush(stdout);
}

static void	exec_child(const t_unit_test *test)
{
	alarm(LIBUNIT_TIMEOUT_SECONDS);
	exit(test->fn() == LIBUNIT_OK ? EXIT_SUCCESS : EXIT_FAILURE);
}

static int	handle_status(const t_unit_test *test, int status)
{
	if (WIFEXITED(status))
	{
		int code = WEXITSTATUS(status);
		if (code == EXIT_SUCCESS)
		{
			print_ok(test->name);
			return (0);
		}
		print_ko(test->name, "EXIT_FAILURE");
		return (1);
	}
	if (WIFSIGNALED(status))
	{
		int sig = WTERMSIG(status);
		print_ko(test->name, signal_to_string(sig));
		return (1);
	}
	print_ko(test->name, "UNKNOWN_STATUS");
	return (1);
}

int	launch_tests(t_unit_test **list, const char *suite_name)
{
	t_unit_test	*test;
	int			failures;
	int			total;

	if (list == NULL)
		return (-1);
	test = *list;
	failures = 0;
	total = 0;
printf("=== %s ===\n", suite_name ? suite_name : "libunit" );
fflush(stdout);
	while (test != NULL)
	{
	pid_t pid = fork();
		if (pid < 0)
		{
			char buffer[128];
			snprintf(buffer, sizeof(buffer), "fork error: %s", strerror(errno));
			print_ko(test->name, buffer);
			failures++;
		}
		else if (pid == 0)
			exec_child(test);
		else
		{
			int status;
			if (waitpid(pid, &status, 0) == -1)
			{
				char buffer[128];
				snprintf(buffer, sizeof(buffer), "waitpid error: %s", strerror(errno));
				print_ko(test->name, buffer);
				failures++;
			}
			else
				failures += handle_status(test, status);
		}
		total++;
		test = test->next;
	}
	printf("%s%d%s/%d tests passed\n", LIBUNIT_COLOR_GREEN, total - failures,
		LIBUNIT_COLOR_RESET, total);
	clear_tests(list);
	return (failures);
}
