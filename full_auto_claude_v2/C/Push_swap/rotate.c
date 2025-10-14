/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   rotate.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "push_swap.h"

void	ra(t_stack **a, int print)
{
	t_stack	*first;
	t_stack	*last;

	if (!*a || !(*a)->next)
		return ;
	first = *a;
	last = stack_last(*a);
	*a = first->next;
	first->next = NULL;
	last->next = first;
	if (print)
		ft_putstr_fd("ra\n", 1);
}

void	rb(t_stack **b, int print)
{
	t_stack	*first;
	t_stack	*last;

	if (!*b || !(*b)->next)
		return ;
	first = *b;
	last = stack_last(*b);
	*b = first->next;
	first->next = NULL;
	last->next = first;
	if (print)
		ft_putstr_fd("rb\n", 1);
}

void	rr(t_stack **a, t_stack **b, int print)
{
	ra(a, 0);
	rb(b, 0);
	if (print)
		ft_putstr_fd("rr\n", 1);
}

void	rra(t_stack **a, int print)
{
	t_stack	*last;
	t_stack	*before_last;

	if (!*a || !(*a)->next)
		return ;
	last = stack_last(*a);
	before_last = stack_before_last(*a);
	before_last->next = NULL;
	last->next = *a;
	*a = last;
	if (print)
		ft_putstr_fd("rra\n", 1);
}

void	rrb(t_stack **b, int print)
{
	t_stack	*last;
	t_stack	*before_last;

	if (!*b || !(*b)->next)
		return ;
	last = stack_last(*b);
	before_last = stack_before_last(*b);
	before_last->next = NULL;
	last->next = *b;
	*b = last;
	if (print)
		ft_putstr_fd("rrb\n", 1);
}

void	rrr(t_stack **a, t_stack **b, int print)
{
	rra(a, 0);
	rrb(b, 0);
	if (print)
		ft_putstr_fd("rrr\n", 1);
}
