#include "ft_nmap.h"

#include <stdio.h>

int	main(int argc, char **argv)
{
	t_options	opts;
	t_summary	summary;

	if (parse_options(argc, argv, &opts) != 0)
	{
		print_usage(argv[0]);
		return (1);
	}
	if (opts.version_only)
	{
		printf("ft_nmap %s\n", FT_NMAP_VERSION);
		free_options(&opts);
		return (0);
	}
	if (scan_ports(&opts, &summary) != 0)
	{
		fprintf(stderr, "Scan failed\n");
		free_options(&opts);
		return (1);
	}
	free_options(&opts);
	if (summary.open_count > 0)
		return (2);
	if (summary.timeout_count > 0)
		return (3);
	return (0);
}
