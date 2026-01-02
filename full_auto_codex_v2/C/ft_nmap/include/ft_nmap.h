#ifndef FT_NMAP_H
# define FT_NMAP_H

# include <netdb.h>
# include <sys/socket.h>
# include <sys/types.h>
# include <sys/time.h>
# include <unistd.h>
# include <stddef.h>
# include <time.h>

# define FT_NMAP_DEFAULT_TIMEOUT_MS 500
# define FT_NMAP_MAX_PORTS 65535
# define FT_NMAP_MAX_INFLIGHT 1024
# define FT_NMAP_MAX_RESOLVED 8
# define FT_NMAP_VERSION "0.2.5"
# define FT_NMAP_MAX_SCAN_PORTS 1024

typedef enum e_port_status
{
	FT_NMAP_STATUS_UNKNOWN = 0,
	FT_NMAP_STATUS_OPEN,
	FT_NMAP_STATUS_CLOSED,
	FT_NMAP_STATUS_TIMEOUT
}	t_port_status;

typedef struct s_ports
{
	int		*values;
	size_t	count;
	size_t	capacity;
}	t_ports;

typedef struct s_result
{
	int				port;
	t_port_status	status;
	long			duration_ms;
	int				retries_used;
	char			service[64];
}	t_result;

typedef struct s_summary
{
	size_t	scanned;
	size_t	requested;
	size_t	pending;
	size_t	excluded_count;
	size_t	open_count;
	size_t	closed_count;
	size_t	timeout_count;
	size_t	retry_count;
	double	open_rate;
	double	closed_rate;
	double	timeout_rate;
	double	avg_retries_per_port;
	long	first_open_ms;
	long	elapsed_ms;
	int		randomized;
	unsigned int	random_seed;
	int		dry_run;
	long	start_ms;
	long	end_ms;
	long	duration_min_ms;
	long	duration_max_ms;
	long	duration_mean_ms;
	long	duration_p50_ms;
	long	duration_p90_ms;
	long	duration_p99_ms;
	int		fastest_port;
	long	fastest_duration_ms;
	int		slowest_port;
	long	slowest_duration_ms;
	int		timeout_stop_hit;
	int		timeout_stop_threshold;
	int		deadline_hit;
	long	deadline_ms;
	int		retry_backoff_pct;
	char	resolved_ip[NI_MAXHOST];
	char	resolved_family[16];
	size_t	resolved_count;
	char	resolved_list[FT_NMAP_MAX_RESOLVED][NI_MAXHOST];
	char	resolved_family_list[FT_NMAP_MAX_RESOLVED][16];
}	t_summary;

typedef enum e_export_filter
{
	FT_NMAP_EXPORT_ALL = 0,
	FT_NMAP_EXPORT_OPEN_ONLY,
	FT_NMAP_EXPORT_KNOWN
}	t_export_filter;

typedef enum e_scan_type
{
	FT_NMAP_SCAN_TCP = 0,
	FT_NMAP_SCAN_UDP
}	t_scan_type;

typedef struct s_options
{
	const char	*target;
	t_ports		ports;
	t_ports		exclude;
	size_t		excluded_count;
	int			stop_on_open_count;
	long		timeout_ms;
	int			max_inflight;
	int			quiet;
	int			show_service;
	const char	*json_path;
	const char	*json_summary_path;
	const char	*csv_path;
	const char	*ndjson_path;
	const char	*yaml_path;
	const char	*html_path;
	const char	*md_path;
	const char	*xml_path;
	int			summary_to_stderr;
	const char	*open_list_path;
	t_export_filter	export_filter;
	int			list_table;
	int			randomize;
	int			ai_family;
	int			retries;
	int			open_only;
	int			top_n;
	long		inter_batch_delay_ms;
	long		deadline_ms;
	unsigned int	random_seed;
	const char	*ip_override;
	int			ip_override_set;
	int			random_seed_set;
	long		progress_interval_ms;
	int			stop_on_timeout_count;
	int			retry_backoff_pct;
	int			dry_run;
	int			version_only;
	int			help_only;
	const char	*targets_path;
	t_scan_type	scan_type;
}	t_options;

int		parse_options(int argc, char **argv, t_options *out);
int		scan_ports(const t_options *opts, t_summary *out_summary);
int		parse_ports(const char *str, t_ports *out);
int		parse_ports_file(const char *path, t_ports *out);
void	print_usage(const char *prog);
void	free_options(t_options *opts);
int		write_json_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count);
int		write_json_stats(const t_options *opts, const t_summary *summary);
int		write_open_list(const t_options *opts, const t_result *results,
			size_t result_count);
int		write_csv_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count);
int		write_ndjson_results(const t_options *opts, const t_result *results,
			size_t count);
int		write_yaml_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count);
int		write_html_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count);
int		write_md_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count);
int		write_xml_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count);
void	print_table_summary(const t_options *opts, const t_result *results,
			size_t count);

#endif
