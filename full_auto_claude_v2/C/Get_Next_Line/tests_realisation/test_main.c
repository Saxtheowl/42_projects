/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   test_main.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: auto-generated <noreply@anthropic.com>     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by auto-gen          #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by auto-gen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../get_next_line.h"
#include <fcntl.h>
#include <stdio.h>
#include <string.h>

#define RESET   "\033[0m"
#define RED     "\033[31m"
#define GREEN   "\033[32m"
#define YELLOW  "\033[33m"
#define BLUE    "\033[34m"

int	g_passed = 0;
int	g_total = 0;

void	test_case(char *desc)
{
	printf(BLUE "\n[TEST %d] %s\n" RESET, g_total + 1, desc);
}

void	test_result(int passed)
{
	g_total++;
	if (passed)
	{
		printf(GREEN "✓ PASSED\n" RESET);
		g_passed++;
	}
	else
		printf(RED "✗ FAILED\n" RESET);
}

void	test_file(char *filename, char **expected, int lines)
{
	int		fd;
	char	*line;
	int		i;
	int		all_ok;

	fd = open(filename, O_RDONLY);
	if (fd < 0)
	{
		printf(RED "Error opening file: %s\n" RESET, filename);
		return ;
	}
	all_ok = 1;
	i = 0;
	while (i < lines)
	{
		line = get_next_line(fd);
		if (!line || strcmp(line, expected[i]) != 0)
		{
			printf(RED "Line %d: Expected '%s', got '%s'\n" RESET,
				i + 1, expected[i], line ? line : "(null)");
			all_ok = 0;
		}
		free(line);
		i++;
	}
	line = get_next_line(fd);
	if (line != NULL)
	{
		printf(RED "Expected NULL at end, got: '%s'\n" RESET, line);
		all_ok = 0;
		free(line);
	}
	close(fd);
	test_result(all_ok);
}

int	main(void)
{
	int		fd1;
	char	*line;

	printf(YELLOW "=== GET_NEXT_LINE TESTS ===\n" RESET);

	// Test 1: Simple file
	test_case("Simple file with newlines");
	{
		char *expected[] = {
			"Hello World\n",
			"This is line 2\n",
			"And line 3\n"
		};
		test_file("test_files/simple.txt", expected, 3);
	}

	// Test 2: File without final newline
	test_case("File without final newline");
	{
		fd1 = open("test_files/no_final_nl.txt", O_RDONLY);
		if (fd1 >= 0)
		{
			line = get_next_line(fd1);
			int ok = line && strcmp(line, "Line 1\n") == 0;
			free(line);
			line = get_next_line(fd1);
			ok = ok && line && strcmp(line, "Line 2 no newline") == 0;
			free(line);
			line = get_next_line(fd1);
			ok = ok && (line == NULL);
			close(fd1);
			test_result(ok);
		}
		else
			test_result(0);
	}

	// Test 3: Empty file
	test_case("Empty file");
	{
		fd1 = open("test_files/empty.txt", O_RDONLY);
		if (fd1 >= 0)
		{
			line = get_next_line(fd1);
			test_result(line == NULL);
			close(fd1);
		}
		else
			test_result(0);
	}

	// Test 4: Single line
	test_case("Single line with newline");
	{
		fd1 = open("test_files/single.txt", O_RDONLY);
		if (fd1 >= 0)
		{
			line = get_next_line(fd1);
			int ok = line && strcmp(line, "Single line\n") == 0;
			free(line);
			line = get_next_line(fd1);
			ok = ok && (line == NULL);
			close(fd1);
			test_result(ok);
		}
		else
			test_result(0);
	}

	// Test 5: Long line
	test_case("Very long line");
	{
		fd1 = open("test_files/long_line.txt", O_RDONLY);
		if (fd1 >= 0)
		{
			line = get_next_line(fd1);
			int ok = line && strlen(line) > 1000;
			free(line);
			close(fd1);
			test_result(ok);
		}
		else
			test_result(0);
	}

	// Test 6: Multiple empty lines
	test_case("Multiple empty lines");
	{
		fd1 = open("test_files/empty_lines.txt", O_RDONLY);
		if (fd1 >= 0)
		{
			int ok = 1;
			line = get_next_line(fd1);
			ok = ok && line && strcmp(line, "\n") == 0;
			free(line);
			line = get_next_line(fd1);
			ok = ok && line && strcmp(line, "\n") == 0;
			free(line);
			line = get_next_line(fd1);
			ok = ok && line && strcmp(line, "text\n") == 0;
			free(line);
			close(fd1);
			test_result(ok);
		}
		else
			test_result(0);
	}

	// Test 7: Invalid fd
	test_case("Invalid file descriptor");
	{
		line = get_next_line(-1);
		test_result(line == NULL);
	}

	// Test 8: Already closed fd
	test_case("Closed file descriptor");
	{
		fd1 = open("test_files/simple.txt", O_RDONLY);
		close(fd1);
		line = get_next_line(fd1);
		test_result(line == NULL);
	}

	// Final results
	printf(YELLOW "\n=== RESULTS ===\n" RESET);
	printf("Tests passed: %d/%d\n", g_passed, g_total);
	if (g_passed == g_total)
		printf(GREEN "All tests passed! ✓\n" RESET);
	else
		printf(RED "Some tests failed! ✗\n" RESET);

	return (g_passed == g_total ? 0 : 1);
}
