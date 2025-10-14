/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   push_swap.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PUSH_SWAP_H
# define PUSH_SWAP_H

# include <stdlib.h>
# include <unistd.h>
# include <limits.h>

typedef struct s_stack
{
	int				value;
	int				index;
	struct s_stack	*next;
}	t_stack;

/* Stack operations */
void	sa(t_stack **a, int print);
void	sb(t_stack **b, int print);
void	ss(t_stack **a, t_stack **b, int print);
void	pa(t_stack **a, t_stack **b, int print);
void	pb(t_stack **a, t_stack **b, int print);
void	ra(t_stack **a, int print);
void	rb(t_stack **b, int print);
void	rr(t_stack **a, t_stack **b, int print);
void	rra(t_stack **a, int print);
void	rrb(t_stack **b, int print);
void	rrr(t_stack **a, t_stack **b, int print);

/* Stack utils */
t_stack	*stack_new(int value);
void	stack_add_back(t_stack **stack, t_stack *new);
void	stack_add_front(t_stack **stack, t_stack *new);
int		stack_size(t_stack *stack);
void	free_stack(t_stack **stack);
t_stack	*stack_last(t_stack *stack);
t_stack	*stack_before_last(t_stack *stack);

/* Parsing */
t_stack	*parse_args(int argc, char **argv);
long	ft_atol(const char *str);
char	**ft_split(char const *s, char c);
void	free_split(char **split);

/* Validation */
int		is_sorted(t_stack *stack);
int		has_duplicates(t_stack *stack);
void	error_exit(void);

/* Sorting */
void	sort_stack(t_stack **a, t_stack **b);
void	sort_three(t_stack **a);
void	sort_small(t_stack **a, t_stack **b);
void	radix_sort(t_stack **a, t_stack **b);

/* Indexing */
void	index_stack(t_stack *stack);
int		get_min(t_stack *stack);
int		get_max_index(t_stack *stack);
int		get_position(t_stack *stack, int index);

/* Utils */
void	ft_putstr_fd(char *s, int fd);
int		ft_strcmp(char *s1, char *s2);

#endif
