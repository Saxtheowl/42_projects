#include "libunit.h"

#include <stdlib.h>
#include <unistd.h>

static int	test_returns_fail(void)
{
	return (1);
}

static int	test_segfault(void)
{
	int	*ptr;

	ptr = NULL;
	*ptr = 42;
	return (LIBUNIT_OK);
}

static int	test_timeout(void)
{
	sleep(LIBUNIT_TIMEOUT_SECONDS + 1);
	return (LIBUNIT_OK);
}

int	main(void)
{
	t_unit_test	*tests;
	int			failures;

	tests = NULL;
	if (load_test(&tests, "Return failure", &test_returns_fail) != 0)
		return (EXIT_FAILURE);
	if (load_test(&tests, "Segfault", &test_segfault) != 0)
	{
		clear_tests(&tests);
		return (EXIT_FAILURE);
	}
	if (load_test(&tests, "Timeout", &test_timeout) != 0)
	{
		clear_tests(&tests);
		return (EXIT_FAILURE);
	}
	failures = launch_tests(&tests, "Failure Suite");
	if (failures == 3)
		return (EXIT_SUCCESS);
	return (EXIT_FAILURE);
}
