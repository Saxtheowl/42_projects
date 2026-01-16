#include "libft.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int	check_int(const char *label, int got, int expected)
{
	if (got != expected)
	{
		fprintf(stderr, "[FAIL] %s: got=%d expected=%d\n", label, got, expected);
		return (1);
	}
	return (0);
}

static int	check_size(const char *label, size_t got, size_t expected)
{
	if (got != expected)
	{
		fprintf(stderr, "[FAIL] %s: got=%zu expected=%zu\n", label, got, expected);
		return (1);
	}
	return (0);
}

static int	check_str(const char *label, const char *got, const char *expected)
{
	if ((got == NULL && expected != NULL) || (got != NULL && expected == NULL))
	{
		fprintf(stderr, "[FAIL] %s: null mismatch\n", label);
		return (1);
	}
	if (got && expected && strcmp(got, expected) != 0)
	{
		fprintf(stderr, "[FAIL] %s: got=\"%s\" expected=\"%s\"\n",
			label, got, expected);
		return (1);
	}
	return (0);
}

static void	free_split(char **items)
{
	size_t	i;

	if (!items)
		return;
	i = 0;
	while (items[i])
	{
		free(items[i]);
		i++;
	}
	free(items);
}

int	main(void)
{
	int		failures;
	char	buffer[32];
	char	*dup;
	char	*trim;
	char	*itoa_str;
	char	**split;

	failures = 0;
	failures += check_size("ft_strlen", ft_strlen("libft"), 5);
	memset(buffer, 'X', sizeof(buffer));
	ft_strlcpy(buffer, "abc", sizeof(buffer));
	failures += check_str("ft_strlcpy", buffer, "abc");
	ft_memmove(buffer + 2, buffer, 3);
	buffer[5] = '\0';
	failures += check_str("ft_memmove overlap", buffer, "ababc");
	dup = ft_strdup("hello");
	failures += check_str("ft_strdup", dup, "hello");
	free(dup);
	failures += check_int("ft_atoi", ft_atoi("  -42"), -42);
	trim = ft_strtrim("  hello  ", " ");
	failures += check_str("ft_strtrim", trim, "hello");
	free(trim);
	itoa_str = ft_itoa(-1234);
	failures += check_str("ft_itoa", itoa_str, "-1234");
	free(itoa_str);
	split = ft_split("a,,b", ',');
	if (!split || !split[0] || !split[1] || split[2])
	{
		fprintf(stderr, "[FAIL] ft_split structure invalid\n");
		failures++;
	}
	else
	{
		failures += check_str("ft_split[0]", split[0], "a");
		failures += check_str("ft_split[1]", split[1], "b");
	}
	free_split(split);
	if (failures == 0)
		printf("All tests passed.\n");
	return (failures != 0);
}
