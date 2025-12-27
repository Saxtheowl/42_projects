#include "ft_nmap.h"

#include <stdio.h>
#include <string.h>

static const char	*status_str(t_port_status st)
{
	if (st == FT_NMAP_STATUS_OPEN)
		return ("open");
	if (st == FT_NMAP_STATUS_CLOSED)
		return ("closed");
	if (st == FT_NMAP_STATUS_TIMEOUT)
		return ("timeout");
	return ("unknown");
}

static const char	*export_filter_str(t_export_filter filter)
{
	if (filter == FT_NMAP_EXPORT_OPEN_ONLY)
		return ("open");
	if (filter == FT_NMAP_EXPORT_KNOWN)
		return ("known");
	return ("all");
}

static void	write_port(FILE *f, const t_result *r, int show_service)
{
	fprintf(f, "{\"port\":%d,\"status\":\"%s\",\"duration_ms\":%ld,"
		"\"retries_used\":%d",
		r->port, status_str(r->status), r->duration_ms, r->retries_used);
	if (show_service && r->service[0] != '\0')
		fprintf(f, ",\"service\":\"%s\"", r->service);
	fprintf(f, "}");
}

int	write_json_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count)
{
	FILE	*f;
	double	kps;
	int		should_close;

	if (strcmp(opts->json_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->json_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	kps = (double)summary->scanned * 1000.0
		/ (double)(summary->elapsed_ms <= 0 ? 1 : summary->elapsed_ms);
	fprintf(f, "{");
	fprintf(f, "\"version\":\"%s\",", FT_NMAP_VERSION);
	fprintf(f, "\"target\":\"%s\",", opts->target);
	fprintf(f, "\"timeout_ms\":%ld,", opts->timeout_ms);
	fprintf(f, "\"resolved_ip\":\"%s\",", summary->resolved_ip);
	fprintf(f, "\"resolved_family\":\"%s\",", summary->resolved_family);
	fprintf(f, "\"resolved_count\":%zu,", summary->resolved_count);
	fprintf(f, "\"resolved\":[");
	for (size_t i = 0; i < summary->resolved_count
		&& i < FT_NMAP_MAX_RESOLVED; ++i)
	{
		if (i > 0)
			fprintf(f, ",");
		fprintf(f, "{\"ip\":\"%s\",\"family\":\"%s\"}",
			summary->resolved_list[i], summary->resolved_family_list[i]);
	}
	fprintf(f, "],");
	fprintf(f, "\"max_inflight\":%d,", opts->max_inflight);
	fprintf(f, "\"stats\":{\"requested\":%zu,\"scanned\":%zu,\"excluded\":%zu,"
		"\"pending\":%zu,\"open\":%zu,\"closed\":%zu,\"timeouts\":%zu,"
		"\"retries\":%zu,\"avg_retries_per_port\":%.2f,"
		"\"elapsed_ms\":%ld,\"kports_per_s\":%.2f,"
		"\"delay_ms\":%ld,\"randomized\":%s,\"random_seed\":%u,"
		"\"dry_run\":%s,"
		"\"retry_backoff_pct\":%d,"
		"\"open_rate\":%.2f,\"closed_rate\":%.2f,"
		"\"timeout_rate\":%.2f,\"first_open_ms\":%ld,"
		"\"duration_p50_ms\":%ld,\"duration_p90_ms\":%ld,"
		"\"duration_p99_ms\":%ld,\"fastest_port\":%d,"
		"\"fastest_duration_ms\":%ld,\"slowest_port\":%d,"
		"\"slowest_duration_ms\":%ld,\"timeout_stop_hit\":%s,"
		"\"timeout_stop_threshold\":%d,"
		"\"start_ms\":%ld,\"end_ms\":%ld,\"duration_min_ms\":%ld,"
		"\"duration_max_ms\":%ld,\"duration_mean_ms\":%ld,"
		"\"deadline_ms\":%ld,\"deadline_hit\":%s},",
		summary->requested, summary->scanned, summary->excluded_count,
		summary->pending, summary->open_count, summary->closed_count,
		summary->timeout_count, summary->retry_count,
		summary->avg_retries_per_port, summary->elapsed_ms,
		kps / 1000.0, opts->inter_batch_delay_ms,
		(summary->randomized ? "true" : "false"), summary->random_seed,
		(summary->dry_run ? "true" : "false"),
		summary->retry_backoff_pct, summary->open_rate,
		summary->closed_rate, summary->timeout_rate, summary->first_open_ms,
		summary->duration_p50_ms, summary->duration_p90_ms,
		summary->duration_p99_ms, summary->fastest_port,
		summary->fastest_duration_ms, summary->slowest_port,
		summary->slowest_duration_ms,
		(summary->timeout_stop_hit ? "true" : "false"),
		summary->timeout_stop_threshold,
		summary->start_ms,
		summary->end_ms, summary->duration_min_ms, summary->duration_max_ms,
		summary->duration_mean_ms, summary->deadline_ms,
		(summary->deadline_hit ? "true" : "false"));
	fprintf(f, "\"ports\":[");
	for (size_t i = 0; i < result_count; ++i)
	{
		if (i > 0)
			fprintf(f, ",");
		write_port(f, &results[i], opts->show_service);
	}
	fprintf(f, "]}");
	if (should_close)
		fclose(f);
	return (0);
}

static void	write_json_stats_body(FILE *f, const t_options *opts,
			const t_summary *summary, double kps)
{
	fprintf(f, "\"version\":\"%s\",", FT_NMAP_VERSION);
	fprintf(f, "\"target\":\"%s\",", opts->target);
	fprintf(f, "\"timeout_ms\":%ld,", opts->timeout_ms);
	fprintf(f, "\"resolved_ip\":\"%s\",", summary->resolved_ip);
	fprintf(f, "\"resolved_family\":\"%s\",", summary->resolved_family);
	fprintf(f, "\"resolved_count\":%zu,", summary->resolved_count);
	fprintf(f, "\"resolved\":[");
	for (size_t i = 0; i < summary->resolved_count
		&& i < FT_NMAP_MAX_RESOLVED; ++i)
	{
		if (i > 0)
			fprintf(f, ",");
		fprintf(f, "{\"ip\":\"%s\",\"family\":\"%s\"}",
			summary->resolved_list[i], summary->resolved_family_list[i]);
	}
	fprintf(f, "],");
	fprintf(f, "\"max_inflight\":%d,", opts->max_inflight);
fprintf(f, "\"export_filter\":\"%s\",", export_filter_str(opts->export_filter));
fprintf(f, "\"stats\":{\"requested\":%zu,\"scanned\":%zu,\"excluded\":%zu,"
	"\"pending\":%zu,\"open\":%zu,\"closed\":%zu,\"timeouts\":%zu,"
	"\"retries\":%zu,\"avg_retries_per_port\":%.2f,"
	"\"elapsed_ms\":%ld,\"kports_per_s\":%.2f,"
	"\"delay_ms\":%ld,\"randomized\":%s,\"random_seed\":%u,"
	"\"dry_run\":%s,"
	"\"retry_backoff_pct\":%d,"
		"\"open_rate\":%.2f,\"closed_rate\":%.2f,"
		"\"timeout_rate\":%.2f,\"first_open_ms\":%ld,"
		"\"duration_p50_ms\":%ld,\"duration_p90_ms\":%ld,"
		"\"duration_p99_ms\":%ld,\"fastest_port\":%d,"
		"\"fastest_duration_ms\":%ld,\"slowest_port\":%d,"
		"\"slowest_duration_ms\":%ld,\"timeout_stop_hit\":%s,"
		"\"timeout_stop_threshold\":%d,"
		"\"start_ms\":%ld,\"end_ms\":%ld,\"duration_min_ms\":%ld,"
		"\"duration_max_ms\":%ld,\"duration_mean_ms\":%ld,"
		"\"deadline_ms\":%ld,\"deadline_hit\":%s}",
		summary->requested, summary->scanned, summary->excluded_count,
		summary->pending, summary->open_count, summary->closed_count,
		summary->timeout_count, summary->retry_count,
		summary->avg_retries_per_port, summary->elapsed_ms, kps / 1000.0,
	opts->inter_batch_delay_ms,
	(summary->randomized ? "true" : "false"), summary->random_seed,
	(summary->dry_run ? "true" : "false"),
		summary->retry_backoff_pct, summary->open_rate,
		summary->closed_rate, summary->timeout_rate, summary->first_open_ms,
		summary->duration_p50_ms, summary->duration_p90_ms,
		summary->duration_p99_ms, summary->fastest_port,
		summary->fastest_duration_ms, summary->slowest_port,
		summary->slowest_duration_ms,
		(summary->timeout_stop_hit ? "true" : "false"),
		summary->timeout_stop_threshold,
		summary->start_ms,
		summary->end_ms, summary->duration_min_ms, summary->duration_max_ms,
		summary->duration_mean_ms, summary->deadline_ms,
		(summary->deadline_hit ? "true" : "false"));
}

int	write_json_stats(const t_options *opts, const t_summary *summary)
{
	FILE	*f;
	double	kps;
	int		should_close;

	if (strcmp(opts->json_summary_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->json_summary_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	kps = (double)summary->scanned * 1000.0
		/ (double)(summary->elapsed_ms <= 0 ? 1 : summary->elapsed_ms);
	fprintf(f, "{");
	write_json_stats_body(f, opts, summary, kps);
	fprintf(f, "}\n");
	if (should_close)
		fclose(f);
	return (0);
}

int	write_open_list(const t_options *opts, const t_result *results,
			size_t result_count)
{
	FILE	*f;
	int		should_close;

	if (strcmp(opts->open_list_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->open_list_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	for (size_t i = 0; i < result_count; ++i)
	{
		if (results[i].status != FT_NMAP_STATUS_OPEN)
			continue ;
		fprintf(f, "%d", results[i].port);
		if (opts->show_service && results[i].service[0] != '\0')
			fprintf(f, " %s", results[i].service);
		fprintf(f, "\n");
	}
	if (should_close)
		fclose(f);
	return (0);
}

int	write_csv_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count)
{
	FILE	*f;
	double	kps;
	int		should_close;

	if (strcmp(opts->csv_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->csv_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	kps = (double)summary->scanned * 1000.0
		/ (double)(summary->elapsed_ms <= 0 ? 1 : summary->elapsed_ms);
fprintf(f, "# version,%s\n", FT_NMAP_VERSION);
fprintf(f, "# target,%s\n", opts->target);
fprintf(f, "# timeout_ms,%ld\n", opts->timeout_ms);
fprintf(f, "# max_inflight,%d\n", opts->max_inflight);
fprintf(f, "# resolved_ip,%s\n", summary->resolved_ip);
fprintf(f, "# resolved_family,%s\n", summary->resolved_family);
fprintf(f, "# resolved_count,%zu\n", summary->resolved_count);
fprintf(f, "# requested,%zu,scanned,%zu,pending,%zu,excluded,%zu,open,%zu,closed,%zu,timeouts,%zu,retries,%zu,avg_retries_per_port,%.2f,retry_backoff_pct,%d,elapsed_ms,%ld,delay_ms,%ld,randomized,%s,dry_run,%s,random_seed,%u,open_rate,%.2f,closed_rate,%.2f,timeout_rate,%.2f,first_open_ms,%ld,duration_p50_ms,%ld,duration_p90_ms,%ld,duration_p99_ms,%ld,fastest_port,%d,fastest_duration_ms,%ld,slowest_port,%d,slowest_duration_ms,%ld,timeout_stop_hit,%s,timeout_stop_threshold,%d,kports_per_s,%.2f,start_ms,%ld,end_ms,%ld,duration_min_ms,%ld,duration_max_ms,%ld,duration_mean_ms,%ld,deadline_ms,%ld,deadline_hit,%s\n",
	summary->requested, summary->scanned, summary->pending,
	summary->excluded_count, summary->open_count, summary->closed_count,
	summary->timeout_count, summary->retry_count,
	summary->avg_retries_per_port, summary->retry_backoff_pct,
	summary->elapsed_ms,
	opts->inter_batch_delay_ms, (summary->randomized ? "true" : "false"),
	(summary->dry_run ? "true" : "false"),
	summary->random_seed, summary->open_rate, summary->closed_rate,
	summary->timeout_rate, summary->first_open_ms, summary->duration_p50_ms,
	summary->duration_p90_ms, summary->duration_p99_ms,
	summary->fastest_port, summary->fastest_duration_ms,
	summary->slowest_port, summary->slowest_duration_ms,
	(summary->timeout_stop_hit ? "true" : "false"),
	summary->timeout_stop_threshold,
	kps / 1000.0,
	summary->start_ms, summary->end_ms,
	summary->duration_min_ms, summary->duration_max_ms,
	summary->duration_mean_ms, summary->deadline_ms,
	(summary->deadline_hit ? "true" : "false"));
	fprintf(f, "port,status,duration_ms,retries_used,service\n");
	for (size_t i = 0; i < result_count; ++i)
	{
		fprintf(f, "%d,%s,%ld,%d,%s\n", results[i].port,
			status_str(results[i].status), results[i].duration_ms,
			results[i].retries_used,
			(opts->show_service ? results[i].service : ""));
	}
	if (should_close)
		fclose(f);
	return (0);
}

int	write_ndjson_results(const t_options *opts, const t_result *results,
			size_t count)
{
	FILE	*f;
	int		should_close;

	if (strcmp(opts->ndjson_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->ndjson_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	for (size_t i = 0; i < count; ++i)
	{
		fprintf(f, "{\"port\":%d,\"status\":\"%s\",\"duration_ms\":%ld,"
			"\"retries_used\":%d",
			results[i].port, status_str(results[i].status),
			results[i].duration_ms, results[i].retries_used);
		if (opts->show_service && results[i].service[0] != '\0')
			fprintf(f, ",\"service\":\"%s\"", results[i].service);
		fprintf(f, "}\n");
	}
	if (should_close)
		fclose(f);
	return (0);
}

void	print_table_summary(const t_options *opts, const t_result *results,
			size_t count)
{
	FILE	*out;

	out = opts->summary_to_stderr ? stderr : stdout;
	fprintf(out, "\nPORT\tSTATUS\t\tDURATION(ms)\tRETRIES");
	if (opts->show_service)
		fprintf(out, "\tSERVICE");
	fprintf(out, "\n");
	for (size_t i = 0; i < count; ++i)
	{
		if (opts->open_only && results[i].status != FT_NMAP_STATUS_OPEN)
			continue ;
		const char	*st = status_str(results[i].status);

		fprintf(out, "%d\t%-8s\t%ld\t\t%d", results[i].port, st,
			results[i].duration_ms, results[i].retries_used);
		if (opts->show_service)
			fprintf(out, "\t%s", results[i].service);
		fprintf(out, "\n");
	}
}

int	write_yaml_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count)
{
	FILE	*f;
	int		should_close;

	if (strcmp(opts->yaml_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->yaml_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	fprintf(f, "version: \"%s\"\n", FT_NMAP_VERSION);
	fprintf(f, "target: \"%s\"\n", opts->target);
	fprintf(f, "timeout_ms: %ld\n", opts->timeout_ms);
	fprintf(f, "max_inflight: %d\n", opts->max_inflight);
	fprintf(f, "resolved_ip: \"%s\"\n", summary->resolved_ip);
	fprintf(f, "resolved_family: \"%s\"\n", summary->resolved_family);
	fprintf(f, "resolved_count: %zu\n", summary->resolved_count);
	if (summary->resolved_count > 0)
	{
		fprintf(f, "resolved:\n");
		for (size_t i = 0; i < summary->resolved_count
			&& i < FT_NMAP_MAX_RESOLVED; ++i)
		{
			fprintf(f, "  - ip: \"%s\"\n", summary->resolved_list[i]);
			fprintf(f, "    family: \"%s\"\n", summary->resolved_family_list[i]);
		}
	}
	fprintf(f, "stats:\n");
	fprintf(f, "  requested: %zu\n", summary->requested);
	fprintf(f, "  scanned: %zu\n", summary->scanned);
	fprintf(f, "  pending: %zu\n", summary->pending);
	fprintf(f, "  excluded: %zu\n", summary->excluded_count);
	fprintf(f, "  open: %zu\n", summary->open_count);
	fprintf(f, "  closed: %zu\n", summary->closed_count);
	fprintf(f, "  timeouts: %zu\n", summary->timeout_count);
	fprintf(f, "  retries: %zu\n", summary->retry_count);
	fprintf(f, "  avg_retries_per_port: %.2f\n", summary->avg_retries_per_port);
	fprintf(f, "  retry_backoff_pct: %d\n", summary->retry_backoff_pct);
	fprintf(f, "  elapsed_ms: %ld\n", summary->elapsed_ms);
	fprintf(f, "  delay_ms: %ld\n", opts->inter_batch_delay_ms);
	fprintf(f, "  randomized: %s\n", summary->randomized ? "true" : "false");
	fprintf(f, "  dry_run: %s\n", summary->dry_run ? "true" : "false");
	fprintf(f, "  random_seed: %u\n", summary->random_seed);
	fprintf(f, "  open_rate: %.2f\n", summary->open_rate);
	fprintf(f, "  closed_rate: %.2f\n", summary->closed_rate);
	fprintf(f, "  timeout_rate: %.2f\n", summary->timeout_rate);
	fprintf(f, "  first_open_ms: %ld\n", summary->first_open_ms);
	fprintf(f, "  duration_p50_ms: %ld\n", summary->duration_p50_ms);
	fprintf(f, "  duration_p90_ms: %ld\n", summary->duration_p90_ms);
	fprintf(f, "  duration_p99_ms: %ld\n", summary->duration_p99_ms);
	fprintf(f, "  fastest_port: %d\n", summary->fastest_port);
	fprintf(f, "  fastest_duration_ms: %ld\n", summary->fastest_duration_ms);
	fprintf(f, "  slowest_port: %d\n", summary->slowest_port);
	fprintf(f, "  slowest_duration_ms: %ld\n", summary->slowest_duration_ms);
	fprintf(f, "  timeout_stop_hit: %s\n",
		(summary->timeout_stop_hit ? "true" : "false"));
	fprintf(f, "  timeout_stop_threshold: %d\n",
		summary->timeout_stop_threshold);
	fprintf(f, "  start_ms: %ld\n", summary->start_ms);
	fprintf(f, "  end_ms: %ld\n", summary->end_ms);
	fprintf(f, "  duration_min_ms: %ld\n", summary->duration_min_ms);
	fprintf(f, "  duration_max_ms: %ld\n", summary->duration_max_ms);
	fprintf(f, "  duration_mean_ms: %ld\n", summary->duration_mean_ms);
	fprintf(f, "  deadline_ms: %ld\n", summary->deadline_ms);
	fprintf(f, "  deadline_hit: %s\n",
		(summary->deadline_hit ? "true" : "false"));
	fprintf(f, "ports:\n");
	for (size_t i = 0; i < result_count; ++i)
	{
		fprintf(f, "  - port: %d\n", results[i].port);
		fprintf(f, "    status: \"%s\"\n", status_str(results[i].status));
		fprintf(f, "    duration_ms: %ld\n", results[i].duration_ms);
		fprintf(f, "    retries_used: %d\n", results[i].retries_used);
		if (opts->show_service && results[i].service[0] != '\0')
			fprintf(f, "    service: \"%s\"\n", results[i].service);
	}
	if (should_close)
		fclose(f);
	return (0);
}

static void	html_escape(const char *src, FILE *f)
{
	for (; *src; ++src)
	{
		if (*src == '<')
			fputs("&lt;", f);
		else if (*src == '>')
			fputs("&gt;", f);
		else if (*src == '&')
			fputs("&amp;", f);
		else if (*src == '"')
			fputs("&quot;", f);
		else
			fputc(*src, f);
	}
}

static void	xml_escape(const char *src, FILE *f)
{
	for (; *src; ++src)
	{
		if (*src == '<')
			fputs("&lt;", f);
		else if (*src == '>')
			fputs("&gt;", f);
		else if (*src == '&')
			fputs("&amp;", f);
		else if (*src == '"')
			fputs("&quot;", f);
		else if (*src == '\'')
			fputs("&apos;", f);
		else
			fputc(*src, f);
	}
}

int	write_html_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count)
{
	FILE	*f;
	double	kps;
	int		should_close;

	if (strcmp(opts->html_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->html_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	kps = (double)summary->scanned * 1000.0
		/ (double)(summary->elapsed_ms <= 0 ? 1 : summary->elapsed_ms);
	fprintf(f, "<!DOCTYPE html><html><head><meta charset=\"utf-8\"/>"
		"<title>ft_nmap report for ");
	html_escape(opts->target, f);
	fprintf(f, "</title><style>body{font-family:Arial,Helvetica,sans-serif;"
		"margin:20px;}table{border-collapse:collapse;width:100%%;margin-top:10px;}"
		"th,td{border:1px solid #ddd;padding:6px;text-align:left;}"
		"th{background:#f0f0f0;}code{background:#f7f7f7;padding:2px 4px;}"
		".stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(180px,1fr));gap:8px;}"
		".card{border:1px solid #ddd;border-radius:4px;padding:8px;background:#fafafa;}"
		"</style></head><body>");
	fprintf(f, "<h1>ft_nmap report</h1>");
	fprintf(f, "<p><strong>Version:</strong> %s</p>", FT_NMAP_VERSION);
	fprintf(f, "<p><strong>Target:</strong> ");
	html_escape(opts->target, f);
	fprintf(f, " &mdash; <strong>Timeout:</strong> %ld ms &mdash; <strong>Inflight:</strong> %d",
		opts->timeout_ms, opts->max_inflight);
	if (summary->resolved_ip[0] != '\0')
	{
		fprintf(f, " &mdash; <strong>Resolved:</strong> ");
		html_escape(summary->resolved_ip, f);
		fprintf(f, " (%s)", summary->resolved_family);
		if (summary->resolved_count > 1)
			fprintf(f, " +%zu alt", summary->resolved_count - 1);
		if (opts->ip_override_set)
			fprintf(f, " [override]");
	}
	fprintf(f, "</p>");
	if (summary->resolved_count > 1)
	{
		fprintf(f, "<p><strong>All addresses:</strong> ");
		for (size_t i = 0; i < summary->resolved_count
			&& i < FT_NMAP_MAX_RESOLVED; ++i)
		{
			if (i > 0)
				fprintf(f, ", ");
			html_escape(summary->resolved_list[i], f);
			fprintf(f, " (%s)", summary->resolved_family_list[i]);
		}
		fprintf(f, "</p>");
	}
	if (summary->dry_run)
		fprintf(f, "<p><strong>Dry run:</strong> resolution only, ports left pending.</p>");
	fprintf(f, "<div class=\"stats-grid\">");
	fprintf(f, "<div class=\"card\"><strong>Requested</strong><br/>%zu</div>", summary->requested);
	fprintf(f, "<div class=\"card\"><strong>Scanned</strong><br/>%zu</div>", summary->scanned);
	fprintf(f, "<div class=\"card\"><strong>Pending</strong><br/>%zu</div>", summary->pending);
	fprintf(f, "<div class=\"card\"><strong>Excluded</strong><br/>%zu</div>", summary->excluded_count);
	fprintf(f, "<div class=\"card\"><strong>Open</strong><br/>%zu (%.2f%%)</div>", summary->open_count, summary->open_rate);
	fprintf(f, "<div class=\"card\"><strong>Closed</strong><br/>%zu (%.2f%%)</div>", summary->closed_count, summary->closed_rate);
	fprintf(f, "<div class=\"card\"><strong>Timeouts</strong><br/>%zu (%.2f%%)</div>", summary->timeout_count, summary->timeout_rate);
	fprintf(f, "<div class=\"card\"><strong>Retries</strong><br/>%zu (avg %.2f, backoff %d%%)</div>",
		summary->retry_count, summary->avg_retries_per_port, summary->retry_backoff_pct);
	fprintf(f, "<div class=\"card\"><strong>Elapsed</strong><br/>%ld ms</div>", summary->elapsed_ms);
	fprintf(f, "<div class=\"card\"><strong>Rate</strong><br/>%.2f kports/s</div>", kps / 1000.0);
	if (summary->first_open_ms >= 0)
		fprintf(f, "<div class=\"card\"><strong>First open</strong><br/>%ld ms</div>", summary->first_open_ms);
	else
		fprintf(f, "<div class=\"card\"><strong>First open</strong><br/>n/a</div>");
	fprintf(f, "<div class=\"card\"><strong>Durations</strong><br/>min %ld / avg %ld / p50 %ld / p90 %ld / p99 %ld / max %ld ms</div>",
		summary->duration_min_ms, summary->duration_mean_ms, summary->duration_p50_ms,
		summary->duration_p90_ms, summary->duration_p99_ms, summary->duration_max_ms);
	if (summary->fastest_port != -1)
		fprintf(f, "<div class=\"card\"><strong>Fastest</strong><br/>%d (%ld ms)</div>",
			summary->fastest_port, summary->fastest_duration_ms);
	if (summary->slowest_port != -1)
		fprintf(f, "<div class=\"card\"><strong>Slowest</strong><br/>%d (%ld ms)</div>",
			summary->slowest_port, summary->slowest_duration_ms);
	fprintf(f, "<div class=\"card\"><strong>Randomized</strong><br/>%s",
		summary->randomized ? "yes" : "no");
	if (summary->randomized)
		fprintf(f, " (seed %u)", summary->random_seed);
	fprintf(f, "</div>");
	fprintf(f, "<div class=\"card\"><strong>Dry run</strong><br/>%s</div>",
		summary->dry_run ? "yes" : "no");
	if (summary->timeout_stop_threshold > 0)
		fprintf(f, "<div class=\"card\"><strong>Timeout-stop</strong><br/>%s (%d)</div>",
			summary->timeout_stop_hit ? "hit" : "not hit", summary->timeout_stop_threshold);
	if (summary->deadline_ms > 0)
		fprintf(f, "<div class=\"card\"><strong>Deadline</strong><br/>%ld ms (%s)</div>",
			summary->deadline_ms, summary->deadline_hit ? "hit" : "not hit");
	fprintf(f, "</div>");

	fprintf(f, "<h2>Ports</h2><table><thead><tr>"
		"<th>Port</th><th>Status</th><th>Duration (ms)</th><th>Retries</th>");
	if (opts->show_service)
		fprintf(f, "<th>Service</th>");
	fprintf(f, "</tr></thead><tbody>");
	for (size_t i = 0; i < result_count; ++i)
	{
		fprintf(f, "<tr><td>%d</td><td>%s</td><td>%ld</td><td>%d</td>",
			results[i].port, status_str(results[i].status),
			results[i].duration_ms, results[i].retries_used);
		if (opts->show_service)
		{
			fprintf(f, "<td>");
			html_escape(results[i].service, f);
			fprintf(f, "</td>");
		}
		fprintf(f, "</tr>");
	}
	fprintf(f, "</tbody></table>");
	fprintf(f, "<p><small>Generated by ft_nmap. Start: %ld, End: %ld.</small></p>",
		summary->start_ms, summary->end_ms);
	fprintf(f, "</body></html>");
	if (should_close)
		fclose(f);
	return (0);
}

int	write_md_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count)
{
	FILE	*f;
	double	kps;
	int		should_close;

	if (strcmp(opts->md_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->md_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	kps = (double)summary->scanned * 1000.0
		/ (double)(summary->elapsed_ms <= 0 ? 1 : summary->elapsed_ms);
	fprintf(f, "# ft_nmap report\n\n");
	fprintf(f, "- **Version**: %s\n", FT_NMAP_VERSION);
	fprintf(f, "- **Target**: `%s`\n", opts->target);
	if (summary->resolved_ip[0] != '\0')
	{
		fprintf(f, "- **Resolved**: `%s` (%s)", summary->resolved_ip,
			summary->resolved_family);
		if (summary->resolved_count > 1)
			fprintf(f, " (+%zu alt)", summary->resolved_count - 1);
		if (opts->ip_override_set)
			fprintf(f, " [override]");
		fprintf(f, "\n");
	}
	fprintf(f, "- **Timeout**: %ld ms, **Inflight**: %d\n", opts->timeout_ms,
		opts->max_inflight);
	fprintf(f, "- **Requested**: %zu, **Scanned**: %zu, **Pending**: %zu, **Excluded**: %zu\n",
		summary->requested, summary->scanned, summary->pending,
		summary->excluded_count);
	fprintf(f, "- **Open/Closed/Timeouts**: %zu (%.2f%%) / %zu (%.2f%%) / %zu (%.2f%%)\n",
		summary->open_count, summary->open_rate, summary->closed_count,
		summary->closed_rate, summary->timeout_count, summary->timeout_rate);
	fprintf(f, "- **Retries**: %zu (avg %.2f, backoff %d%%)\n",
		summary->retry_count, summary->avg_retries_per_port,
		summary->retry_backoff_pct);
	fprintf(f, "- **Elapsed**: %ld ms, **Rate**: %.2f kports/s\n",
		summary->elapsed_ms, kps / 1000.0);
	fprintf(f, "- **Durations**: min %ld / avg %ld / p50 %ld / p90 %ld / p99 %ld / max %ld ms\n",
		summary->duration_min_ms, summary->duration_mean_ms,
		summary->duration_p50_ms, summary->duration_p90_ms,
		summary->duration_p99_ms, summary->duration_max_ms);
	if (summary->fastest_port != -1 || summary->slowest_port != -1)
	{
		fprintf(f, "- **Fastest/Slowest**: ");
		if (summary->fastest_port != -1)
			fprintf(f, "%d (%ld ms)", summary->fastest_port,
				summary->fastest_duration_ms);
		else
			fprintf(f, "n/a");
		fprintf(f, " / ");
		if (summary->slowest_port != -1)
			fprintf(f, "%d (%ld ms)", summary->slowest_port,
				summary->slowest_duration_ms);
		else
			fprintf(f, "n/a");
		fprintf(f, "\n");
	}
	fprintf(f, "- **Randomized**: %s", summary->randomized ? "yes" : "no");
	if (summary->randomized)
		fprintf(f, " (seed %u)", summary->random_seed);
	fprintf(f, "\n");
	fprintf(f, "- `dry_run: %s` (resolution only when true)\n",
		summary->dry_run ? "true" : "false");
	if (summary->deadline_ms > 0)
		fprintf(f, "- **Deadline**: %ld ms (%s)\n", summary->deadline_ms,
			summary->deadline_hit ? "hit" : "not hit");
	if (summary->timeout_stop_threshold > 0)
		fprintf(f, "- **Timeout stop**: %s after %d timeouts\n",
			summary->timeout_stop_hit ? "hit" : "not hit",
			summary->timeout_stop_threshold);
	if (summary->first_open_ms >= 0)
		fprintf(f, "- **First open**: %ld ms\n", summary->first_open_ms);
	fprintf(f, "\n## Ports\n\n");
	fprintf(f, "| Port | Status | Duration (ms) | Retries | Service |\n");
	fprintf(f, "| ---- | ------ | ------------- | ------- | ------- |\n");
	for (size_t i = 0; i < result_count; ++i)
	{
		fprintf(f, "| %d | %s | %ld | %d | ",
			results[i].port, status_str(results[i].status),
			results[i].duration_ms, results[i].retries_used);
		if (opts->show_service && results[i].service[0] != '\0')
			fprintf(f, "%s", results[i].service);
		fprintf(f, " |\n");
	}
	fprintf(f, "\n_Generated by ft_nmap. Start: %ld, End: %ld._\n",
		summary->start_ms, summary->end_ms);
	if (should_close)
		fclose(f);
	return (0);
}

int	write_xml_summary(const t_options *opts, const t_summary *summary,
			const t_result *results, size_t result_count)
{
	FILE	*f;
	double	kps;
	int		should_close;

	if (strcmp(opts->xml_path, "-") == 0)
	{
		f = stdout;
		should_close = 0;
	}
	else
	{
		f = fopen(opts->xml_path, "w");
		if (!f)
			return (-1);
		should_close = 1;
	}
	kps = (double)summary->scanned * 1000.0
		/ (double)(summary->elapsed_ms <= 0 ? 1 : summary->elapsed_ms);
	fprintf(f, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	fprintf(f, "<ft_nmap version=\"%s\" target=\"", FT_NMAP_VERSION);
	xml_escape(opts->target, f);
	fprintf(f,
		"\" timeout_ms=\"%ld\" max_inflight=\"%d\" resolved_ip=\"%s\" resolved_family=\"%s\" resolved_count=\"%zu\" export_filter=\"%s\" delay_ms=\"%ld\" randomized=\"%s\" dry_run=\"%s\"",
		opts->timeout_ms, opts->max_inflight, summary->resolved_ip,
		summary->resolved_family, summary->resolved_count,
		export_filter_str(opts->export_filter),
		opts->inter_batch_delay_ms, summary->randomized ? "true" : "false",
		summary->dry_run ? "true" : "false");
	if (summary->resolved_count > 1)
	{
		fprintf(f, " resolved_alt=\"");
		for (size_t i = 1; i < summary->resolved_count
			&& i < FT_NMAP_MAX_RESOLVED; ++i)
		{
			if (i > 1)
				fputc(' ', f);
			xml_escape(summary->resolved_list[i], f);
			fprintf(f, "(%s)", summary->resolved_family_list[i]);
		}
		fprintf(f, "\"");
	}
	if (summary->randomized)
		fprintf(f, " random_seed=\"%u\"", summary->random_seed);
	fprintf(f, " retry_backoff_pct=\"%d\">\n", summary->retry_backoff_pct);
	fprintf(f,
		"  <stats requested=\"%zu\" scanned=\"%zu\" pending=\"%zu\" excluded=\"%zu\" open=\"%zu\" closed=\"%zu\" timeouts=\"%zu\" retries=\"%zu\" avg_retries_per_port=\"%.2f\" elapsed_ms=\"%ld\" kports_per_s=\"%.2f\" open_rate=\"%.2f\" closed_rate=\"%.2f\" timeout_rate=\"%.2f\" first_open_ms=\"%ld\" duration_min_ms=\"%ld\" duration_mean_ms=\"%ld\" duration_p50_ms=\"%ld\" duration_p90_ms=\"%ld\" duration_p99_ms=\"%ld\" duration_max_ms=\"%ld\" fastest_port=\"%d\" fastest_duration_ms=\"%ld\" slowest_port=\"%d\" slowest_duration_ms=\"%ld\" timeout_stop_hit=\"%s\" timeout_stop_threshold=\"%d\" dry_run=\"%s\" deadline_ms=\"%ld\" deadline_hit=\"%s\" start_ms=\"%ld\" end_ms=\"%ld\" />\n",
		summary->requested, summary->scanned, summary->pending,
		summary->excluded_count, summary->open_count, summary->closed_count,
		summary->timeout_count, summary->retry_count,
		summary->avg_retries_per_port, summary->elapsed_ms, kps / 1000.0,
		summary->open_rate, summary->closed_rate, summary->timeout_rate,
		summary->first_open_ms, summary->duration_min_ms,
		summary->duration_mean_ms, summary->duration_p50_ms,
		summary->duration_p90_ms, summary->duration_p99_ms,
		summary->duration_max_ms, summary->fastest_port,
		summary->fastest_duration_ms, summary->slowest_port,
		summary->slowest_duration_ms,
		summary->timeout_stop_hit ? "true" : "false",
		summary->timeout_stop_threshold, summary->dry_run ? "true" : "false",
		summary->deadline_ms, summary->deadline_hit ? "true" : "false",
		summary->start_ms, summary->end_ms);
	fprintf(f, "  <ports count=\"%zu\">\n", result_count);
	for (size_t i = 0; i < result_count; ++i)
	{
		fprintf(f, "    <port id=\"%d\" status=\"%s\" duration_ms=\"%ld\" retries_used=\"%d\"",
			results[i].port, status_str(results[i].status),
			results[i].duration_ms, results[i].retries_used);
		if (opts->show_service && results[i].service[0] != '\0')
		{
			fprintf(f, " service=\"");
			xml_escape(results[i].service, f);
			fprintf(f, "\"");
		}
		fprintf(f, " />\n");
	}
	fprintf(f, "  </ports>\n</ft_nmap>\n");
	if (should_close)
		fclose(f);
	return (0);
}
