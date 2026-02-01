/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_ls.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_LS_H
# define FT_LS_H

# include <unistd.h>
# include <stdlib.h>
# include <dirent.h>
# include <sys/stat.h>
# include <sys/types.h>
# include <pwd.h>
# include <grp.h>
# include <time.h>
# include <string.h>
# include <errno.h>

# define FLAG_L 0x01
# define FLAG_R 0x02
# define FLAG_A 0x04
# define FLAG_REV 0x08
# define FLAG_T 0x10

typedef struct s_file
{
	char			*name;
	char			*path;
	struct stat		st;
	struct s_file	*next;
}	t_file;

typedef struct s_opts
{
	int		flags;
	int		multi;
}	t_opts;

typedef struct s_widths
{
	int		links;
	int		user;
	int		group;
	int		size;
	long	total;
}	t_widths;

void	ft_putchar(char c);
void	ft_putstr(const char *s);
void	ft_putendl(const char *s);
void	ft_putnbr(long n);
void	ft_putstr_padded(const char *s, int width, int right);
void	ft_putnbr_padded(long n, int width);
size_t	ft_strlen(const char *s);
int		ft_strcmp(const char *s1, const char *s2);
char	*ft_strdup(const char *s);
char	*ft_strjoin(const char *s1, const char *s2);
void	*ft_memset(void *b, int c, size_t len);

int		parse_opts(int argc, char **argv, t_opts *opts);
t_file	*read_directory(const char *path, t_opts *opts);
void	sort_files(t_file **head, t_opts *opts);
void	display_files(t_file *files, t_opts *opts, int show_dirname);
void	free_files(t_file *files);
t_file	*add_file(t_file **head, const char *name, const char *path);
int		count_digits(long n);

#endif
