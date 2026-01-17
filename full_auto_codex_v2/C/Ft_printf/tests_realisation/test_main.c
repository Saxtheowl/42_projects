#include "ft_printf.h"

#include <errno.h>
#include <fcntl.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef int	(*t_vprinter)(const char *, va_list);

typedef struct s_capture
{
	char	*data;
	size_t	size;
}	t_capture;

static int	g_checks;
static int	g_raw_checks;

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

static int	read_all(int fd, t_capture *out)
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
	out->data = result;
	out->size = size;
	return (0);
}

static int	capture_vprinter(t_vprinter fn, const char *fmt, va_list *args,
		t_capture *output, int *printed)
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

static int	contains_nul(const t_capture *cap)
{
	return (memchr(cap->data, '\0', cap->size) != NULL);
}

static void	print_hex(const char *label, const t_capture *cap, size_t max)
{
	size_t	i;
	size_t	limit;

	limit = cap->size;
	if (limit > max)
		limit = max;
	fprintf(stderr, "  %s (%zu bytes):", label, cap->size);
	i = 0;
	while (i < limit)
	{
		fprintf(stderr, " %02x", (unsigned char)cap->data[i]);
		i++;
	}
	if (cap->size > max)
		fprintf(stderr, " ...");
	fprintf(stderr, "\n");
}

static ssize_t	first_diff_index(const t_capture *a, const t_capture *b)
{
	size_t	i;
	size_t	limit;

	limit = a->size;
	if (b->size < limit)
		limit = b->size;
	i = 0;
	while (i < limit)
	{
		if (a->data[i] != b->data[i])
			return ((ssize_t)i);
		i++;
	}
	if (a->size != b->size)
		return ((ssize_t)limit);
	return (-1);
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
	t_capture	std_out;
	t_capture	ft_out;
	char	*std_norm;
	char	*ft_norm;
	int		std_ret;
	int		ft_ret;

	std_out.data = NULL;
	ft_out.data = NULL;
	va_start(args, fmt);
	va_copy(copy, args);
	if (capture_vprinter(vprintf, fmt, &args, &std_out, &std_ret) == -1
		|| capture_vprinter(ft_vprintf, fmt, &copy, &ft_out, &ft_ret) == -1)
	{
		va_end(args);
		va_end(copy);
		free(std_out.data);
		free(ft_out.data);
		fprintf(stderr, "[line %d] Error: failed to capture output\n", line);
		return (1);
	}
	va_end(args);
	va_end(copy);
	if (std_ret != (int)std_out.size)
		fprintf(stderr,
			"[line %d] Warning: printf ret (%d) differs from size (%zu)\n",
			line, std_ret, std_out.size);
	if (ft_ret != (int)ft_out.size)
		fprintf(stderr,
			"[line %d] Warning: ft_printf ret (%d) differs from size (%zu)\n",
			line, ft_ret, ft_out.size);
	if (contains_nul(&std_out) || contains_nul(&ft_out))
	{
		fprintf(stderr,
			"[line %d] Error: NUL byte in output, use raw checker\n", line);
		free(std_out.data);
		free(ft_out.data);
		return (1);
	}
	std_norm = normalize_nil(std_out.data);
	ft_norm = normalize_nil(ft_out.data);
	if (std_norm == NULL || ft_norm == NULL)
	{
		fprintf(stderr, "[line %d] Error: normalization failure\n", line);
		free(std_out.data);
		free(ft_out.data);
		free(std_norm);
		free(ft_norm);
		return (1);
	}
	if (strcmp(std_norm, ft_norm) != 0)
	{
		fprintf(stderr, "[line %d] Mismatch:\n", line);
		fprintf(stderr, "  format: \"%s\"\n", fmt);
		fprintf(stderr, "  printf: ret=%d, out=\"%s\"\n",
			std_ret, std_out.data);
		fprintf(stderr, "  ft_printf: ret=%d, out=\"%s\"\n",
			ft_ret, ft_out.data);
		fprintf(stderr, "  normalized printf: \"%s\"\n", std_norm);
		fprintf(stderr, "  normalized ft_printf: \"%s\"\n", ft_norm);
		free(std_out.data);
		free(ft_out.data);
		free(std_norm);
		free(ft_norm);
		return (1);
	}
	if (std_ret != ft_ret
		&& strstr(std_out.data, "(nil)") == NULL
		&& strstr(ft_out.data, "(nil)") == NULL)
		fprintf(stderr,
			"[line %d] Warning: return mismatch (printf=%d, ft_printf=%d)\n",
			line, std_ret, ft_ret);
	free(std_out.data);
	free(ft_out.data);
	free(std_norm);
	free(ft_norm);
	return (0);
}

