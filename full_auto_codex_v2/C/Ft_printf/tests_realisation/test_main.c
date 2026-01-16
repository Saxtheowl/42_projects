#include "ft_printf.h"

#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef int	(*t_vprinter)(const char *, va_list);

static char	*repeat_char(char c, size_t count)
{
	char	*result;

	result = malloc(count + 1);
	if (result == NULL)
		return (NULL);
	memset(result, c, count);
	result[count] = '\0';
	return (result);
}

static char	*join_format(const char *prefix, const char *suffix)
{
	size_t	len_prefix;
	size_t	len_suffix;
	char	*result;

	len_prefix = strlen(prefix);
	len_suffix = strlen(suffix);
	result = malloc(len_prefix + 2 + len_suffix + 1);
	if (result == NULL)
		return (NULL);
	memcpy(result, prefix, len_prefix);
	memcpy(result + len_prefix, "%d", 2);
	memcpy(result + len_prefix + 2, suffix, len_suffix);
	result[len_prefix + 2 + len_suffix] = '\0';
	return (result);
}

static int	read_all(int fd, char **out)
{
	char	buffer[256];
	char	*result;
	size_t	capacity;
	size_t	size;
	ssize_t	bytes;

	capacity = 256;
	size = 0;
	result = malloc(capacity);
	if (result == NULL)
		return (-1);
	while (1)
	{
		bytes = read(fd, buffer, sizeof(buffer));
		if (bytes < 0)
		{
			free(result);
			return (-1);
		}
		if (bytes == 0)
			break ;
		while (size + (size_t)bytes + 1 > capacity)
		{
			capacity *= 2;
			char *new_result = realloc(result, capacity);
			if (new_result == NULL)
			{
				free(result);
				return (-1);
			}
			result = new_result;
		}
		memcpy(result + size, buffer, (size_t)bytes);
		size += (size_t)bytes;
	}
	result[size] = '\0';
	*out = result;
	return (0);
}

static int	capture_vprinter(t_vprinter fn, const char *fmt, va_list *args,
		char **output, int *printed)
{
	int		pipefd[2];
	int		saved;
	va_list	copy;

	if (pipe(pipefd) == -1)
		return (-1);
	saved = dup(STDOUT_FILENO);
	if (saved == -1)
	{
		close(pipefd[0]);
		close(pipefd[1]);
		return (-1);
	}
	if (dup2(pipefd[1], STDOUT_FILENO) == -1)
	{
		close(pipefd[0]);
		close(pipefd[1]);
		close(saved);
		return (-1);
	}
	close(pipefd[1]);
	va_copy(copy, *args);
	errno = 0;
	*printed = fn(fmt, copy);
	va_end(copy);
	fflush(stdout);
	if (dup2(saved, STDOUT_FILENO) == -1)
	{
		close(pipefd[0]);
		close(saved);
		return (-1);
	}
	close(saved);
	if (read_all(pipefd[0], output) == -1)
	{
		close(pipefd[0]);
		return (-1);
	}
	close(pipefd[0]);
	return (0);
}

static char	*normalize_nil(const char *src)
{
	char	*result;
	size_t	i;
	size_t	j;

	result = malloc(strlen(src) + 1);
	if (result == NULL)
		return (NULL);
	i = 0;
	j = 0;
	while (src[i] != '\0')
	{
		if (src[i] == '(' && strncmp(&src[i], "(nil)", 5) == 0)
		{
			memcpy(&result[j], "0x0", 3);
			j += 3;
			i += 5;
		}
		else
			result[j++] = src[i++];
	}
	result[j] = '\0';
	return (result);
}

