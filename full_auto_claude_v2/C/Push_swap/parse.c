/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "push_swap.h"

static int	is_number(char *str)
{
	int	i;

	i = 0;
	if (str[i] == '-' || str[i] == '+')
		i++;
	if (!str[i])
		return (0);
	while (str[i])
	{
		if (str[i] < '0' || str[i] > '9')
			return (0);
		i++;
	}
	return (1);
}

static t_stack	*process_args(char **args)
{
	t_stack	*stack;
	t_stack	*new;
	long	num;
	int		i;

	stack = NULL;
	i = 0;
	while (args[i])
	{
		if (!is_number(args[i]))
			error_exit();
		num = ft_atol(args[i]);
		if (num > INT_MAX || num < INT_MIN)
			error_exit();
		new = stack_new((int)num);
		if (!new)
			error_exit();
		stack_add_back(&stack, new);
		i++;
	}
	return (stack);
}

t_stack	*parse_args(int argc, char **argv)
{
	t_stack	*stack;
	char	**args;

	if (argc == 2)
	{
		args = ft_split(argv[1], ' ');
		if (!args || !args[0])
		{
			if (args)
				free_split(args);
			error_exit();
		}
		stack = process_args(args);
		free_split(args);
	}
	else
		stack = process_args(argv + 1);
	if (has_duplicates(stack))
	{
		free_stack(&stack);
		error_exit();
	}
	return (stack);
}
