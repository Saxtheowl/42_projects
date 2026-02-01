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

#include "ft_ls.h"

static int	parse_flag(char c, t_opts *opts)
{
	if (c == 'l')
		opts->flags |= FLAG_L;
	else if (c == 'R')
		opts->flags |= FLAG_R;
	else if (c == 'a')
		opts->flags |= FLAG_A;
	else if (c == 'r')
		opts->flags |= FLAG_REV;
	else if (c == 't')
		opts->flags |= FLAG_T;
	else
	{
		ft_putstr("ft_ls: invalid option -- '");
		ft_putchar(c);
		ft_putendl("'");
		return (-1);
	}
	return (0);
}

int	parse_opts(int argc, char **argv, t_opts *opts)
{
	int	i;
	int	j;

	opts->flags = 0;
	opts->multi = 0;
	i = 1;
	while (i < argc && argv[i][0] == '-' && argv[i][1])
	{
		j = 1;
		while (argv[i][j])
		{
			if (parse_flag(argv[i][j], opts) < 0)
				return (-1);
			j++;
		}
		i++;
	}
	return (i);
}

static void	ls_recursive(const char *path, t_opts *opts, int first)
{
	t_file	*files;
	t_file	*f;
	char	*new_path;
	char	*tmp;

	files = read_directory(path, opts);
	if (!files)
		return ;
	sort_files(&files, opts);
	if (!first)
		ft_putchar('\n');
	ft_putstr(path);
	ft_putendl(":");
	display_files(files, opts, 0);
	if (opts->flags & FLAG_R)
	{
		f = files;
		while (f)
		{
			if (S_ISDIR(f->st.st_mode) && ft_strcmp(f->name, ".") != 0
				&& ft_strcmp(f->name, "..") != 0)
			{
				tmp = ft_strjoin(path, "/");
				new_path = ft_strjoin(tmp, f->name);
				free(tmp);
				ls_recursive(new_path, opts, 0);
				free(new_path);
			}
			f = f->next;
		}
	}
	free_files(files);
}

static void	ls_single(const char *path, t_opts *opts, int show_name)
{
	struct stat	st;
	t_file		*files;

	if (lstat(path, &st) < 0)
	{
		ft_putstr("ft_ls: cannot access '");
		ft_putstr(path);
		ft_putstr("': ");
		ft_putendl(strerror(errno));
		return ;
	}
	if (S_ISDIR(st.st_mode))
	{
		if (opts->flags & FLAG_R)
			ls_recursive(path, opts, 1);
		else
		{
			files = read_directory(path, opts);
			if (files)
			{
				sort_files(&files, opts);
				if (show_name)
				{
					ft_putstr(path);
					ft_putendl(":");
				}
				display_files(files, opts, 0);
				free_files(files);
			}
		}
	}
	else
	{
		files = NULL;
		add_file(&files, path, path);
		display_files(files, opts, 0);
		free_files(files);
	}
}

int	main(int argc, char **argv)
{
	t_opts	opts;
	int		start;
	int		i;
	int		multi;

	start = parse_opts(argc, argv, &opts);
	if (start < 0)
		return (1);
	if (start >= argc)
	{
		ls_single(".", &opts, 0);
		return (0);
	}
	multi = (argc - start) > 1;
	i = start;
	while (i < argc)
	{
		if (i > start)
			ft_putchar('\n');
		ls_single(argv[i], &opts, multi);
		i++;
	}
	return (0);
}
