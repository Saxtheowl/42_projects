#include "ft_ls.h"

#include <errno.h>
#include <grp.h>
#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>
#include <limits.h>

#ifndef PATH_MAX
# define PATH_MAX 4096
#endif

static const t_options *g_sort_options = NULL;

static int	handle_directory(const char *path, const t_options *opts, int print_header);

static size_t	count_digits(unsigned long long value)
{
	size_t	count;

	count = 1;
	while (value >= 10)
	{
		value /= 10;
		count++;
	}
	return (count);
}

static const char	*format_owner(uid_t uid, char *buffer, size_t size)
{
	struct passwd	*pwd;

	pwd = getpwuid(uid);
	if (pwd != NULL)
	{
		snprintf(buffer, size, "%s", pwd->pw_name);
		return (buffer);
	}
	snprintf(buffer, size, "%u", (unsigned int)uid);
	return (buffer);
}

static const char	*format_group(gid_t gid, char *buffer, size_t size)
{
	struct group	*grp;

	grp = getgrgid(gid);
	if (grp != NULL)
	{
		snprintf(buffer, size, "%s", grp->gr_name);
		return (buffer);
	}
	snprintf(buffer, size, "%u", (unsigned int)gid);
	return (buffer);
}

static void	format_mode(mode_t mode, char buffer[11])
{
	buffer[0] = S_ISDIR(mode) ? 'd' :
		(S_ISLNK(mode) ? 'l' :
		(S_ISCHR(mode) ? 'c' :
		(S_ISBLK(mode) ? 'b' :
		(S_ISSOCK(mode) ? 's' :
		(S_ISFIFO(mode) ? 'p' : '-')))));
	buffer[1] = (mode & S_IRUSR) ? 'r' : '-';
	buffer[2] = (mode & S_IWUSR) ? 'w' : '-';
	buffer[3] = (mode & S_IXUSR) ? 'x' : '-';
	buffer[4] = (mode & S_IRGRP) ? 'r' : '-';
	buffer[5] = (mode & S_IWGRP) ? 'w' : '-';
	buffer[6] = (mode & S_IXGRP) ? 'x' : '-';
	buffer[7] = (mode & S_IROTH) ? 'r' : '-';
	buffer[8] = (mode & S_IWOTH) ? 'w' : '-';
	buffer[9] = (mode & S_IXOTH) ? 'x' : '-';
	if (mode & S_ISUID)
		buffer[3] = (buffer[3] == 'x') ? 's' : 'S';
	if (mode & S_ISGID)
		buffer[6] = (buffer[6] == 'x') ? 's' : 'S';
	if (mode & S_ISVTX)
		buffer[9] = (buffer[9] == 'x') ? 't' : 'T';
	buffer[10] = '\0';
}

static void	format_time(time_t timestamp, char *buffer, size_t size)
{
	time_t	now;
	double	diff;
	struct tm	*tm_info;
	const char	*fmt;

	now = time(NULL);
	diff = difftime(now, timestamp);
	tm_info = localtime(&timestamp);
	if (tm_info == NULL)
	{
		snprintf(buffer, size, "????????????");
		return ;
	}
	fmt = "%b %e %H:%M";
	if (diff > 15768000.0 || diff < -3600.0)
		fmt = "%b %e  %Y";
	strftime(buffer, size, fmt, tm_info);
}

static char	*join_path(const char *dir, const char *name)
{
	size_t	dir_len;
	size_t	name_len;
	char	*result;

	dir_len = strlen(dir);
	name_len = strlen(name);
	result = malloc(dir_len + name_len + 2);
	if (!result)
		return (NULL);
	memcpy(result, dir, dir_len);
	if (dir_len > 0 && dir[dir_len - 1] != '/')
		result[dir_len++] = '/';
	memcpy(result + dir_len, name, name_len);
	result[dir_len + name_len] = '\0';
	return (result);
}

static int	is_hidden(const char *name)
{
	return (name[0] == '.');
}

static int	compare_entries_ctx(const t_entry *lhs, const t_entry *rhs,
	const t_options *opts)
{
	int	result;

	if ((opts->flags & FT_LS_OPT_T) != 0)
	{
		if (lhs->stats.st_mtime != rhs->stats.st_mtime)
			result = (lhs->stats.st_mtime > rhs->stats.st_mtime) ? -1 : 1;
		else
			result = strcmp(lhs->name, rhs->name);
	}
	else
		result = strcmp(lhs->name, rhs->name);
	if ((opts->flags & FT_LS_OPT_R) != 0)
		result = -result;
	return (result);
}

