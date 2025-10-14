/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   sort_small.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "push_swap.h"

void	sort_three(t_stack **a)
{
	int	first;
	int	second;
	int	third;

	first = (*a)->value;
	second = (*a)->next->value;
	third = (*a)->next->next->value;
	if (first > second && second < third && first < third)
		sa(a, 1);
	else if (first > second && second > third)
	{
		sa(a, 1);
		rra(a, 1);
	}
	else if (first > second && second < third && first > third)
		ra(a, 1);
	else if (first < second && second > third && first < third)
	{
		sa(a, 1);
		ra(a, 1);
	}
	else if (first < second && second > third && first > third)
		rra(a, 1);
}

static void	push_min_to_b(t_stack **a, t_stack **b)
{
	int		min;
	int		size;
	int		pos;

	min = get_min(*a);
	size = stack_size(*a);
	pos = 0;
	while ((*a)->value != min)
	{
		pos++;
		*a = (*a)->next;
	}
	if (pos <= size / 2)
	{
		while ((*a)->value != min)
			ra(a, 1);
	}
	else
	{
		while ((*a)->value != min)
			rra(a, 1);
	}
	pb(a, b, 1);
}

void	sort_small(t_stack **a, t_stack **b)
{
	int	size;

	size = stack_size(*a);
	if (size == 2)
	{
		if ((*a)->value > (*a)->next->value)
			sa(a, 1);
		return ;
	}
	while (size > 3)
	{
		push_min_to_b(a, b);
		size--;
	}
	sort_three(a);
	while (*b)
		pa(a, b, 1);
}
