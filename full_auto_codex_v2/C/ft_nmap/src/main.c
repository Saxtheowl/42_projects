#include "ft_nmap.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int	add_target(char ***targets, size_t *count, size_t *cap,
					const char *token)
{
	size_t	len;
	char	*copy;
	char	**next;

	if (!token || *token == '\0')
		return (0);
	if (*count + 1 > *cap)
	{
		size_t	new_cap = (*cap == 0) ? 8 : (*cap * 2);

		next = realloc(*targets, sizeof(char *) * new_cap);
		if (!next)
			return (-1);
		*targets = next;
		*cap = new_cap;
	}
	len = strlen(token);
	copy = malloc(len + 1);
	if (!copy)
		return (-1);
	memcpy(copy, token, len + 1);
	(*targets)[*count] = copy;
	(*count)++;
	return (0);
}

static int	load_targets(const char *path, char ***targets_out,
					size_t *count_out)
{
	FILE	*f;
	char	line[4096];
	char	*token;
	char	*comment;
	size_t	count = 0;
	size_t	cap = 0;
	char	**targets = NULL;

	if (!path || !targets_out || !count_out)
		return (-1);
	if (strcmp(path, "-") == 0)
		f = stdin;
	else
		f = fopen(path, "r");
	if (!f)
		return (-1);
	while (fgets(line, sizeof(line), f))
	{
		comment = strchr(line, '#');
		if (comment)
			*comment = '\0';
		token = strtok(line, ", \t\r\n");
		while (token)
		{
			if (add_target(&targets, &count, &cap, token) != 0)
			{
				fclose(f);
				return (-1);
			}
			token = strtok(NULL, ", \t\r\n");
		}
	}
	if (f != stdin)
		fclose(f);
	if (count == 0)
	{
		free(targets);
		return (-1);
	}
	*targets_out = targets;
	*count_out = count;
	return (0);
}

static void	free_targets(char **targets, size_t count)
{
	if (!targets)
		return ;
	for (size_t i = 0; i < count; ++i)
		free(targets[i]);
	free(targets);
}

static char	*sanitize_target(const char *target)
{
	size_t	len;
	char	*safe;

	if (!target)
		return (NULL);
	len = strlen(target);
	safe = malloc(len + 1);
	if (!safe)
		return (NULL);
	for (size_t i = 0; i < len; ++i)
	{
		unsigned char c = (unsigned char)target[i];

		if (isalnum(c) || c == '.' || c == '-' || c == '_')
			safe[i] = (char)c;
		else
			safe[i] = '_';
	}
	safe[len] = '\0';
	return (safe);
}

static int	path_requires_template(const char *path)
{
	return (path && strstr(path, "%s") == NULL);
}

static int	path_is_stdout(const char *path)
{
	return (path && strcmp(path, "-") == 0);
}

static char	*format_path(const char *templ, const char *safe_target)
{
	char	*out;
	int		len;

	if (!templ)
		return (NULL);
	if (!safe_target)
	{
		out = malloc(strlen(templ) + 1);
		if (!out)
			return (NULL);
		strcpy(out, templ);
		return (out);
	}
	if (strstr(templ, "%s") == NULL)
	{
		out = malloc(strlen(templ) + 1);
		if (!out)
			return (NULL);
		strcpy(out, templ);
		return (out);
	}
	len = snprintf(NULL, 0, templ, safe_target);
	if (len < 0)
		return (NULL);
	out = malloc((size_t)len + 1);
	if (!out)
		return (NULL);
	snprintf(out, (size_t)len + 1, templ, safe_target);
	return (out);
}

static void	free_formatted_paths(t_options *opts)
{
	free((char *)opts->json_path);
	free((char *)opts->json_summary_path);
	free((char *)opts->csv_path);
	free((char *)opts->ndjson_path);
	free((char *)opts->yaml_path);
	free((char *)opts->xml_path);
	free((char *)opts->html_path);
	free((char *)opts->md_path);
	free((char *)opts->open_list_path);
}