static int	compare_entries_qsort(const void *lhs_ptr, const void *rhs_ptr)
{
	const t_entry	*lhs;
	const t_entry	*rhs;

	lhs = lhs_ptr;
	rhs = rhs_ptr;
	return (compare_entries_ctx(lhs, rhs, g_sort_options));
}

static void	free_entries(t_entry *entries, size_t count)
{
	size_t	index;

	if (entries == NULL)
		return ;
	index = 0;
	while (index < count)
	{
		free(entries[index].name);
		free(entries[index].full_path);
		index++;
	}
	free(entries);
}

static int	add_entry(t_entry **entries, size_t *count, size_t *capacity,
	const t_entry *value)
{
	t_entry	*tmp;

	if (*count == *capacity)
	{
		*capacity = (*capacity == 0) ? 16 : (*capacity * 2);
		tmp = realloc(*entries, *capacity * sizeof(t_entry));
		if (!tmp)
			return (-1);
		*entries = tmp;
	}
	(*entries)[*count] = *value;
	(*count)++;
	return (0);
}

static int	collect_directory_entries(const char *path, const t_options *opts,
				 t_entry **entries_out, size_t *count_out)
{
	DIR			*dir;
	struct dirent	*ent;
	t_entry		entry;
	t_entry		*entries;
	size_t		count;
	size_t		capacity;

	dir = opendir(path);
	if (dir == NULL)
		return (perror(path), -1);
	entries = NULL;
	count = 0;
	capacity = 0;
	while ((ent = readdir(dir)) != NULL)
	{
		if (!(opts->flags & FT_LS_OPT_A) && is_hidden(ent->d_name))
			continue ;
		entry.name = strdup(ent->d_name);
		entry.full_path = join_path(path, ent->d_name);
		if (!entry.name || !entry.full_path)
		{
			perror("ft_ls: malloc");
			free(entry.name);
			free(entry.full_path);
			continue ;
		}
		if (lstat(entry.full_path, &entry.stats) == -1)
		{
			perror(entry.full_path);
			free(entry.name);
			free(entry.full_path);
			continue ;
		}
		if (add_entry(&entries, &count, &capacity, &entry) != 0)
		{
			perror("ft_ls: malloc");
			free(entry.name);
			free(entry.full_path);
			free_entries(entries, count);
			closedir(dir);
			return (-1);
		}
	}
	closedir(dir);
	*entries_out = entries;
	*count_out = count;
	return (0);
}

static void	compute_widths(const t_entry *entries, size_t count,
				 size_t *link_w, size_t *size_w)
{
	size_t	index;
	size_t	lw;
	size_t	sw;

	lw = 1;
	sw = 1;
	index = 0;
	while (index < count)
	{
		size_t nlink_width;
		size_t size_width;

		nlink_width = count_digits(entries[index].stats.st_nlink);
		size_width = count_digits((unsigned long long)entries[index].stats.st_size);
		if (nlink_width > lw)
			lw = nlink_width;
		if (size_width > sw)
			sw = size_width;
		index++;
	}
	*link_w = lw;
	*size_w = sw;
}

static void	print_long_entry(const t_entry *entry, const t_options *opts,
		      size_t link_w, size_t size_w)
{
	char	mode[11];
	char	owner_buf[64];
	char	group_buf[64];
	char	time_buf[64];
	char	target[PATH_MAX + 1];
	ssize_t	len;

	(void)opts;
	format_mode(entry->stats.st_mode, mode);
	format_time(entry->stats.st_mtime, time_buf, sizeof(time_buf));
	printf("%s %*lu %s %s %*lld %s %s",
		mode,
		(int)link_w,
		(unsigned long)entry->stats.st_nlink,
		format_owner(entry->stats.st_uid, owner_buf, sizeof(owner_buf)),
		format_group(entry->stats.st_gid, group_buf, sizeof(group_buf)),
		(int)size_w,
		(long long)entry->stats.st_size,
		time_buf,
		entry->name);
	if (S_ISLNK(entry->stats.st_mode))
	{
		len = readlink(entry->full_path, target, PATH_MAX);
		if (len >= 0)
		{
			target[len] = '\0';
			printf(" -> %s", target);
		}
	}
	printf("\n");
}

