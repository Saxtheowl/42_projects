#include "ft_nmap.h"

#include <stdio.h>

void	print_usage(const char *prog)
{
	printf("Usage: %s -t target | -i targets.txt [-p ports|-P file|-k top] [-x ports|-X file] [-T timeout_ms] [-c inflight] [-R retries] [-b backoff_pct] [-w delay_ms] [-M deadline_ms] [-f stop_after_open| -F] [-q] [-O] [-S] [-l] [-r] [-e seed] [-g progress_ms] [-I ip_override] [-4|-6] [--scan tcp|udp] [-n] [-o file.json] [-J summary.json] [-C file.csv] [-N file.ndjson] [-Y file.yaml] [-Z file.xml] [-H file.html] [-m file.md] [-L open_ports.txt] [-E export_filter] [-Q] [-V]\n",
		prog);
	printf("  -h, --help    Show this help screen\n");
	printf("  -t target     Target hostname or IPv4 address (required)\n");
	printf("  --ip target   Long-form alias for -t\n");
	printf("  -i file       File containing target hosts/IPs (one per line, or comma/space separated)\n");
	printf("  --file file   Long-form alias for -i\n");
	printf("  -p ports      Comma-separated list or ranges (e.g. 22,80-90,443,https)\n");
	printf("               (max %d ports after exclusions)\n", FT_NMAP_MAX_SCAN_PORTS);
printf("  -P file       File containing ports/ranges/service names (whitespace/comma separated, last -p/-P wins)\n");
	printf("  --ports ports Long-form alias for -p\n");
	printf("  -k top        Scan the TOP <n> common TCP ports (built-in list)\n");
printf("  -x ports      Exclude ports/ranges/service names from the scan\n");
printf("  -X file       File with ports/ranges/service names to exclude (last -x/-X wins)\n");
	printf("  -F            Stop scanning after the first OPEN port is found (shortcut for -f 1)\n");
	printf("  -f n          Stop scanning after <n> OPEN ports are found (marks remaining as pending/unknown)\n");
printf("  -T timeout_ms Timeout per connection attempt (default %d ms)\n",
	FT_NMAP_DEFAULT_TIMEOUT_MS);
	printf("  -c inflight   Max simultaneous connections (1-%d, default 256)\n",
		FT_NMAP_MAX_INFLIGHT);
	printf("  --speedup n   Long-form alias for -c\n");
	printf("  -R retries    Retry count on TIMEOUT (0-5, default 0)\n");
	printf("  -b pct        Increase timeout by <pct>%% for each retry (exponential-style backoff)\n");
	printf("  -w delay_ms   Delay between poll cycles (ms) to rate-limit batches (0-60000)\n");
	printf("  -M deadline_ms Stop the scan after this duration (ms) and mark remaining ports as pending\n");
	printf("  -q            Quiet: only final summary\n");
	printf("  -O            Only print per-port lines for OPEN ports\n");
	printf("  -u n          Stop the scan after <n> timeouts and mark remaining ports as pending/unknown\n");
	printf("  -S            Show service names when available\n");
	printf("  -l            Print a table summary after the scan\n");
	printf("  -r            Randomize port order\n");
	printf("  -e seed       Force a deterministic random seed (implies -r) to reproduce shuffled order\n");
	printf("  -g progress_ms Print periodic progress to stderr every <progress_ms> milliseconds (scanned/open/closed/timeouts/active)\n");
	printf("  -I ip         Override DNS and scan this IPv4/IPv6 literal instead of the resolved address\n");
	printf("  -n            Dry run: resolve the target but skip all socket probes (ports remain pending/unknown)\n");
	printf("  -V            Show version and exit\n");
	printf("  -4/-6         Force IPv4 or IPv6 resolution only (default: both)\n");
	printf("  -o file.json  Save results and stats as JSON\n");
	printf("  -J file.json  Save only stats (sans ports) as JSON (lighter payload)\n");
	printf("  -C file.csv   Save results and stats as CSV\n");
	printf("  -N file.ndjson Save per-port lines as NDJSON (one JSON object per line)\n");
	printf("  -Y file.yaml  Save results and stats as YAML (human-friendly)\n");
	printf("  -Z file.xml   Save results and stats as XML (attributes + ports list)\n");
	printf("  -H file.html  Save results and stats as a self-contained HTML report\n");
	printf("  -m file.md    Save results and stats as a Markdown report (human-readable)\n");
	printf("  -L file.txt   Write the list of OPEN ports only (one per line, optional service when -S)\n");
	printf("  -E filter     Filter exports: 'all' (default), 'open' (only OPEN), 'known' (exclude unknown/pending)\n");
	printf("  -Q            Send the final summary/table to stderr (useful when exporting to stdout with paths set to '-')\n");
	printf("  --scan type   Scan type: tcp (connect) or udp (default: tcp)\n");
	printf("\nNotes: for export paths, use '-' to write to stdout. When a stdout export is used, the summary is automatically sent to stderr to avoid mixing formats.\n");
	printf("Notes: when scanning multiple targets with -i, export paths must include '%%s' to inject the target name (e.g. report_%%s.json).\n");
}
