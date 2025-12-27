#include "ft_nmap.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <limits.h>
#include <netdb.h>
#include <poll.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <time.h>

#define FT_NMAP_MAX_RETRIES 5

static void	report_port(const t_options *opts, const t_result *res)
{
	if (opts->quiet)
		return ;
	if (opts->open_only && res->status != FT_NMAP_STATUS_OPEN)
		return ;
	if (res->status == FT_NMAP_STATUS_OPEN)
	{
		if (res->retries_used > 0)
			printf("%s:%d open (retries=%d, %ldms)", opts->target, res->port,
				res->retries_used, res->duration_ms);
		else
			printf("%s:%d open", opts->target, res->port);
		if (opts->show_service && res->service[0] != '\0')
			printf(" (%s)", res->service);
		printf("\n");
		return ;
	}
	if (res->status == FT_NMAP_STATUS_CLOSED)
	{
		if (res->retries_used > 0)
			printf("%s:%d closed (retries=%d, %ldms)\n", opts->target,
				res->port, res->retries_used, res->duration_ms);
		else
			printf("%s:%d closed (%ldms)\n", opts->target, res->port,
				res->duration_ms);
	}
	else if (res->status == FT_NMAP_STATUS_TIMEOUT)
		printf("%s:%d timeout (retries=%d, %ldms)\n", opts->target, res->port,
			res->retries_used, res->duration_ms);
}

static int	make_nonblocking(int fd)
{
	int	flags;

	flags = fcntl(fd, F_GETFL, 0);
	if (flags == -1)
		return (-1);
	return (fcntl(fd, F_SETFL, flags | O_NONBLOCK));
}

static int	set_port(struct sockaddr *sa, socklen_t len, int port)
{
	if (sa->sa_family == AF_INET)
	{
		struct sockaddr_in *in = (struct sockaddr_in *)sa;

		if (len < sizeof(struct sockaddr_in))
			return (-1);
		in->sin_port = htons(port);
		return (0);
	}
	if (sa->sa_family == AF_INET6)
	{
		struct sockaddr_in6 *in6 = (struct sockaddr_in6 *)sa;

		if (len < sizeof(struct sockaddr_in6))
			return (-1);
		in6->sin6_port = htons(port);
		return (0);
	}
	return (-1);
}

static void	shuffle_ports(int *ports, size_t count)
{
	for (size_t i = count; i > 1; --i)
	{
		size_t	j = (size_t)(rand() % i);
		int		tmp;

		tmp = ports[i - 1];
		ports[i - 1] = ports[j];
		ports[j] = tmp;
	}
}

static int	open_connection(const struct addrinfo *res, int port,
		const t_options *opts, t_result *out, struct timeval *begin_out)
{
	const struct addrinfo	*cur = res;

	while (cur)
	{
		struct sockaddr_storage	addr;
		int						fd;

		memcpy(&addr, cur->ai_addr, cur->ai_addrlen);
		if (set_port((struct sockaddr *)&addr, cur->ai_addrlen, port) != 0)
		{
			cur = cur->ai_next;
			continue ;
		}
		fd = socket(cur->ai_family, cur->ai_socktype, cur->ai_protocol);
		if (fd < 0 || make_nonblocking(fd) != 0 || fd >= FD_SETSIZE)
		{
			if (fd >= 0)
				close(fd);
			cur = cur->ai_next;
			continue ;
		}
		if (connect(fd, (struct sockaddr *)&addr, cur->ai_addrlen) != 0
			&& errno != EINPROGRESS)
		{
			close(fd);
			cur = cur->ai_next;
			continue ;
		}
		gettimeofday(begin_out, NULL);
		out->port = port;
		out->status = FT_NMAP_STATUS_UNKNOWN;
		out->duration_ms = 0;
		out->service[0] = '\0';
		(void)opts;
		return (fd);
	}
	out->port = port;
	out->status = FT_NMAP_STATUS_CLOSED;
	out->duration_ms = 0;
	out->service[0] = '\0';
	return (-1);
}

static int	compare_results_by_port(const void *a, const void *b)
{
	const t_result	*ra = (const t_result *)a;
	const t_result	*rb = (const t_result *)b;

	if (ra->port == rb->port)
		return (0);
	return (ra->port < rb->port ? -1 : 1);
}

static int	compare_long(const void *a, const void *b)
{
	long	la = *(const long *)a;
	long	lb = *(const long *)b;

	if (la == lb)
		return (0);
	return (la < lb ? -1 : 1);
}

static long	percentile_ms(long *values, size_t count, double pct)
{
	size_t	idx;

	if (count == 0)
		return (0);
	qsort(values, count, sizeof(long), compare_long);
	if (pct <= 0.0)
		return (values[0]);
	if (pct >= 100.0)
		return (values[count - 1]);
	idx = (size_t)((pct / 100.0) * (double)(count - 1));
	if (idx >= count)
		idx = count - 1;
	return (values[idx]);
}

