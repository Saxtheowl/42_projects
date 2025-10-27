#ifndef LIBUNIT_H
# define LIBUNIT_H

# include <stddef.h>

# define LIBUNIT_OK 0
# define LIBUNIT_KO 1
# define LIBUNIT_TIMEOUT_SECONDS 2

# define LIBUNIT_COLOR_RESET "\033[0m"
# define LIBUNIT_COLOR_GREEN "\033[32m"
# define LIBUNIT_COLOR_RED "\033[31m"
# define LIBUNIT_COLOR_YELLOW "\033[33m"

typedef struct s_unit_test
{
	char			*name;
	int			(*fn)(void);
	struct s_unit_test	*next;
}t_unit_test;

int	load_test(t_unit_test **list, const char *name, int (*fn)(void));
int	launch_tests(t_unit_test **list, const char *suite_name);
void	clear_tests(t_unit_test **list);

#endif
