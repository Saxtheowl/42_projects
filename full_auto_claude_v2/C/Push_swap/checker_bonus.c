/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   checker_bonus.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "push_swap.h"

static char	*get_next_line(int fd)
{
	char	*line;
	char	buffer[2];
	int		i;
	int		ret;

	line = malloc(1000);
	if (!line)
		return (NULL);
	i = 0;
	ret = read(fd, buffer, 1);
	while (ret > 0)
	{
		buffer[1] = '\0';
		if (buffer[0] == '\n')
			break ;
		line[i++] = buffer[0];
		ret = read(fd, buffer, 1);
	}
	line[i] = '\0';
	if (ret <= 0 && i == 0)
	{
		free(line);
		return (NULL);
	}
	return (line);
}

static void	execute_operation(char *line, t_stack **a, t_stack **b)
{
	if (ft_strcmp(line, "sa") == 0)
		sa(a, 0);
	else if (ft_strcmp(line, "sb") == 0)
		sb(b, 0);
	else if (ft_strcmp(line, "ss") == 0)
		ss(a, b, 0);
	else if (ft_strcmp(line, "pa") == 0)
		pa(a, b, 0);
	else if (ft_strcmp(line, "pb") == 0)
		pb(a, b, 0);
	else if (ft_strcmp(line, "ra") == 0)
		ra(a, 0);
	else if (ft_strcmp(line, "rb") == 0)
		rb(b, 0);
	else if (ft_strcmp(line, "rr") == 0)
		rr(a, b, 0);
	else if (ft_strcmp(line, "rra") == 0)
		rra(a, 0);
	else if (ft_strcmp(line, "rrb") == 0)
		rrb(b, 0);
	else if (ft_strcmp(line, "rrr") == 0)
		rrr(a, b, 0);
	else
		error_exit();
}

static void	read_and_execute(t_stack **a, t_stack **b)
{
	char	*line;

	line = get_next_line(0);
	while (line)
	{
		execute_operation(line, a, b);
		free(line);
		line = get_next_line(0);
	}
}

int	main(int argc, char **argv)
{
	t_stack	*a;
	t_stack	*b;

	if (argc < 2)
		return (0);
	a = parse_args(argc, argv);
	b = NULL;
	if (!a)
		error_exit();
	read_and_execute(&a, &b);
	if (is_sorted(a) && !b)
		ft_putstr_fd("OK\n", 1);
	else
		ft_putstr_fd("KO\n", 1);
	free_stack(&a);
	free_stack(&b);
	return (0);
}
