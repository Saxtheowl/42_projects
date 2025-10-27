#include "libasm.h"

#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static int g_failures = 0;

static void fail(const char *message)
{
	fprintf(stderr, "%s\n", message);
	g_failures++;
}

static void check_size(const char *label, size_t got, size_t expected)
{
	if (got != expected)
	{
		fprintf(stderr, "[FAIL] %s: got %zu expected %zu\n", label, got, expected);
		g_failures++;
	}
}

static void check_int(const char *label, long got, long expected)
{
	if (got != expected)
	{
		fprintf(stderr, "[FAIL] %s: got %ld expected %ld\n", label, got, expected);
		g_failures++;
	}
}

static void check_str(const char *label, const char *got, const char *expected)
{
	if (strcmp(got, expected) != 0)
	{
		fprintf(stderr, "[FAIL] %s: got '%s' expected '%s'\n", label, got, expected);
		g_failures++;
	}
}

static void test_strlen(void)
{
	check_size("strlen empty", ft_strlen(""), strlen(""));
	check_size("strlen hello", ft_strlen("hello"), strlen("hello"));
	check_size("strlen long", ft_strlen("abcdefghijklmnopqrstuvwxyz"), strlen("abcdefghijklmnopqrstuvwxyz"));
}

static void test_strcpy(void)
{
	char dest[64];
	const char *src = "mini libasm";
	char *ret = ft_strcpy(dest, src);
	if (ret != dest)
		fail("ft_strcpy should return destination pointer");
	check_str("strcpy", dest, src);
}

static void test_strcmp(void)
{
	check_int("strcmp equal", ft_strcmp("abc", "abc"), strcmp("abc", "abc"));
	check_int("strcmp lt", ft_strcmp("abc", "abd") < 0, 1);
	check_int("strcmp gt", ft_strcmp("abd", "abc") > 0, 1);
}

static void test_strdup(void)
{
	const char *src = "duplicate me";
	char *dup = ft_strdup(src);
	if (dup == NULL)
	{
		fail("ft_strdup returned NULL");
		return ;
	}
	check_str("strdup content", dup, src);
	if (dup == src)
		fail("ft_strdup returned the original pointer");
	free(dup);
}

static void test_write_success(void)
{
	int pipefd[2];
	const char *msg = "hello write";
	char buffer[64] = {0};

	if (pipe(pipefd) == -1)
	{
		perror("pipe");
		exit(EXIT_FAILURE);
	}
	size_t len = strlen(msg);
	errno = 0;
	ssize_t written = ft_write(pipefd[1], msg, len);
	close(pipefd[1]);
	if (written != (ssize_t)len)
	{
		fprintf(stderr, "[FAIL] ft_write wrote %zd expected %zu\n", written, len);
		g_failures++;
	}
	ssize_t read_bytes = read(pipefd[0], buffer, sizeof(buffer));
	close(pipefd[0]);
	if (read_bytes != (ssize_t)len)
	{
		fprintf(stderr, "[FAIL] pipe read %zd expected %zu\n", read_bytes, len);
		g_failures++;
	}
	else if (memcmp(buffer, msg, len) != 0)
	{
		fail("ft_write pipe content mismatch");
	}
}

static void test_write_error(void)
{
	errno = 0;
	ssize_t res = ft_write(-1, "hi", 2);
	if (res != -1)
		fail("ft_write error case should return -1");
	if (errno != EBADF)
	{
		fprintf(stderr, "[FAIL] ft_write errno %d expected %d (EBADF)\n", errno, EBADF);
		g_failures++;
	}
}

static void test_read_success(void)
{
	int pipefd[2];
	const char *msg = "hello read";
	char buffer[64] = {0};

	if (pipe(pipefd) == -1)
	{
		perror("pipe");
		exit(EXIT_FAILURE);
	}
	write(pipefd[1], msg, strlen(msg));
	close(pipefd[1]);
	errno = 0;
	ssize_t read_bytes = ft_read(pipefd[0], buffer, sizeof(buffer));
	close(pipefd[0]);
	if (read_bytes != (ssize_t)strlen(msg))
	{
		fprintf(stderr, "[FAIL] ft_read read %zd expected %zu\n", read_bytes, strlen(msg));
		g_failures++;
	}
	else if (memcmp(buffer, msg, strlen(msg)) != 0)
	{
		fail("ft_read buffer mismatch");
	}
}

static void test_read_error(void)
{
	char buffer[16];
	errno = 0;
	ssize_t res = ft_read(-1, buffer, sizeof(buffer));
	if (res != -1)
		fail("ft_read error case should return -1");
	if (errno != EBADF)
	{
		fprintf(stderr, "[FAIL] ft_read errno %d expected %d (EBADF)\n", errno, EBADF);
		g_failures++;
	}
}

int main(void)
{
	test_strlen();
	test_strcpy();
	test_strcmp();
	test_strdup();
	test_write_success();
	test_write_error();
	test_read_success();
	test_read_error();

	if (g_failures != 0)
	{
		fprintf(stderr, "%d test(s) failed\n", g_failures);
		return EXIT_FAILURE;
	}
	printf("All libasm tests passed\n");
	return EXIT_SUCCESS;
}
