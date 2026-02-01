/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libasm.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

static void	test_strlen(void)
{
	const char	*tests[] = {"", "hello", "42 is nice", NULL};
	int			i;

	printf("=== Testing ft_strlen ===\n");
	i = 0;
	while (tests[i])
	{
		printf("ft_strlen(\"%s\") = %zu (expected: %zu) %s\n",
			tests[i], ft_strlen(tests[i]), strlen(tests[i]),
			ft_strlen(tests[i]) == strlen(tests[i]) ? "OK" : "FAIL");
		i++;
	}
	printf("\n");
}

static void	test_strcpy(void)
{
	char		buf1[100];
	char		buf2[100];
	const char	*tests[] = {"", "hello", "42 is nice!", NULL};
	int			i;

	printf("=== Testing ft_strcpy ===\n");
	i = 0;
	while (tests[i])
	{
		ft_strcpy(buf1, tests[i]);
		strcpy(buf2, tests[i]);
		printf("ft_strcpy(\"%s\") = \"%s\" (expected: \"%s\") %s\n",
			tests[i], buf1, buf2,
			strcmp(buf1, buf2) == 0 ? "OK" : "FAIL");
		i++;
	}
	printf("\n");
}

static void	test_strcmp(void)
{
	const char	*pairs[][2] = {
		{"abc", "abc"},
		{"abc", "abd"},
		{"abd", "abc"},
		{"", ""},
		{"a", ""},
		{"", "a"},
		{NULL, NULL}
	};
	int			i;
	int			my_res;
	int			std_res;

	printf("=== Testing ft_strcmp ===\n");
	i = 0;
	while (pairs[i][0])
	{
		my_res = ft_strcmp(pairs[i][0], pairs[i][1]);
		std_res = strcmp(pairs[i][0], pairs[i][1]);
		printf("ft_strcmp(\"%s\", \"%s\") = %d (expected: %d) %s\n",
			pairs[i][0], pairs[i][1], my_res, std_res,
			(my_res < 0 && std_res < 0) || (my_res > 0 && std_res > 0) ||
			(my_res == 0 && std_res == 0) ? "OK" : "FAIL");
		i++;
	}
	printf("\n");
}

static void	test_write(void)
{
	ssize_t		ret;

	printf("=== Testing ft_write ===\n");
	printf("Writing to stdout: ");
	ret = ft_write(1, "Hello, World!\n", 14);
	printf("ft_write returned: %zd\n", ret);
	
	errno = 0;
	ret = ft_write(-1, "test", 4);
	printf("ft_write(-1, ...) = %zd, errno = %d (EBADF=%d) %s\n",
		ret, errno, EBADF, errno == EBADF ? "OK" : "FAIL");
	printf("\n");
}

static void	test_read(void)
{
	ssize_t		ret;

	printf("=== Testing ft_read ===\n");
	errno = 0;
	ret = ft_read(-1, NULL, 0);
	printf("ft_read(-1, ...) = %zd, errno = %d (EBADF=%d) %s\n",
		ret, errno, EBADF, errno == EBADF ? "OK" : "FAIL");
	printf("\n");
}

static void	test_strdup(void)
{
	const char	*tests[] = {"", "hello", "42 is nice", NULL};
	char		*dup;
	int			i;

	printf("=== Testing ft_strdup ===\n");
	i = 0;
	while (tests[i])
	{
		dup = ft_strdup(tests[i]);
		printf("ft_strdup(\"%s\") = \"%s\" %s\n",
			tests[i], dup,
			strcmp(dup, tests[i]) == 0 ? "OK" : "FAIL");
		free(dup);
		i++;
	}
	printf("\n");
}

int	main(void)
{
	printf("=== LIBASM TESTS ===\n\n");
	test_strlen();
	test_strcpy();
	test_strcmp();
	test_write();
	test_read();
	test_strdup();
	printf("=== ALL TESTS COMPLETE ===\n");
	return (0);
}
