/* ************************************************************************** */
/*                                                                            */
/*   libunit.h - Unit testing library header                                  */
/*                                                                            */
/* ************************************************************************** */

#ifndef LIBUNIT_H
# define LIBUNIT_H

/* Test result codes */
# define TEST_SUCCESS 0
# define TEST_FAILURE 1
# define TEST_TIMEOUT 2
# define TEST_SIGNAL  3

/* Test structure (opaque) */
typedef struct s_test	t_test;
typedef struct s_suite	t_suite;

/* Suite management */
t_suite	*ut_create_suite(const char *name);
void	ut_add_test(t_suite *suite, const char *name, int (*func)(void));
int		ut_run_all(void);
void	ut_cleanup(void);

/* Assertions */
void	ut_assert(int condition, const char *message);
void	ut_assert_eq(int expected, int actual, const char *name);
void	ut_assert_str_eq(const char *expected, const char *actual, const char *name);
void	ut_assert_null(void *ptr, const char *name);
void	ut_assert_not_null(void *ptr, const char *name);

/* Convenience macros */
# define ASSERT(cond)           ut_assert((cond), #cond)
# define ASSERT_EQ(exp, act)    ut_assert_eq((exp), (act), #exp " == " #act)
# define ASSERT_STR_EQ(exp, act) ut_assert_str_eq((exp), (act), #exp " == " #act)
# define ASSERT_NULL(ptr)       ut_assert_null((ptr), #ptr " is NULL")
# define ASSERT_NOT_NULL(ptr)   ut_assert_not_null((ptr), #ptr " is not NULL")

#endif