static int	should_export(t_export_filter filter, t_port_status status)
{
	if (filter == FT_NMAP_EXPORT_OPEN_ONLY)
		return (status == FT_NMAP_STATUS_OPEN);
	if (filter == FT_NMAP_EXPORT_KNOWN)
		return (status != FT_NMAP_STATUS_UNKNOWN);
	return (1);
}

static long	elapsed_ms_since(const struct timeval *from,
		const struct timeval *to)
{
	return ((to->tv_sec - from->tv_sec) * 1000L
		+ (to->tv_usec - from->tv_usec) / 1000L);
}

int	scan_ports(const t_options *opts, t_summary *out_summary)
{
	t_result			*results;
	int					*ports;
	size_t				open_count;
	size_t				timeout_count;
	size_t				closed_count;
	size_t				retry_count;
	size_t				scanned_count;
	double				open_rate;
	double				closed_rate;
	double				timeout_rate;
	double				avg_retries_per_port;
	long				first_open_ms;
	struct timeval		start_time;
	struct timeval		end_time;
	long				start_epoch_ms;
	long				duration_min_ms;
	long				duration_max_ms;
	long				duration_sum_ms;
	int					end_time_set;
	long				duration_p50_ms;
	long				duration_p90_ms;
	long				duration_p99_ms;
	struct addrinfo		hints;
	struct addrinfo		*res;
	int					rc;
	size_t				capacity;
	int					max_retry;
	int					max_batch;
	int					*job_port;
	size_t				*job_res_idx;
	int					*job_retry;
	int					*job_attempts;
	long				end_epoch_ms;
	int					deadline_hit;
	size_t				pending_count;
	size_t				export_count;
	double				rate;
	long				elapsed_ms;
	unsigned int		random_seed;
	int					randomized;
	int					fastest_port;
	long				fastest_duration_ms;
	int					slowest_port;
	long				slowest_duration_ms;
	int					progress_enabled;
	long				last_progress_ms;
	int					timeout_stop_hit;
	long				min_wait_ms;
	char				resolved_ip[NI_MAXHOST];
	const char			*resolved_family;
	char				resolved_list[FT_NMAP_MAX_RESOLVED][NI_MAXHOST];
	char				resolved_family_list[FT_NMAP_MAX_RESOLVED][16];
	size_t				resolved_count;

	if (!opts)
		return (-1);
	results = NULL;
	ports = NULL;
	job_port = NULL;
	job_res_idx = NULL;
	job_retry = NULL;
	job_attempts = NULL;
	resolved_ip[0] = '\0';
	resolved_family = "unknown";
	memset(resolved_list, 0, sizeof(resolved_list));
	memset(resolved_family_list, 0, sizeof(resolved_family_list));
	resolved_count = 0;
	memset(&hints, 0, sizeof(hints));
	hints.ai_family = opts->ai_family;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_protocol = IPPROTO_TCP;
	const char *resolve_name = opts->ip_override_set ? opts->ip_override
		: opts->target;
	rc = getaddrinfo(resolve_name, NULL, &hints, &res);
	if (rc != 0)
	{
		fprintf(stderr, "resolve %s failed: %s\n", resolve_name,
			gai_strerror(rc));
		return (-1);
	}
	for (struct addrinfo *ai = res; ai && resolved_count < FT_NMAP_MAX_RESOLVED;
		ai = ai->ai_next)
	{
		char	addrbuf[NI_MAXHOST];

		if (getnameinfo(ai->ai_addr, ai->ai_addrlen, addrbuf, sizeof(addrbuf),
				NULL, 0, NI_NUMERICHOST) != 0)
			continue ;
		strncpy(resolved_list[resolved_count], addrbuf,
			sizeof(resolved_list[resolved_count]) - 1);
		resolved_list[resolved_count][sizeof(resolved_list[resolved_count]) - 1] = '\0';
		if (ai->ai_family == AF_INET)
			strncpy(resolved_family_list[resolved_count], "ipv4",
				sizeof(resolved_family_list[resolved_count]) - 1);
		else if (ai->ai_family == AF_INET6)
			strncpy(resolved_family_list[resolved_count], "ipv6",
				sizeof(resolved_family_list[resolved_count]) - 1);
		else
			strncpy(resolved_family_list[resolved_count], "unknown",
				sizeof(resolved_family_list[resolved_count]) - 1);
		resolved_family_list[resolved_count][sizeof(resolved_family_list[resolved_count]) - 1] = '\0';
		resolved_count++;
	}
	if (resolved_count > 0)
	{
		strncpy(resolved_ip, resolved_list[0], sizeof(resolved_ip) - 1);
		resolved_ip[sizeof(resolved_ip) - 1] = '\0';
		resolved_family = resolved_family_list[0];
	}
	if (resolved_ip[0] == '\0' && opts->target)
	{
		strncpy(resolved_ip, opts->target, sizeof(resolved_ip) - 1);
		resolved_ip[sizeof(resolved_ip) - 1] = '\0';
	}
	results = calloc(opts->ports.count, sizeof(t_result));
	if (!results)
	{
		freeaddrinfo(res);
		return (-1);
	}
	if (opts->dry_run)
	{
		gettimeofday(&start_time, NULL);
		end_time = start_time;
		start_epoch_ms = start_time.tv_sec * 1000L + start_time.tv_usec / 1000L;
		end_epoch_ms = start_epoch_ms;
		max_batch = opts->max_inflight;
		open_count = 0;
		closed_count = 0;
		timeout_count = 0;
		retry_count = 0;
		scanned_count = 0;
		pending_count = opts->ports.count;
		export_count = opts->ports.count;
		open_rate = 0.0;
		closed_rate = 0.0;
		timeout_rate = 0.0;
		avg_retries_per_port = 0.0;
		first_open_ms = -1;
		duration_min_ms = 0;
		duration_max_ms = 0;
		duration_sum_ms = 0;
		duration_p50_ms = 0;
		duration_p90_ms = 0;
		duration_p99_ms = 0;
		fastest_port = -1;
		fastest_duration_ms = 0;
		slowest_port = -1;
		slowest_duration_ms = 0;
		deadline_hit = 0;
		rate = 0.0;
		elapsed_ms = 1;
		end_time_set = 1;
		randomized = 0;
		random_seed = 0;
		progress_enabled = 0;
		timeout_stop_hit = 0;
		for (size_t i = 0; i < opts->ports.count; ++i)
		{
			results[i].port = opts->ports.values[i];
			results[i].status = FT_NMAP_STATUS_UNKNOWN;
			results[i].duration_ms = 0;
			results[i].retries_used = 0;
			results[i].service[0] = '\0';
		}
		goto build_summary;
	}
	max_retry = opts->retries;
	if (max_retry < 0)
		max_retry = 0;
	if (max_retry > FT_NMAP_MAX_RETRIES)
		max_retry = FT_NMAP_MAX_RETRIES;
	if (!opts->quiet)
		fprintf(stderr, "[debug] scanning %zu ports\n", opts->ports.count);
	ports = malloc(sizeof(int) * opts->ports.count);
	if (!ports)
	{
		freeaddrinfo(res);
		free(results);
		return (-1);
	}
	memcpy(ports, opts->ports.values, sizeof(int) * opts->ports.count);
	random_seed = 0;
	randomized = (opts->randomize && opts->ports.count > 1);
	if (randomized)
	{
		if (opts->random_seed_set)
			random_seed = opts->random_seed;
		else
		{
			struct timeval	tv;

			gettimeofday(&tv, NULL);
			random_seed = (unsigned int)(tv.tv_sec ^ tv.tv_usec ^ getpid());
		}
		srand(random_seed);
		shuffle_ports(ports, opts->ports.count);
	}
	capacity = opts->ports.count * (size_t)(max_retry + 1);
	job_port = malloc(sizeof(int) * capacity);
	job_res_idx = malloc(sizeof(size_t) * capacity);
	job_retry = malloc(sizeof(int) * capacity);
	job_attempts = malloc(sizeof(int) * capacity);

	if (!job_port || !job_res_idx || !job_retry || !job_attempts)
	{
		freeaddrinfo(res);
		free(results);
		free(ports);
		free(job_port);
		free(job_res_idx);
		free(job_retry);
		free(job_attempts);
		return (-1);
	}
	for (size_t i = 0; i < opts->ports.count; ++i)
	{
		job_port[i] = ports[i];
		job_res_idx[i] = i;
		job_retry[i] = max_retry;
		job_attempts[i] = 0;
		results[i].port = ports[i];
		results[i].retries_used = 0;
	}
	size_t jobs_created = opts->ports.count;
	if (randomized)
	{
		for (size_t i = opts->ports.count; i > 1; --i)
		{
			size_t	j = (size_t)(rand() % i);
			int		tmp_port = job_port[i - 1];
			size_t	tmp_idx = job_res_idx[i - 1];
			int		tmp_r = job_retry[i - 1];

			job_port[i - 1] = job_port[j];
			job_res_idx[i - 1] = job_res_idx[j];
			job_retry[i - 1] = job_retry[j];
			job_port[j] = tmp_port;
			job_res_idx[j] = tmp_idx;
			job_retry[j] = tmp_r;
		}
	}
	gettimeofday(&start_time, NULL);
	start_epoch_ms = start_time.tv_sec * 1000L + start_time.tv_usec / 1000L;
	open_count = 0;
	timeout_count = 0;
	closed_count = 0;
	retry_count = 0;
	scanned_count = 0;
	open_rate = 0.0;
	closed_rate = 0.0;
	timeout_rate = 0.0;
	avg_retries_per_port = 0.0;
	first_open_ms = -1;
	deadline_hit = 0;
	duration_min_ms = LONG_MAX;
	duration_max_ms = 0;
	duration_sum_ms = 0;
	duration_p50_ms = 0;
	duration_p90_ms = 0;
	duration_p99_ms = 0;
	end_time_set = 0;
	fastest_port = -1;
	fastest_duration_ms = LONG_MAX;
	slowest_port = -1;
	slowest_duration_ms = 0;
	progress_enabled = (opts->progress_interval_ms > 0);
	last_progress_ms = -1;
	timeout_stop_hit = 0;
	size_t	queue_head = 0;
	int		active = 0;
	max_batch = opts->max_inflight;
	struct pollfd	pfds[FT_NMAP_MAX_INFLIGHT];
	struct timeval	begin_times[FT_NMAP_MAX_INFLIGHT];
	size_t			idx_map[FT_NMAP_MAX_INFLIGHT];
	int				retry_left[FT_NMAP_MAX_INFLIGHT];
	int				attempts_map[FT_NMAP_MAX_INFLIGHT];
	int				stop_requested = 0;
	long			attempt_timeout_ms[FT_NMAP_MAX_INFLIGHT];

	if (max_batch < 1)
		max_batch = 1;
	if (max_batch > FT_NMAP_MAX_INFLIGHT)
		max_batch = FT_NMAP_MAX_INFLIGHT;
	if (max_batch > (int)opts->ports.count)
		max_batch = (int)opts->ports.count;
	if (progress_enabled)
	{
		fprintf(stderr, "[progress] scanned=0 open=0 closed=0 timeouts=0 active=0 pending=%zu\n",
			opts->ports.count);
		last_progress_ms = 0;
	}
	while (queue_head < jobs_created || active > 0)
	{
		while (!stop_requested && active < max_batch && queue_head < jobs_created)
		{
			int	fd = open_connection(res, job_port[queue_head], opts,
					&results[job_res_idx[queue_head]], &begin_times[active]);

			if (fd >= 0)
			{
				pfds[active].fd = fd;
				pfds[active].events = POLLOUT;
				pfds[active].revents = 0;
				idx_map[active] = job_res_idx[queue_head];
				retry_left[active] = job_retry[queue_head];
				attempts_map[active] = job_attempts[queue_head];
				long	backoff_extra = (long)opts->timeout_ms
					* (long)opts->retry_backoff_pct / 100L
					* (long)attempts_map[active];

				if (backoff_extra < 0)
					backoff_extra = 0;
				attempt_timeout_ms[active] = opts->timeout_ms + backoff_extra;
				if (attempt_timeout_ms[active] < 1)
					attempt_timeout_ms[active] = opts->timeout_ms;
				active++;
			}
			else
			{
				closed_count++;
				scanned_count++;
				t_result *r = &results[job_res_idx[queue_head]];

				r->status = FT_NMAP_STATUS_CLOSED;
				r->duration_ms = 0;
				r->retries_used = job_attempts[queue_head];
				r->service[0] = '\0';
				if (duration_min_ms == LONG_MAX)
					duration_min_ms = 0;
			}
			queue_head++;
		}
		struct timeval	deadline_now;
		long			elapsed_total_ms;

		gettimeofday(&deadline_now, NULL);
		elapsed_total_ms = (deadline_now.tv_sec - start_time.tv_sec) * 1000L
			+ (deadline_now.tv_usec - start_time.tv_usec) / 1000L;
		if (!deadline_hit && opts->deadline_ms > 0
			&& elapsed_total_ms >= opts->deadline_ms)
		{
			deadline_hit = 1;
			end_time = deadline_now;
			end_time_set = 1;
			for (int i = active - 1; i >= 0; --i)
			{
				long elapsed_ms = (deadline_now.tv_sec - begin_times[i].tv_sec)
					* 1000L + (deadline_now.tv_usec - begin_times[i].tv_usec)
					/ 1000L;

				timeout_count++;
				scanned_count++;
				results[idx_map[i]].status = FT_NMAP_STATUS_TIMEOUT;
				results[idx_map[i]].duration_ms = elapsed_ms;
				results[idx_map[i]].retries_used = attempts_map[i];
				if (elapsed_ms < duration_min_ms)
					duration_min_ms = elapsed_ms;
				if (elapsed_ms > duration_max_ms)
					duration_max_ms = elapsed_ms;
				if (elapsed_ms < fastest_duration_ms)
				{
					fastest_duration_ms = elapsed_ms;
					fastest_port = results[idx_map[i]].port;
				}
				if (elapsed_ms >= slowest_duration_ms)
				{
					slowest_duration_ms = elapsed_ms;
					slowest_port = results[idx_map[i]].port;
				}
				duration_sum_ms += elapsed_ms;
				if (!timeout_stop_hit && opts->stop_on_timeout_count > 0
					&& (int)timeout_count >= opts->stop_on_timeout_count)
				{
					stop_requested = 1;
					timeout_stop_hit = 1;
				}
				close(pfds[i].fd);
			}
			active = 0;
			break ;
		}
		if (active == 0)
		{
			if (stop_requested)
				break ;
			continue ;
		}
		min_wait_ms = -1;
		{
			struct timeval	now;

			gettimeofday(&now, NULL);
			for (int i = 0; i < active; ++i)
			{
				long elapsed_ms = elapsed_ms_since(&begin_times[i], &now);
				long remaining = attempt_timeout_ms[i] - elapsed_ms;

				if (remaining < 0)
					remaining = 0;
				if (min_wait_ms < 0 || remaining < min_wait_ms)
					min_wait_ms = remaining;
			}
			if (min_wait_ms < 0)
				min_wait_ms = opts->timeout_ms;
			if (min_wait_ms < 1)
				min_wait_ms = 1;
		}
		int ready = poll(pfds, active, (int)min_wait_ms);
		struct timeval	now;

		gettimeofday(&now, NULL);
		if (progress_enabled)
		{
			long elapsed_ms = (now.tv_sec - start_time.tv_sec) * 1000L
				+ (now.tv_usec - start_time.tv_usec) / 1000L;

			if (last_progress_ms < 0
				|| elapsed_ms - last_progress_ms >= opts->progress_interval_ms)
			{
				size_t pending_live = (opts->ports.count > scanned_count
						? opts->ports.count - scanned_count : 0);

				fprintf(stderr,
					"[progress] scanned=%zu open=%zu closed=%zu timeouts=%zu active=%d pending=%zu\n",
					scanned_count, open_count, closed_count, timeout_count,
					active, pending_live);
				last_progress_ms = elapsed_ms;
			}
		}
		if (ready == 0)
		{
			for (int i = active - 1; i >= 0; --i)
			{
				long elapsed_ms = elapsed_ms_since(&begin_times[i], &now);

				if (elapsed_ms < attempt_timeout_ms[i])
					continue ;
				if (retry_left[i] > 0 && jobs_created < capacity)
				{
					job_port[jobs_created] = results[idx_map[i]].port;
					job_res_idx[jobs_created] = idx_map[i];
					job_retry[jobs_created] = retry_left[i] - 1;
					job_attempts[jobs_created] = attempts_map[i] + 1;
					jobs_created++;
					retry_count++;
				}
				else
				{
					timeout_count++;
					scanned_count++;
					results[idx_map[i]].status = FT_NMAP_STATUS_TIMEOUT;
					results[idx_map[i]].duration_ms = elapsed_ms;
					results[idx_map[i]].retries_used = attempts_map[i];
					if (elapsed_ms < duration_min_ms)
						duration_min_ms = elapsed_ms;
					if (elapsed_ms > duration_max_ms)
						duration_max_ms = elapsed_ms;
					if (elapsed_ms < fastest_duration_ms)
					{
						fastest_duration_ms = elapsed_ms;
						fastest_port = results[idx_map[i]].port;
					}
					if (elapsed_ms >= slowest_duration_ms)
					{
						slowest_duration_ms = elapsed_ms;
						slowest_port = results[idx_map[i]].port;
					}
					duration_sum_ms += elapsed_ms;
					report_port(opts, &results[idx_map[i]]);
					if (!timeout_stop_hit && opts->stop_on_timeout_count > 0
						&& (int)timeout_count >= opts->stop_on_timeout_count)
					{
						stop_requested = 1;
						timeout_stop_hit = 1;
					}
				}
				close(pfds[i].fd);
				pfds[i] = pfds[active - 1];
				begin_times[i] = begin_times[active - 1];
				idx_map[i] = idx_map[active - 1];
				retry_left[i] = retry_left[active - 1];
				attempts_map[i] = attempts_map[active - 1];
				attempt_timeout_ms[i] = attempt_timeout_ms[active - 1];
				active--;
			}
			if (opts->inter_batch_delay_ms > 0)
				usleep((useconds_t)(opts->inter_batch_delay_ms * 1000));
			continue ;
		}
		for (int i = active - 1; i >= 0; --i)
		{
			if (!(pfds[i].revents & (POLLOUT | POLLERR | POLLHUP)))
				continue ;
			long elapsed_ms = (now.tv_sec - begin_times[i].tv_sec) * 1000L
				+ (now.tv_usec - begin_times[i].tv_usec) / 1000L;
			int err = 0;
			socklen_t len = sizeof(err);

			if (getsockopt(pfds[i].fd, SOL_SOCKET, SO_ERROR, &err, &len) == 0
				&& err == 0)
			{
				int port = ports[idx_map[i]];
				t_result *r = &results[idx_map[i]];

				open_count++;
				scanned_count++;
				results[idx_map[i]].status = FT_NMAP_STATUS_OPEN;
				results[idx_map[i]].duration_ms = elapsed_ms;
				results[idx_map[i]].retries_used = attempts_map[i];
				if (elapsed_ms < duration_min_ms)
					duration_min_ms = elapsed_ms;
				if (elapsed_ms > duration_max_ms)
					duration_max_ms = elapsed_ms;
				if (elapsed_ms < fastest_duration_ms)
				{
					fastest_duration_ms = elapsed_ms;
					fastest_port = port;
				}
				if (elapsed_ms >= slowest_duration_ms)
				{
					slowest_duration_ms = elapsed_ms;
					slowest_port = port;
				}
				duration_sum_ms += elapsed_ms;
				if (first_open_ms < 0)
				{
					struct timeval	now;

					gettimeofday(&now, NULL);
					first_open_ms = (now.tv_sec - start_time.tv_sec) * 1000L
						+ (now.tv_usec - start_time.tv_usec) / 1000L;
					if (first_open_ms < 0)
						first_open_ms = elapsed_ms;
				}
				if (opts->show_service)
				{
					struct servent *se = getservbyport(htons(port), "tcp");

					if (se)
					{
						strncpy(results[idx_map[i]].service, se->s_name,
							sizeof(results[idx_map[i]].service) - 1);
						results[idx_map[i]].service[sizeof(results[idx_map[i]].service) - 1] = '\0';
					}
				}
				report_port(opts, r);
				if (opts->stop_on_open_count > 0
					&& (int)open_count >= opts->stop_on_open_count)
					stop_requested = 1;
			}
			else
			{
				if (retry_left[i] > 0 && jobs_created < capacity)
				{
					job_port[jobs_created] = results[idx_map[i]].port;
					job_res_idx[jobs_created] = idx_map[i];
					job_retry[jobs_created] = retry_left[i] - 1;
					job_attempts[jobs_created] = attempts_map[i] + 1;
					jobs_created++;
					retry_count++;
				}
				else
				{
					closed_count++;
					scanned_count++;
					results[idx_map[i]].status = FT_NMAP_STATUS_CLOSED;
					results[idx_map[i]].duration_ms = elapsed_ms;
					results[idx_map[i]].retries_used = attempts_map[i];
					if (elapsed_ms < duration_min_ms)
						duration_min_ms = elapsed_ms;
					if (elapsed_ms > duration_max_ms)
						duration_max_ms = elapsed_ms;
					if (elapsed_ms < fastest_duration_ms)
					{
						fastest_duration_ms = elapsed_ms;
						fastest_port = results[idx_map[i]].port;
					}
					if (elapsed_ms >= slowest_duration_ms)
					{
						slowest_duration_ms = elapsed_ms;
						slowest_port = results[idx_map[i]].port;
					}
					duration_sum_ms += elapsed_ms;
					report_port(opts, &results[idx_map[i]]);
				}
			}
			close(pfds[i].fd);
			pfds[i] = pfds[active - 1];
			begin_times[i] = begin_times[active - 1];
			idx_map[i] = idx_map[active - 1];
			retry_left[i] = retry_left[active - 1];
			attempts_map[i] = attempts_map[active - 1];
			attempt_timeout_ms[i] = attempt_timeout_ms[active - 1];
			active--;
		}
		for (int i = active - 1; i >= 0; --i)
		{
			long elapsed_ms = elapsed_ms_since(&begin_times[i], &now);

			if (elapsed_ms < attempt_timeout_ms[i])
				continue ;
			if (retry_left[i] > 0 && jobs_created < capacity)
			{
				job_port[jobs_created] = results[idx_map[i]].port;
				job_res_idx[jobs_created] = idx_map[i];
				job_retry[jobs_created] = retry_left[i] - 1;
				job_attempts[jobs_created] = attempts_map[i] + 1;
				jobs_created++;
				retry_count++;
			}
			else
			{
				timeout_count++;
				scanned_count++;
				results[idx_map[i]].status = FT_NMAP_STATUS_TIMEOUT;
				results[idx_map[i]].duration_ms = elapsed_ms;
				results[idx_map[i]].retries_used = attempts_map[i];
				if (elapsed_ms < duration_min_ms)
					duration_min_ms = elapsed_ms;
				if (elapsed_ms > duration_max_ms)
					duration_max_ms = elapsed_ms;
				if (elapsed_ms < fastest_duration_ms)
				{
					fastest_duration_ms = elapsed_ms;
					fastest_port = results[idx_map[i]].port;
				}
				if (elapsed_ms >= slowest_duration_ms)
				{
					slowest_duration_ms = elapsed_ms;
					slowest_port = results[idx_map[i]].port;
				}
				duration_sum_ms += elapsed_ms;
				report_port(opts, &results[idx_map[i]]);
				if (!timeout_stop_hit && opts->stop_on_timeout_count > 0
					&& (int)timeout_count >= opts->stop_on_timeout_count)
				{
					stop_requested = 1;
					timeout_stop_hit = 1;
				}
			}
			close(pfds[i].fd);
			pfds[i] = pfds[active - 1];
			begin_times[i] = begin_times[active - 1];
			idx_map[i] = idx_map[active - 1];
			retry_left[i] = retry_left[active - 1];
			attempts_map[i] = attempts_map[active - 1];
			attempt_timeout_ms[i] = attempt_timeout_ms[active - 1];
			active--;
		}
		if (stop_requested)
		{
			for (int i = 0; i < active; ++i)
				close(pfds[i].fd);
			active = 0;
			queue_head = jobs_created;
		}
		if (opts->inter_batch_delay_ms > 0)
			usleep((useconds_t)(opts->inter_batch_delay_ms * 1000));
	}
	if (opts->inter_batch_delay_ms > 0 && scanned_count > 0)
		usleep((useconds_t)(opts->inter_batch_delay_ms * 1000));
	if (!end_time_set)
		gettimeofday(&end_time, NULL);
	elapsed_ms = (end_time.tv_sec - start_time.tv_sec) * 1000L
		+ (end_time.tv_usec - start_time.tv_usec) / 1000L;
	if (elapsed_ms <= 0)
		elapsed_ms = 1;
	if (opts->deadline_ms > 0 && elapsed_ms >= opts->deadline_ms)
		deadline_hit = 1;
	end_epoch_ms = end_time.tv_sec * 1000L + end_time.tv_usec / 1000L;
	rate = (double)scanned_count * 1000.0 / (double)elapsed_ms;
	pending_count = (opts->ports.count > scanned_count
			? opts->ports.count - scanned_count : 0);
	export_count = opts->ports.count;
	if (scanned_count > 0)
	{
		open_rate = ((double)open_count / (double)scanned_count) * 100.0;
		closed_rate = ((double)closed_count / (double)scanned_count) * 100.0;
		timeout_rate = ((double)timeout_count / (double)scanned_count) * 100.0;
		avg_retries_per_port = (double)retry_count / (double)scanned_count;
	}
build_summary:
	t_summary	summary;

	summary.scanned = scanned_count;
	summary.requested = opts->ports.count;
	summary.pending = pending_count;
	summary.excluded_count = opts->excluded_count;
	summary.open_count = open_count;
	summary.closed_count = closed_count;
	summary.timeout_count = timeout_count;
	summary.retry_count = retry_count;
	summary.open_rate = open_rate;
	summary.closed_rate = closed_rate;
	summary.timeout_rate = timeout_rate;
	summary.avg_retries_per_port = avg_retries_per_port;
	summary.first_open_ms = first_open_ms;
	summary.elapsed_ms = elapsed_ms;
	summary.randomized = randomized;
	summary.random_seed = random_seed;
	summary.dry_run = opts->dry_run;
	summary.start_ms = start_epoch_ms;
	summary.end_ms = end_epoch_ms;
	summary.duration_min_ms = (duration_min_ms == LONG_MAX ? 0
			: duration_min_ms);
	summary.duration_max_ms = duration_max_ms;
	summary.duration_mean_ms = (scanned_count > 0
			? duration_sum_ms / (long)scanned_count : 0);
	summary.fastest_port = fastest_port;
	summary.fastest_duration_ms = (fastest_duration_ms == LONG_MAX
			? 0 : fastest_duration_ms);
	summary.slowest_port = slowest_port;
	summary.slowest_duration_ms = slowest_duration_ms;
	summary.timeout_stop_hit = timeout_stop_hit;
	summary.timeout_stop_threshold = opts->stop_on_timeout_count;
	summary.deadline_hit = deadline_hit;
	summary.deadline_ms = opts->deadline_ms;
	summary.retry_backoff_pct = opts->retry_backoff_pct;
	summary.resolved_count = resolved_count;
	strncpy(summary.resolved_ip, resolved_ip, sizeof(summary.resolved_ip) - 1);
	summary.resolved_ip[sizeof(summary.resolved_ip) - 1] = '\0';
	strncpy(summary.resolved_family, resolved_family,
		sizeof(summary.resolved_family) - 1);
	summary.resolved_family[sizeof(summary.resolved_family) - 1] = '\0';
	for (size_t i = 0; i < resolved_count && i < FT_NMAP_MAX_RESOLVED; ++i)
	{
		strncpy(summary.resolved_list[i], resolved_list[i],
			sizeof(summary.resolved_list[i]) - 1);
		summary.resolved_list[i][sizeof(summary.resolved_list[i]) - 1] = '\0';
		strncpy(summary.resolved_family_list[i], resolved_family_list[i],
			sizeof(summary.resolved_family_list[i]) - 1);
		summary.resolved_family_list[i][sizeof(summary.resolved_family_list[i]) - 1] = '\0';
	}
	if (scanned_count > 0)
	{
		long	*durations = malloc(sizeof(long) * scanned_count);
		size_t	d_count = 0;

		if (durations)
		{
			for (size_t i = 0; i < opts->ports.count && d_count < scanned_count; ++i)
			{
				if (results[i].status == FT_NMAP_STATUS_UNKNOWN)
					continue ;
				durations[d_count++] = results[i].duration_ms;
			}
			if (d_count > 0)
			{
				duration_p50_ms = percentile_ms(durations, d_count, 50.0);
				duration_p90_ms = percentile_ms(durations, d_count, 90.0);
				duration_p99_ms = percentile_ms(durations, d_count, 99.0);
			}
			free(durations);
		}
	}
	summary.duration_p50_ms = duration_p50_ms;
	summary.duration_p90_ms = duration_p90_ms;
	summary.duration_p99_ms = duration_p99_ms;
	size_t	filtered_count = 0;

	for (size_t i = 0; i < export_count; ++i)
	{
		if (!should_export(opts->export_filter, results[i].status))
			continue ;
		results[filtered_count++] = results[i];
	}
	export_count = filtered_count;
	if (export_count > 1)
		qsort(results, export_count, sizeof(t_result), compare_results_by_port);
	FILE	*summary_stream = opts->summary_to_stderr ? stderr : stdout;

	fprintf(summary_stream, "Scan finished: %zu/%zu ports scanned",
		summary.scanned, summary.requested);
	if (summary.pending > 0)
		fprintf(summary_stream, " (%zu pending)", summary.pending);
	if (summary.excluded_count > 0)
		fprintf(summary_stream, " (%zu excluded)", summary.excluded_count);
	fprintf(summary_stream, ", %zu open, %zu closed, %zu timeouts (rates %.2f%%/%.2f%%/%.2f%%, retries %zu (avg %.2f), timeout %ld ms, inflight %d, %.2f kports/s, duration min/avg/p50/p90/p99/max %ld/%ld/%ld/%ld/%ld/%ld ms)",
		summary.open_count, summary.closed_count, summary.timeout_count,
		summary.open_rate, summary.closed_rate, summary.timeout_rate,
		summary.retry_count, summary.avg_retries_per_port, opts->timeout_ms,
		max_batch, rate / 1000.0,
		summary.duration_min_ms, summary.duration_mean_ms,
		summary.duration_p50_ms, summary.duration_p90_ms,
		summary.duration_p99_ms, summary.duration_max_ms);
	if (summary.open_count > 0)
		fprintf(summary_stream, " [first open at %ld ms]",
			summary.first_open_ms);
	if (opts->deadline_ms > 0)
	{
		if (summary.deadline_hit)
			fprintf(summary_stream, " [deadline %ld ms hit]",
				summary.deadline_ms);
		else
			fprintf(summary_stream, " [deadline %ld ms]",
				summary.deadline_ms);
	}
	if (summary.randomized)
		fprintf(summary_stream, " [seed %u]", summary.random_seed);
	if (opts->retries > 0 && opts->retry_backoff_pct > 0)
		fprintf(summary_stream, " [backoff +%d%%/retry]",
			opts->retry_backoff_pct);
	if (summary.dry_run)
		fprintf(summary_stream, " [dry-run]");
	if (summary.resolved_ip[0] != '\0')
	{
		fprintf(summary_stream, " [resolved %s (%s)",
			summary.resolved_ip, summary.resolved_family);
		if (summary.resolved_count > 1)
			fprintf(summary_stream, " +%zu alt", summary.resolved_count - 1);
		if (opts->ip_override_set)
			fprintf(summary_stream, ", override");
		fprintf(summary_stream, "]");
	}
	if (summary.fastest_port != -1 && summary.slowest_port != -1)
		fprintf(summary_stream, " [fastest %d (%ld ms), slowest %d (%ld ms)]",
			summary.fastest_port, summary.fastest_duration_ms,
			summary.slowest_port, summary.slowest_duration_ms);
	if (summary.timeout_stop_hit)
		fprintf(summary_stream, " [timeout-stop %d]",
			summary.timeout_stop_threshold);
	fprintf(summary_stream, "\n");
	if (opts->json_path)
	{
		if (write_json_summary(opts, &summary, results, export_count) != 0)
			fprintf(stderr, "Failed to write JSON to %s\n", opts->json_path);
	}
	if (opts->json_summary_path)
	{
		if (write_json_stats(opts, &summary) != 0)
			fprintf(stderr, "Failed to write JSON summary to %s\n",
				opts->json_summary_path);
	}
	if (opts->open_list_path)
	{
		if (write_open_list(opts, results, export_count) != 0)
			fprintf(stderr, "Failed to write open list to %s\n",
				opts->open_list_path);
	}
	if (opts->csv_path)
	{
		if (write_csv_summary(opts, &summary, results, export_count) != 0)
			fprintf(stderr, "Failed to write CSV to %s\n", opts->csv_path);
	}
	if (opts->yaml_path)
	{
		if (write_yaml_summary(opts, &summary, results, export_count) != 0)
			fprintf(stderr, "Failed to write YAML to %s\n", opts->yaml_path);
	}
	if (opts->xml_path)
	{
		if (write_xml_summary(opts, &summary, results, export_count) != 0)
			fprintf(stderr, "Failed to write XML to %s\n", opts->xml_path);
	}
	if (opts->html_path)
	{
		if (write_html_summary(opts, &summary, results, export_count) != 0)
			fprintf(stderr, "Failed to write HTML to %s\n", opts->html_path);
	}
	if (opts->md_path)
	{
		if (write_md_summary(opts, &summary, results, export_count) != 0)
			fprintf(stderr, "Failed to write Markdown to %s\n", opts->md_path);
	}
	if (opts->ndjson_path)
	{
		if (write_ndjson_results(opts, results, export_count) != 0)
			fprintf(stderr, "Failed to write NDJSON to %s\n", opts->ndjson_path);
	}
	if (opts->list_table)
		print_table_summary(opts, results, export_count);
	if (out_summary)
	{
		*out_summary = summary;
	}
	freeaddrinfo(res);
	free(ports);
	free(job_port);
	free(job_res_idx);
	free(job_retry);
	free(job_attempts);
	free(results);
	return (0);
}