static int	check_case(int line, const char *fmt, ...)
{
	va_list	args;
	va_list	copy;
	char	*std_out;
	char	*ft_out;
	char	*std_norm;
	char	*ft_norm;
	int		std_ret;
	int		ft_ret;

	std_out = NULL;
	ft_out = NULL;
	va_start(args, fmt);
	va_copy(copy, args);
	if (capture_vprinter(vprintf, fmt, &args, &std_out, &std_ret) == -1
		|| capture_vprinter(ft_vprintf, fmt, &copy, &ft_out, &ft_ret) == -1)
	{
		va_end(args);
		va_end(copy);
		free(std_out);
		free(ft_out);
		fprintf(stderr, "[line %d] Error: failed to capture output\n", line);
		return (1);
	}
	va_end(args);
	va_end(copy);
	if (ft_ret != (int)strlen(ft_out))
		fprintf(stderr,
			"[line %d] Warning: ft_printf ret (%d) differs from strlen (%zu)\n",
			line, ft_ret, strlen(ft_out));
	if (std_ret != (int)strlen(std_out))
		fprintf(stderr,
			"[line %d] Warning: printf ret (%d) differs from strlen (%zu)\n",
			line, std_ret, strlen(std_out));
	std_norm = normalize_nil(std_out);
	ft_norm = normalize_nil(ft_out);
	if (std_norm == NULL || ft_norm == NULL)
	{
		fprintf(stderr, "[line %d] Error: normalization failure\n", line);
		free(std_out);
		free(ft_out);
		free(std_norm);
		free(ft_norm);
		return (1);
	}
	if (strcmp(std_norm, ft_norm) != 0)
	{
		fprintf(stderr, "[line %d] Mismatch:\n", line);
		fprintf(stderr, "  format: \"%s\"\n", fmt);
		fprintf(stderr, "  printf: ret=%d, out=\"%s\"\n", std_ret, std_out);
		fprintf(stderr, "  ft_printf: ret=%d, out=\"%s\"\n", ft_ret, ft_out);
		fprintf(stderr, "  normalized printf: \"%s\"\n", std_norm);
		fprintf(stderr, "  normalized ft_printf: \"%s\"\n", ft_norm);
		free(std_out);
		free(ft_out);
		free(std_norm);
		free(ft_norm);
		return (1);
	}
	free(std_out);
	free(ft_out);
	free(std_norm);
	free(ft_norm);
	return (0);
}

static int	check_write_failure(void)
{
	int	full_fd;
	int	saved;
	int	ret;

	full_fd = open("/dev/full", O_WRONLY);
	if (full_fd == -1)
	{
		fprintf(stderr,
			"Warning: /dev/full unavailable, skipping write failure test\n");
		return (0);
	}
	saved = dup(STDOUT_FILENO);
	if (saved == -1)
	{
		close(full_fd);
		return (1);
	}
	if (dup2(full_fd, STDOUT_FILENO) == -1)
	{
		close(full_fd);
		close(saved);
		return (1);
	}
	close(full_fd);
	ret = ft_printf("write failure test");
	if (dup2(saved, STDOUT_FILENO) == -1)
	{
		close(saved);
		return (1);
	}
	close(saved);
	if (ret != -1)
	{
		fprintf(stderr,
			"Expected ft_printf write failure to return -1, got %d\n", ret);
		return (1);
	}
	return (0);
}

#define CHECK(fmt, ...) \
	do { \
		if (check_case(__LINE__, fmt, ##__VA_ARGS__)) \
			return (1); \
	} while (0)

int	main(void)
{
	int marker;
	char *long_str;
	int ret;
	char *prefix;
	char *suffix;
	char *long_fmt;

	CHECK("");
	CHECK("simple string");
	CHECK("char: %c", 'A');
	CHECK("string: %s", "hello");
	CHECK("null string: %s", (char *)NULL);
	CHECK("percent: %%");
	CHECK("mixed percent: 100%% done");
	CHECK("integer: %d", 42);
	CHECK("negative: %i", -2147483648);
	CHECK("zero: %d %u %x", 0, 0u, 0u);
	CHECK("int max: %d", 2147483647);
	CHECK("uint max: %u", 4294967295u);
	CHECK("hex zero: %x %X", 0u, 0u);
	CHECK("hex uint max: %x %X", 0xffffffffu, 0xffffffffu);
	CHECK("unsigned: %u", 3000000000u);
	CHECK("unsigned -1: %u", (unsigned int)-1);
	CHECK("hex: %x", 0xabcdef);
	CHECK("HEX: %X", 0xABCDEF);
	CHECK("adjacent: %d%d%d", 1, 2, 3);
	CHECK("strings: %s%s%s", "a", "", "b");
	CHECK("percent chain: %%%%");
	CHECK("pointer stack: %p", (void *)&marker);
	CHECK("pointer: %p", (void *)0x1234abcd);
	CHECK("null ptr: %p", (void *)0);
	CHECK("pointers: %p %p", (void *)&marker, (void *)&ret);
	CHECK("mix: %c %s %d %u %x %%", 'X', "foo", -123, 456u, 0xbeef);
	long_str = repeat_char('a', 1500);
	if (long_str == NULL)
		return (1);
	CHECK("long string: %s", long_str);
	CHECK("long wrap %s end", long_str);
	free(long_str);
	prefix = repeat_char('p', 900);
	suffix = repeat_char('s', 900);
	if (prefix == NULL || suffix == NULL)
		return (1);
	long_fmt = join_format(prefix, suffix);
	if (long_fmt == NULL)
	{
		free(prefix);
		free(suffix);
		return (1);
	}
	CHECK(long_fmt, 12345);
	free(prefix);
	free(suffix);
	free(long_fmt);
	ret = ft_printf(NULL);
	if (ret != -1)
	{
		fprintf(stderr, "Expected ft_printf(NULL) = -1, got %d\n", ret);
		return (1);
	}
	if (check_write_failure())
		return (1);
	return (0);
}
