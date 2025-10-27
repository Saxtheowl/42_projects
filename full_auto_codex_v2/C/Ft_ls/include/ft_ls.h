#ifndef FT_LS_H
# define FT_LS_H

# include <dirent.h>
# include <sys/stat.h>
# include <stddef.h>

# define FT_LS_OPT_L (1 << 0)
# define FT_LS_OPT_R_UPPER (1 << 1)
# define FT_LS_OPT_A (1 << 2)
# define FT_LS_OPT_R (1 << 3)
# define FT_LS_OPT_T (1 << 4)

typedef struct s_options
{
	int flags;
} t_options;

typedef struct s_entry
{
	char		*name;
	char		*full_path;
	struct stat	stats;
}	t_entry;

int	parse_options(int argc, char **argv, t_options *opts, int *first_path);
int	process_paths(int argc, char **argv, const t_options *opts, int first_path);


#endif
