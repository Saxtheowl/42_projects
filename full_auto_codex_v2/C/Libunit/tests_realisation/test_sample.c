#include "libunit.h"

#include <stdlib.h>

static int	test_success_one(void)
{
	return (LIBUNIT_OK);
}

static int	test_success_two(void)
{
	return (LIBUNIT_OK);
}

int	main(void)
{
	t_unit_test	*tests;
	int			failures;

	tests = NULL;
	if (load_test(&tests, "Simple success 1", &test_success_one) != 0)
		return (EXIT_FAILURE);
	if (load_test(&tests, "Simple success 2", &test_success_two) != 0)
	{
		clear_tests(&tests);
		return (EXIT_FAILURE);
	}
	failures = launch_tests(&tests, "Sample Suite");
	return (failures == 0 ? EXIT_SUCCESS : EXIT_FAILURE);
}