int	main(int argc, char **argv)
{
	t_options	opts;
	t_summary	summary;
	char		**targets = NULL;
	size_t		target_count = 0;
	int			exit_code = 0;

	if (parse_options(argc, argv, &opts) != 0)
	{
		print_usage(argv[0]);
		return (1);
	}
	if (opts.help_only)
	{
		print_usage(argv[0]);
		free_options(&opts);
		return (0);
	}
	if (opts.version_only)
	{
		printf("ft_nmap %s\n", FT_NMAP_VERSION);
		free_options(&opts);
		return (0);
	}
	if (opts.targets_path)
	{
		if (load_targets(opts.targets_path, &targets, &target_count) != 0)
		{
			fprintf(stderr, "Failed to read targets from %s\n",
				opts.targets_path);
			free_options(&opts);
			return (1);
		}
	}
	else
	{
		targets = malloc(sizeof(char *));
		if (!targets)
		{
			free_options(&opts);
			return (1);
		}
		targets[0] = malloc(strlen(opts.target) + 1);
		if (!targets[0])
		{
			free(targets);
			free_options(&opts);
			return (1);
		}
		strcpy(targets[0], opts.target);
		target_count = 1;
	}
	if (target_count > 1)
	{
		const char	*paths[] = {
			opts.json_path, opts.json_summary_path, opts.csv_path,
			opts.ndjson_path, opts.yaml_path, opts.xml_path,
			opts.html_path, opts.md_path, opts.open_list_path
		};
		for (size_t i = 0; i < sizeof(paths) / sizeof(paths[0]); ++i)
		{
			if (path_is_stdout(paths[i]))
			{
				fprintf(stderr,
					"stdout export '-' not supported with multiple targets\n");
				free_targets(targets, target_count);
				free_options(&opts);
				return (1);
			}
			if (paths[i] && path_requires_template(paths[i]))
			{
				fprintf(stderr,
					"export path '%s' must include %%s when using -i\n",
					paths[i]);
				free_targets(targets, target_count);
				free_options(&opts);
				return (1);
			}
		}
	}
	for (size_t i = 0; i < target_count; ++i)
	{
		char		*safe = sanitize_target(targets[i]);
		t_options	scan_opts = opts;

		scan_opts.target = targets[i];
		scan_opts.json_path = format_path(opts.json_path, safe);
		scan_opts.json_summary_path = format_path(opts.json_summary_path, safe);
		scan_opts.csv_path = format_path(opts.csv_path, safe);
		scan_opts.ndjson_path = format_path(opts.ndjson_path, safe);
		scan_opts.yaml_path = format_path(opts.yaml_path, safe);
		scan_opts.xml_path = format_path(opts.xml_path, safe);
		scan_opts.html_path = format_path(opts.html_path, safe);
		scan_opts.md_path = format_path(opts.md_path, safe);
		scan_opts.open_list_path = format_path(opts.open_list_path, safe);
		free(safe);
		if ((opts.json_path && !scan_opts.json_path)
			|| (opts.json_summary_path && !scan_opts.json_summary_path)
			|| (opts.csv_path && !scan_opts.csv_path)
			|| (opts.ndjson_path && !scan_opts.ndjson_path)
			|| (opts.yaml_path && !scan_opts.yaml_path)
			|| (opts.xml_path && !scan_opts.xml_path)
			|| (opts.html_path && !scan_opts.html_path)
			|| (opts.md_path && !scan_opts.md_path)
			|| (opts.open_list_path && !scan_opts.open_list_path))
		{
			fprintf(stderr, "Failed to format export paths for %s\n",
				scan_opts.target);
			free_formatted_paths(&scan_opts);
			free_targets(targets, target_count);
			free_options(&opts);
			return (1);
		}
		if (scan_ports(&scan_opts, &summary) != 0)
		{
			fprintf(stderr, "Scan failed for %s\n", scan_opts.target);
			free_formatted_paths(&scan_opts);
			free_targets(targets, target_count);
			free_options(&opts);
			return (1);
		}
		free_formatted_paths(&scan_opts);
		if (summary.open_count > 0)
			exit_code = 2;
		else if (summary.timeout_count > 0 && exit_code == 0)
			exit_code = 3;
	}
	free_targets(targets, target_count);
	free_options(&opts);
	return (exit_code);
}
