/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   files.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ls.h"

t_file	*add_file(t_file **head, const char *name, const char *path)
{
	t_file	*new;
	t_file	*tmp;

	new = malloc(sizeof(t_file));
	if (!new)
		return (NULL);
	new->name = ft_strdup(name);
	new->path = ft_strdup(path);
	new->next = NULL;
	if (!new->name || !new->path)
	{
		free(new->name);
		free(new->path);
		free(new);
		return (NULL);
	}
	if (lstat(path, &new->st) < 0)
		ft_memset(&new->st, 0, sizeof(struct stat));
	if (!*head)
		*head = new;
	else
	{
		tmp = *head;
		while (tmp->next)
			tmp = tmp->next;
		tmp->next = new;
	}
	return (new);
}

void	free_files(t_file *files)
{
	t_file	*tmp;

	while (files)
	{
		tmp = files->next;
		free(files->name);
		free(files->path);
		free(files);
		files = tmp;
	}
}

static int	should_skip(const char *name, t_opts *opts)
{
	if (!(opts->flags & FLAG_A))
	{
		if (name[0] == '.')
			return (1);
	}
	return (0);
}

t_file	*read_directory(const char *path, t_opts *opts)
{
	DIR				*dir;
	struct dirent	*entry;
	t_file			*files;
	char			*full_path;
	char			*tmp;

	files = NULL;
	dir = opendir(path);
	if (!dir)
	{
		ft_putstr("ft_ls: cannot access '");
		ft_putstr(path);
		ft_putstr("': ");
		ft_putendl(strerror(errno));
		return (NULL);
	}
	entry = readdir(dir);
	while (entry)
	{
		if (!should_skip(entry->d_name, opts))
		{
			tmp = ft_strjoin(path, "/");
			full_path = ft_strjoin(tmp, entry->d_name);
			free(tmp);
			add_file(&files, entry->d_name, full_path);
			free(full_path);
		}
		entry = readdir(dir);
	}
	closedir(dir);
	return (files);
}
