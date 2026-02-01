/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "push_swap.h"

static int	has_duplicates(t_stack *stack)
{
	t_stack	*i;
	t_stack	*j;

	i = stack;
	while (i)
	{
		j = i->next;
		while (j)
		{
			if (i->value == j->value)
				return (1);
			j = j->next;
		}
		i = i->next;
	}
	return (0);
}

static t_stack	*parse_args(int argc, char **argv)
{
	t_stack	*stack;
	int		i;
	int		value;
	int		error;

	stack = NULL;
	i = 1;
	while (i < argc)
	{
		error = 0;
		value = ft_atoi_check(argv[i], &error);
		if (error)
		{
			stack_clear(&stack);
			return (NULL);
		}
		stack_add_back(&stack, stack_new(value));
		i++;
	}
	return (stack);
}

static void	push_swap(t_stack **a, t_stack **b)
{
	int	size;

	size = stack_size(*a);
	if (size <= 1 || is_sorted(*a))
		return ;
	index_stack(*a);
	if (size == 2)
		sa(a, 1);
	else if (size == 3)
		sort_three(a);
	else if (size <= 5)
		sort_five(a, b);
	else
		radix_sort(a, b);
}

int	main(int argc, char **argv)
{
	t_stack	*a;
	t_stack	*b;

	if (argc < 2)
		return (0);
	a = parse_args(argc, argv);
	if (!a || has_duplicates(a))
	{
		ft_putstr("Error\n");
		stack_clear(&a);
		return (1);
	}
	b = NULL;
	push_swap(&a, &b);
	stack_clear(&a);
	stack_clear(&b);
	return (0);
}
