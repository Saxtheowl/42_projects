/* ************************************************************************** */
/*                                                                            */
/*   libunit - Unit testing library for C                                     */
/*   Simple test framework with assertions and test suites                    */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <setjmp.h>
#include <sys/wait.h>
#include <unistd.h>

/* Colors */
#define GREEN  "\033[32m"
#define RED    "\033[31m"
#define YELLOW "\033[33m"
#define RESET  "\033[0m"

/* Test result codes */
#define TEST_SUCCESS 0
#define TEST_FAILURE 1
#define TEST_TIMEOUT 2
#define TEST_SIGNAL  3

/* Test structure */
typedef struct s_test
{
	char			*name;
	int				(*func)(void);
	struct s_test	*next;
}	t_test;

/* Test suite structure */
typedef struct s_suite
{
	char			*name;
	t_test			*tests;
	int				total;
	int				passed;
	int				failed;
	struct s_suite	*next;
}	t_suite;

/* Global state */
static t_suite	*g_suites = NULL;
static jmp_buf	g_jump_buffer;
static int		g_assertion_failed = 0;

/* ========== Assertion functions ========== */

void	ut_assert(int condition, const char *message)
{
	if (!condition)
	{
		fprintf(stderr, "    " RED "ASSERTION FAILED: %s" RESET "\n", message);
		g_assertion_failed = 1;
		longjmp(g_jump_buffer, 1);
	}
}

void	ut_assert_eq(int expected, int actual, const char *name)
{
	if (expected != actual)
	{
		fprintf(stderr, "    " RED "ASSERT_EQ FAILED: %s" RESET "\n", name);
		fprintf(stderr, "      Expected: %d, Actual: %d\n", expected, actual);
		g_assertion_failed = 1;
		longjmp(g_jump_buffer, 1);
	}
}

void	ut_assert_str_eq(const char *expected, const char *actual, const char *name)
{
	if ((expected == NULL && actual != NULL) ||
		(expected != NULL && actual == NULL) ||
		(expected != NULL && actual != NULL && strcmp(expected, actual) != 0))
	{
		fprintf(stderr, "    " RED "ASSERT_STR_EQ FAILED: %s" RESET "\n", name);
		fprintf(stderr, "      Expected: \"%s\", Actual: \"%s\"\n",
				expected ? expected : "(null)",
				actual ? actual : "(null)");
		g_assertion_failed = 1;
		longjmp(g_jump_buffer, 1);
	}
}

void	ut_assert_null(void *ptr, const char *name)
{
	if (ptr != NULL)
	{
		fprintf(stderr, "    " RED "ASSERT_NULL FAILED: %s" RESET "\n", name);
		g_assertion_failed = 1;
		longjmp(g_jump_buffer, 1);
	}
}

void	ut_assert_not_null(void *ptr, const char *name)
{
	if (ptr == NULL)
	{
		fprintf(stderr, "    " RED "ASSERT_NOT_NULL FAILED: %s" RESET "\n", name);
		g_assertion_failed = 1;
		longjmp(g_jump_buffer, 1);
	}
}

/* ========== Suite management ========== */

t_suite	*ut_create_suite(const char *name)
{
	t_suite	*suite;

	suite = malloc(sizeof(t_suite));
	if (!suite)
		return (NULL);
	suite->name = strdup(name);
	suite->tests = NULL;
	suite->total = 0;
	suite->passed = 0;
	suite->failed = 0;
	suite->next = NULL;

	/* Add to global list */
	if (!g_suites)
		g_suites = suite;
	else
	{
		t_suite *last = g_suites;
		while (last->next)
			last = last->next;
		last->next = suite;
	}
	return (suite);
}

void	ut_add_test(t_suite *suite, const char *name, int (*func)(void))
{
	t_test	*test;

	if (!suite)
		return;

	test = malloc(sizeof(t_test));
	if (!test)
		return;
	test->name = strdup(name);
	test->func = func;
	test->next = NULL;

	if (!suite->tests)
		suite->tests = test;
	else
	{
		t_test *last = suite->tests;
		while (last->next)
			last = last->next;
		last->next = test;
	}
	suite->total++;
}

/* ========== Test execution ========== */

static int	run_test_in_fork(int (*func)(void))
{
	pid_t	pid;
	int		status;
	int		result;

	pid = fork();
	if (pid < 0)
		return (TEST_FAILURE);

	if (pid == 0)
	{
		/* Child process */
		g_assertion_failed = 0;
		if (setjmp(g_jump_buffer) == 0)
		{
			result = func();
			exit(g_assertion_failed ? TEST_FAILURE : result);
		}
		else
		{
			exit(TEST_FAILURE);
		}
	}

	/* Parent process */
	waitpid(pid, &status, 0);

	if (WIFEXITED(status))
		return (WEXITSTATUS(status));
	if (WIFSIGNALED(status))
		return (TEST_SIGNAL);
	return (TEST_FAILURE);
}

