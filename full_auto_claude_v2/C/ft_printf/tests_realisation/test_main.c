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

#include "../ft_printf.h"
#include <stdio.h>
#include <limits.h>

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

void	compare_outputs(int ret1, int ret2)
{
	g_total++;
	if (ret1 == ret2)
	{
		printf(GREEN "✓ Return values match: %d\n" RESET, ret1);
		g_passed++;
	}
	else
	{
		printf(RED "✗ Return values differ: printf=%d, ft_printf=%d\n" RESET,
			ret1, ret2);
	}
}

int	main(void)
{
	int		ret1, ret2;
	char	*null_str = NULL;
	void	*null_ptr = NULL;

	printf(YELLOW "=== FT_PRINTF TESTS ===\n" RESET);

	// Test %c
	test_case("Character - %c");
	printf("   printf:    ");
	ret1 = printf("Char: %c\n", 'A');
	printf("   ft_printf: ");
	ret2 = ft_printf("Char: %c\n", 'A');
	compare_outputs(ret1, ret2);

	// Test %s
	test_case("String - %s");
	printf("   printf:    ");
	ret1 = printf("String: %s\n", "Hello World");
	printf("   ft_printf: ");
	ret2 = ft_printf("String: %s\n", "Hello World");
	compare_outputs(ret1, ret2);

	// Test %s with NULL
	test_case("String NULL - %s");
	printf("   printf:    ");
	ret1 = printf("NULL string: %s\n", null_str);
	printf("   ft_printf: ");
	ret2 = ft_printf("NULL string: %s\n", null_str);
	compare_outputs(ret1, ret2);

	// Test %d
	test_case("Decimal - %d");
	printf("   printf:    ");
	ret1 = printf("Number: %d\n", 42);
	printf("   ft_printf: ");
	ret2 = ft_printf("Number: %d\n", 42);
	compare_outputs(ret1, ret2);

	// Test %d with negative
	test_case("Negative decimal - %d");
	printf("   printf:    ");
	ret1 = printf("Negative: %d\n", -42);
	printf("   ft_printf: ");
	ret2 = ft_printf("Negative: %d\n", -42);
	compare_outputs(ret1, ret2);

	// Test %d with INT_MIN
	test_case("INT_MIN - %d");
	printf("   printf:    ");
	ret1 = printf("INT_MIN: %d\n", INT_MIN);
	printf("   ft_printf: ");
	ret2 = ft_printf("INT_MIN: %d\n", INT_MIN);
	compare_outputs(ret1, ret2);

	// Test %d with INT_MAX
	test_case("INT_MAX - %d");
	printf("   printf:    ");
	ret1 = printf("INT_MAX: %d\n", INT_MAX);
	printf("   ft_printf: ");
	ret2 = ft_printf("INT_MAX: %d\n", INT_MAX);
	compare_outputs(ret1, ret2);

	// Test %i
	test_case("Integer - %i");
	printf("   printf:    ");
	ret1 = printf("Integer: %i\n", 123);
	printf("   ft_printf: ");
	ret2 = ft_printf("Integer: %i\n", 123);
	compare_outputs(ret1, ret2);

	// Test %u
	test_case("Unsigned - %u");
	printf("   printf:    ");
	ret1 = printf("Unsigned: %u\n", 4294967295U);
	printf("   ft_printf: ");
	ret2 = ft_printf("Unsigned: %u\n", 4294967295U);
	compare_outputs(ret1, ret2);

	// Test %x
	test_case("Hexadecimal lowercase - %x");
	printf("   printf:    ");
	ret1 = printf("Hex lower: %x\n", 255);
	printf("   ft_printf: ");
	ret2 = ft_printf("Hex lower: %x\n", 255);
	compare_outputs(ret1, ret2);

	// Test %X
	test_case("Hexadecimal uppercase - %X");
	printf("   printf:    ");
	ret1 = printf("Hex upper: %X\n", 255);
	printf("   ft_printf: ");
	ret2 = ft_printf("Hex upper: %X\n", 255);
	compare_outputs(ret1, ret2);

	// Test %p
	test_case("Pointer - %p");
	printf("   printf:    ");
	ret1 = printf("Pointer: %p\n", (void *)&ret1);
	printf("   ft_printf: ");
	ret2 = ft_printf("Pointer: %p\n", (void *)&ret1);
	compare_outputs(ret1, ret2);

	// Test %p with NULL
	test_case("Pointer NULL - %p");
	printf("   printf:    ");
	ret1 = printf("NULL ptr: %p\n", null_ptr);
	printf("   ft_printf: ");
	ret2 = ft_printf("NULL ptr: %p\n", null_ptr);
	compare_outputs(ret1, ret2);

	// Test %%
	test_case("Percent - %%");
	printf("   printf:    ");
	ret1 = printf("Percent: %%\n");
	printf("   ft_printf: ");
	ret2 = ft_printf("Percent: %%\n");
	compare_outputs(ret1, ret2);

	// Test mixed
	test_case("Mixed conversions");
	printf("   printf:    ");
	ret1 = printf("Mixed: %c %s %d %x %%\n", 'Z', "test", 42, 255);
	printf("   ft_printf: ");
	ret2 = ft_printf("Mixed: %c %s %d %x %%\n", 'Z', "test", 42, 255);
	compare_outputs(ret1, ret2);

	// Test zero
	test_case("Zero values");
	printf("   printf:    ");
	ret1 = printf("Zeros: %d %u %x %X\n", 0, 0, 0, 0);
	printf("   ft_printf: ");
	ret2 = ft_printf("Zeros: %d %u %x %X\n", 0, 0, 0, 0);
	compare_outputs(ret1, ret2);

	// Final results
	printf(YELLOW "\n=== RESULTS ===\n" RESET);
	printf("Tests passed: %d/%d\n", g_passed, g_total);
	if (g_passed == g_total)
		printf(GREEN "All tests passed! ✓\n" RESET);
	else
		printf(RED "Some tests failed! ✗\n" RESET);

	return (g_passed == g_total ? 0 : 1);
}