static int	print_entries(t_entry *entries, size_t count, const t_options *opts,
		       int show_total)
{
	size_t	link_width;
	size_t	size_width;
	size_t	index;
	long long	blocks_total;

	link_width = 1;
	size_width = 1;
	blocks_total = 0;
	if (show_total && (opts->flags & FT_LS_OPT_L))
	{
		compute_widths(entries, count, &link_width, &size_width);
		index = 0;
		while (index < count)
		{
			blocks_total += entries[index].stats.st_blocks;
			index++;
		}
		printf("total %lld\n", blocks_total / 2);
	}
	else if (opts->flags & FT_LS_OPT_L)
		compute_widths(entries, count, &link_width, &size_width);
	index = 0;
	while (index < count)
	{
		if (opts->flags & FT_LS_OPT_L)
			print_long_entry(&entries[index], opts, link_width, size_width);
		else
			printf("%s\n", entries[index].name);
		index++;
	}
	return (0);
}

static int	init_entry_from_path(t_entry *entry, const char *full_path,
	const char *display_name)
{
	entry->name = strdup(display_name);
	entry->full_path = strdup(full_path);
	if (!entry->name || !entry->full_path)
	{
		perror("ft_ls: malloc");
		free(entry->name);
		free(entry->full_path);
		return (-1);
	}
	if (lstat(entry->full_path, &entry->stats) == -1)
	{
		perror(display_name);
		free(entry->name);
		free(entry->full_path);
		return (-1);
	}
	return (0);
}



static int	recurse_directories(const t_options *opts,
	      t_entry *entries, size_t count)
{
	size_t	index;
	int		status;

	if (!(opts->flags & FT_LS_OPT_R_UPPER))
		return (0);
	status = 0;
	index = 0;
	while (index < count)
	{
		const t_entry *entry = &entries[index];

		if (S_ISDIR(entry->stats.st_mode)
			&& strcmp(entry->name, ".") != 0
			&& strcmp(entry->name, "..") != 0)
		{
			printf("\n");
			if (handle_directory(entry->full_path, opts, 1) != 0)
				status = 1;
		}
		index++;
	}
	return (status);
}

static int	handle_directory(const char *path, const t_options *opts,
		   int print_header)
{
	t_entry	*entries;
	size_t	count;
	int		status;

	if (collect_directory_entries(path, opts, &entries, &count) != 0)
		return (-1);
	if (print_header)
		printf("%s:\n", path);
	if (count > 0)
	{
		g_sort_options = opts;
		qsort(entries, count, sizeof(t_entry), compare_entries_qsort);
	}
	print_entries(entries, count, opts, 1);
	status = recurse_directories(opts, entries, count);
	free_entries(entries, count);
	return (status);
}

int	process_paths(int argc, char **argv, const t_options *opts, int first_path)
{
	int		status;
	t_entry	*file_entries;
	t_entry	*dir_entries;
	size_t	file_count;
	size_t	file_capacity;
	size_t	dir_count;
	size_t	dir_capacity;
	int		i;

	status = 0;
	file_entries = NULL;
	dir_entries = NULL;
	file_count = 0;
	dir_count = 0;
	file_capacity = 0;
	dir_capacity = 0;
	if (first_path >= argc)
		return (handle_directory(".", opts,
			(opts->flags & FT_LS_OPT_R_UPPER) != 0));
	i = first_path;
	while (i < argc)
	{
		t_entry entry;

		if (init_entry_from_path(&entry, argv[i], argv[i]) != 0)
		{
			status = 1;
			i++;
			continue ;
		}
		if (S_ISDIR(entry.stats.st_mode))
		{
			if (add_entry(&dir_entries, &dir_count, &dir_capacity, &entry) != 0)
			{
				perror("ft_ls: malloc");
				free(entry.name);
				free(entry.full_path);
				status = 1;
			}
		}
		else
		{
			if (add_entry(&file_entries, &file_count, &file_capacity, &entry) != 0)
			{
				perror("ft_ls: malloc");
				free(entry.name);
				free(entry.full_path);
				status = 1;
			}
		}
		i++;
	}
	if (file_count > 0)
	{
		g_sort_options = opts;
		qsort(file_entries, file_count, sizeof(t_entry), compare_entries_qsort);
		print_entries(file_entries, file_count, opts, 0);
	}
	if (file_count > 0 && dir_count > 0)
		printf("\n");
	if (dir_count > 0)
	{
		g_sort_options = opts;
		qsort(dir_entries, dir_count, sizeof(t_entry), compare_entries_qsort);
		i = 0;
		while (i < (int)dir_count)
		{
			int header;

			header = (dir_count > 1) || (file_count > 0)
				|| ((opts->flags & FT_LS_OPT_R_UPPER) != 0);
			if (handle_directory(dir_entries[i].full_path, opts, header) != 0)
				status = 1;
			if (i + 1 < (int)dir_count)
				printf("\n");
			i++;
		}
	}
	free_entries(file_entries, file_count);
	free_entries(dir_entries, dir_count);
	return (status);
}