static int	check_case_raw(int line, const char *fmt, ...)
{
	va_list	args;
	va_list	copy;
	t_capture	std_out;
	t_capture	ft_out;
	int		std_ret;
	int		ft_ret;

	std_out.data = NULL;
	ft_out.data = NULL;
	va_start(args, fmt);
	va_copy(copy, args);
	if (capture_vprinter(vprintf, fmt, &args, &std_out, &std_ret) == -1
		|| capture_vprinter(ft_vprintf, fmt, &copy, &ft_out, &ft_ret) == -1)
	{
		va_end(args);
		va_end(copy);
		free(std_out.data);
		free(ft_out.data);
		fprintf(stderr, "[line %d] Error: failed to capture output\n", line);
		return (1);
	}
	va_end(args);
	va_end(copy);
	if (ft_ret != (int)ft_out.size || std_ret != (int)std_out.size)
		fprintf(stderr,
			"[line %d] Warning: return differs from size (printf=%d/%zu, "
			"ft_printf=%d/%zu)\n", line, std_ret, std_out.size,
			ft_ret, ft_out.size);
	if (std_out.size != ft_out.size
		|| memcmp(std_out.data, ft_out.data, std_out.size) != 0)
	{
		ssize_t	diff;

		diff = first_diff_index(&std_out, &ft_out);
		fprintf(stderr, "[line %d] Binary mismatch (size %zu vs %zu)\n",
			line, std_out.size, ft_out.size);
		if (diff >= 0)
			fprintf(stderr, "  first diff index: %zd\n", diff);
		print_hex("printf", &std_out, 64);
		print_hex("ft_printf", &ft_out, 64);
		free(std_out.data);
		free(ft_out.data);
		return (1);
	}
	free(std_out.data);
	free(ft_out.data);
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
		g_checks++; \
		if (check_case(__LINE__, fmt, ##__VA_ARGS__)) \
			return (1); \
	} while (0)

#define CHECK_RAW(fmt, ...) \
	do { \
		g_raw_checks++; \
		if (check_case_raw(__LINE__, fmt, ##__VA_ARGS__)) \
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
	CHECK("null string mid: start %s end", (char *)NULL);
	CHECK("double null strings: %s %s", (char *)NULL, (char *)NULL);
	CHECK("empty string: %s", "");
	CHECK("string with spaces: %s", " a b ");
	CHECK("percent: %%");
	CHECK("mixed percent: 100%% done");
	CHECK("percent after number: %d%%", 42);
	CHECK("percent after string: %s%%", "rate");
	CHECK_RAW("null char: %c", '\0');
	CHECK_RAW("null mid: A%cB", '\0');
	CHECK_RAW("nulls: %c%c", '\0', '\0');
	CHECK_RAW("binary %c %s %c", '\0', "x\0y", '\0');
	CHECK_RAW("binary percent: %c%%%c", '\0', '\0');
	CHECK_RAW("nul+empty: %c%s", '\0', "");
	CHECK_RAW("nul+text: %c%s", '\0', "ok");
	CHECK("integer: %d", 42);
	CHECK("negative: %i", -2147483648);
	CHECK("int min: %d", -2147483648);
	CHECK("zero: %d %u %x", 0, 0u, 0u);
	CHECK("int max: %d", 2147483647);
	CHECK("int range: %d %d", -2147483648, 2147483647);
	CHECK("sign mix: %d %i %d", -1, 0, 1);
	CHECK("uint max: %u", 4294967295u);
	CHECK("hex zero: %x %X", 0u, 0u);
	CHECK("hex uint max: %x %X", 0xffffffffu, 0xffffffffu);
	CHECK("hex mix: %x %X %x", 1u, 2u, 3u);
	CHECK("hex letters: %x %X", 0xdeadbeefu, 0xdeadbeefu);
	CHECK("unsigned: %u", 3000000000u);
	CHECK("unsigned -1: %u", (unsigned int)-1);
	CHECK("hex: %x", 0xabcdef);
	CHECK("HEX: %X", 0xABCDEF);
	CHECK("adjacent: %d%d%d", 1, 2, 3);
	CHECK("many ints: %d %d %d %d %d", 1, 2, 3, 4, 5);
	CHECK("strings: %s%s%s", "a", "", "b");
	CHECK("percent chain: %%%%");
	CHECK("percent mix: %% %d %% %s", 42, "ok");
	CHECK("pointer stack: %p", (void *)&marker);
	CHECK("pointer: %p", (void *)0x1234abcd);
	CHECK("pointer alt: %p", (void *)0x7fffffff);
	CHECK("null ptr: %p", (void *)0);
	CHECK("pointers: %p %p", (void *)&marker, (void *)&ret);
	CHECK("null ptr mix: %p %d", (void *)0, 42);
	CHECK("null in middle: %s then %d", (char *)NULL, 7);
	CHECK("mix nulls: %s %p %d", (char *)NULL, (void *)0, 0);
	CHECK("mix: %c %s %d %u %x %%", 'X', "foo", -123, 456u, 0xbeef);
	CHECK("order mix: %u %d %x %i %s", 7u, -7, 0x2a, 0, "end");
	CHECK("combo: %s %p %d %x %u %c %%", "z",
		(void *)&marker, -1, 0x7fu, 99u, 'Q');
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
	if (check_case_raw(__LINE__, "string null byte: %s", "ab\0cd"))
		return (1);
	fprintf(stderr, "Checks: %d (raw %d)\n", g_checks + g_raw_checks,
		g_raw_checks);
	return (0);
}
