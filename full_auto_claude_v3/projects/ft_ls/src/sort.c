/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   sort.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ls.h"

static int	compare_alpha(t_file *a, t_file *b)
{
	return (ft_strcmp(a->name, b->name));
}

static int	compare_time(t_file *a, t_file *b)
{
	if (a->st.st_mtime != b->st.st_mtime)
		return (b->st.st_mtime - a->st.st_mtime);
	return (ft_strcmp(a->name, b->name));
}

static void	swap_files(t_file *a, t_file *b)
{
	char		*tmp_name;
	char		*tmp_path;
	struct stat	tmp_st;

	tmp_name = a->name;
	tmp_path = a->path;
	tmp_st = a->st;
	a->name = b->name;
	a->path = b->path;
	a->st = b->st;
	b->name = tmp_name;
	b->path = tmp_path;
	b->st = tmp_st;
}

static void	bubble_sort(t_file *head, int (*cmp)(t_file*, t_file*), int rev)
{
	t_file	*ptr;
	int		swapped;
	int		result;

	if (!head)
		return ;
	swapped = 1;
	while (swapped)
	{
		swapped = 0;
		ptr = head;
		while (ptr->next)
		{
			result = cmp(ptr, ptr->next);
			if (rev)
				result = -result;
			if (result > 0)
			{
				swap_files(ptr, ptr->next);
				swapped = 1;
			}
			ptr = ptr->next;
		}
	}
}

void	sort_files(t_file **head, t_opts *opts)
{
	int	rev;

	if (!head || !*head)
		return ;
	rev = (opts->flags & FLAG_REV) ? 1 : 0;
	if (opts->flags & FLAG_T)
		bubble_sort(*head, compare_time, rev);
	else
		bubble_sort(*head, compare_alpha, rev);
}