static void	run_suite(t_suite *suite)
{
	t_test	*test;
	int		result;

	printf("\n" YELLOW "=== Suite: %s ===" RESET "\n", suite->name);

	test = suite->tests;
	while (test)
	{
		printf("  [%s] ", test->name);
		fflush(stdout);

		result = run_test_in_fork(test->func);

		switch (result)
		{
			case TEST_SUCCESS:
				printf(GREEN "[OK]" RESET "\n");
				suite->passed++;
				break;
			case TEST_FAILURE:
				printf(RED "[KO]" RESET "\n");
				suite->failed++;
				break;
			case TEST_SIGNAL:
				printf(RED "[CRASH]" RESET "\n");
				suite->failed++;
				break;
			case TEST_TIMEOUT:
				printf(RED "[TIMEOUT]" RESET "\n");
				suite->failed++;
				break;
			default:
				printf(RED "[ERROR]" RESET "\n");
				suite->failed++;
		}
		test = test->next;
	}

	printf("  Results: %d/%d passed\n", suite->passed, suite->total);
}

int	ut_run_all(void)
{
	t_suite	*suite;
	int		total_passed = 0;
	int		total_failed = 0;

	printf("\n" YELLOW "====== LIBUNIT TEST RUNNER ======" RESET "\n");

	suite = g_suites;
	while (suite)
	{
		run_suite(suite);
		total_passed += suite->passed;
		total_failed += suite->failed;
		suite = suite->next;
	}

	printf("\n" YELLOW "====== SUMMARY ======" RESET "\n");
	printf("Total: %d passed, %d failed\n", total_passed, total_failed);

	if (total_failed == 0)
		printf(GREEN "All tests passed!" RESET "\n");
	else
		printf(RED "Some tests failed!" RESET "\n");

	return (total_failed > 0 ? 1 : 0);
}

/* ========== Cleanup ========== */

void	ut_cleanup(void)
{
	t_suite	*suite;
	t_suite	*next_suite;
	t_test	*test;
	t_test	*next_test;

	suite = g_suites;
	while (suite)
	{
		test = suite->tests;
		while (test)
		{
			next_test = test->next;
			free(test->name);
			free(test);
			test = next_test;
		}
		next_suite = suite->next;
		free(suite->name);
		free(suite);
		suite = next_suite;
	}
	g_suites = NULL;
}

/* ========== Demo tests ========== */

#ifdef DEMO_TESTS

static int	test_addition(void)
{
	ut_assert_eq(4, 2 + 2, "2 + 2 should equal 4");
	ut_assert_eq(10, 5 + 5, "5 + 5 should equal 10");
	return (TEST_SUCCESS);
}

static int	test_subtraction(void)
{
	ut_assert_eq(0, 5 - 5, "5 - 5 should equal 0");
	ut_assert_eq(-5, 0 - 5, "0 - 5 should equal -5");
	return (TEST_SUCCESS);
}

static int	test_string(void)
{
	ut_assert_str_eq("hello", "hello", "strings should match");
	ut_assert_not_null("test", "non-null string");
	return (TEST_SUCCESS);
}

static int	test_failure(void)
{
	ut_assert_eq(1, 2, "this test should fail");
	return (TEST_SUCCESS);
}

static int	test_crash(void)
{
	int	*ptr = NULL;
	*ptr = 42;  /* Segfault */
	return (TEST_SUCCESS);
}

int	main(void)
{
	t_suite	*math_suite;
	t_suite	*string_suite;
	t_suite	*edge_suite;

	printf("libunit Demo\n");

	/* Create suites */
	math_suite = ut_create_suite("Math Operations");
	ut_add_test(math_suite, "addition", test_addition);
	ut_add_test(math_suite, "subtraction", test_subtraction);

	string_suite = ut_create_suite("String Operations");
	ut_add_test(string_suite, "string_compare", test_string);

	edge_suite = ut_create_suite("Edge Cases");
	ut_add_test(edge_suite, "expected_failure", test_failure);
	ut_add_test(edge_suite, "crash_handling", test_crash);

	/* Run all tests */
	int result = ut_run_all();

	/* Cleanup */
	ut_cleanup();

	return (result);
}

#endif
