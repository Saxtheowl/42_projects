/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   display.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ls.h"

static void	print_mode(mode_t mode)
{
	char	str[11];

	str[0] = '-';
	if (S_ISDIR(mode))
		str[0] = 'd';
	else if (S_ISLNK(mode))
		str[0] = 'l';
	else if (S_ISCHR(mode))
		str[0] = 'c';
	else if (S_ISBLK(mode))
		str[0] = 'b';
	else if (S_ISFIFO(mode))
		str[0] = 'p';
	else if (S_ISSOCK(mode))
		str[0] = 's';
	str[1] = (mode & S_IRUSR) ? 'r' : '-';
	str[2] = (mode & S_IWUSR) ? 'w' : '-';
	str[3] = (mode & S_IXUSR) ? 'x' : '-';
	str[4] = (mode & S_IRGRP) ? 'r' : '-';
	str[5] = (mode & S_IWGRP) ? 'w' : '-';
	str[6] = (mode & S_IXGRP) ? 'x' : '-';
	str[7] = (mode & S_IROTH) ? 'r' : '-';
	str[8] = (mode & S_IWOTH) ? 'w' : '-';
	str[9] = (mode & S_IXOTH) ? 'x' : '-';
	str[10] = '\0';
	ft_putstr(str);
}

static void	get_widths(t_file *files, t_widths *w)
{
	struct passwd	*pw;
	struct group	*gr;
	int				len;

	w->links = 1;
	w->user = 1;
	w->group = 1;
	w->size = 1;
	w->total = 0;
	while (files)
	{
		w->total += files->st.st_blocks;
		len = count_digits(files->st.st_nlink);
		if (len > w->links)
			w->links = len;
		pw = getpwuid(files->st.st_uid);
		if (pw && (int)ft_strlen(pw->pw_name) > w->user)
			w->user = ft_strlen(pw->pw_name);
		gr = getgrgid(files->st.st_gid);
		if (gr && (int)ft_strlen(gr->gr_name) > w->group)
			w->group = ft_strlen(gr->gr_name);
		len = count_digits(files->st.st_size);
		if (len > w->size)
			w->size = len;
		files = files->next;
	}
}

static void	print_time(time_t mtime)
{
	char	*t;
	time_t	now;
	int		i;

	t = ctime(&mtime);
	now = time(NULL);
	i = 4;
	while (i < 11)
		ft_putchar(t[i++]);
	if (now - mtime > 15778463 || mtime > now)
	{
		ft_putchar(' ');
		i = 20;
		while (i < 24)
			ft_putchar(t[i++]);
	}
	else
	{
		i = 11;
		while (i < 16)
			ft_putchar(t[i++]);
	}
}

static void	print_long(t_file *f, t_widths *w)
{
	struct passwd	*pw;
	struct group	*gr;
	char			link[256];
	ssize_t			len;

	print_mode(f->st.st_mode);
	ft_putchar(' ');
	ft_putnbr_padded(f->st.st_nlink, w->links);
	ft_putchar(' ');
	pw = getpwuid(f->st.st_uid);
	if (pw)
		ft_putstr_padded(pw->pw_name, w->user, 1);
	else
		ft_putnbr_padded(f->st.st_uid, w->user);
	ft_putchar(' ');
	gr = getgrgid(f->st.st_gid);
	if (gr)
		ft_putstr_padded(gr->gr_name, w->group, 1);
	else
		ft_putnbr_padded(f->st.st_gid, w->group);
	ft_putchar(' ');
	ft_putnbr_padded(f->st.st_size, w->size);
	ft_putchar(' ');
	print_time(f->st.st_mtime);
	ft_putchar(' ');
	ft_putstr(f->name);
	if (S_ISLNK(f->st.st_mode))
	{
		len = readlink(f->path, link, sizeof(link) - 1);
		if (len > 0)
		{
			link[len] = '\0';
			ft_putstr(" -> ");
			ft_putstr(link);
		}
	}
	ft_putchar('\n');
}

void	display_files(t_file *files, t_opts *opts, int show_dirname)
{
	t_widths	w;
	t_file		*f;

	if (!files)
		return ;
	if (show_dirname)
	{
		ft_putstr(files->path);
		ft_putendl(":");
	}
	if (opts->flags & FLAG_L)
	{
		get_widths(files, &w);
		ft_putstr("total ");
		ft_putnbr(w.total);
		ft_putchar('\n');
	}
	f = files;
	while (f)
	{
		if (opts->flags & FLAG_L)
			print_long(f, &w);
		else
			ft_putendl(f->name);
		f = f->next;
	}
}
