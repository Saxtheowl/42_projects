/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   validation.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "push_swap.h"

void	error_exit(void)
{
	ft_putstr_fd("Error\n", 2);
	exit(1);
}

int	is_sorted(t_stack *stack)
{
	if (!stack)
		return (1);
	while (stack->next)
	{
		if (stack->value > stack->next->value)
			return (0);
		stack = stack->next;
	}
	return (1);
}

int	has_duplicates(t_stack *stack)
{
	t_stack	*tmp;
	t_stack	*current;

	current = stack;
	while (current)
	{
		tmp = current->next;
		while (tmp)
		{
			if (current->value == tmp->value)
				return (1);
			tmp = tmp->next;
		}
		current = current->next;
	}
	return (0);
}

void	index_stack(t_stack *stack)
{
	t_stack	*current;
	t_stack	*tmp;
	int		index;

	current = stack;
	while (current)
	{
		index = 0;
		tmp = stack;
		while (tmp)
		{
			if (tmp->value < current->value)
				index++;
			tmp = tmp->next;
		}
		current->index = index;
		current = current->next;
	}
}
