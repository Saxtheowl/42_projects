#include "ft_ping.h"

#include <math.h>
#include <stdio.h>

void	ft_stats_init(t_stats *stats)
{
	if (!stats)
		return ;
	ft_bzero(stats, sizeof(*stats));
	stats->min_rtt = 0.0;
	stats->max_rtt = 0.0;
	stats->sum_rtt = 0.0;
	stats->sum_rtt_squared = 0.0;
}

void	ft_stats_on_send(t_stats *stats)
{
	if (!stats)
		return ;
	stats->sent += 1;
}

void	ft_stats_on_reply(t_stats *stats, double rtt_ms)
{
	if (!stats)
		return ;
	stats->received += 1;
	if (stats->received == 1 || rtt_ms < stats->min_rtt)
		stats->min_rtt = rtt_ms;
	if (stats->received == 1 || rtt_ms > stats->max_rtt)
		stats->max_rtt = rtt_ms;
	stats->sum_rtt += rtt_ms;
	stats->sum_rtt_squared += (rtt_ms * rtt_ms);
}

static void	print_summary(const t_session *session)
{
	const t_stats	*stats;
	double			loss;
	struct timeval	now;
	double			elapsed_ms;

	stats = &session->stats;
	if (stats->sent == 0)
		return ;
	loss = 0.0;
	if (stats->sent > 0)
		loss = ((double)(stats->sent - stats->received) / stats->sent) * 100.0;
	gettimeofday(&now, NULL);
	elapsed_ms = ft_time_diff_ms(&session->start_time, &now);
	printf("%u packets transmitted, %u received, %.1f%% packet loss",
		stats->sent, stats->received, loss);
	if (stats->received > 0)
	{
		double	avg;
		double	stddev;
		double	variance;

		avg = stats->sum_rtt / stats->received;
		variance = (stats->sum_rtt_squared / stats->received) - (avg * avg);
		if (variance < 0.0)
			variance = 0.0;
		stddev = sqrt(variance);
		printf(", time %.0fms\n", elapsed_ms);
		printf("rtt min/avg/max/mdev = %.3f/%.3f/%.3f/%.3f ms\n",
			stats->min_rtt, avg, stats->max_rtt, stddev);
	}
	else
		printf(", time %.0fms\n", elapsed_ms);
}

void	ft_stats_print(const t_session *session)
{
	if (!session)
		return ;
	printf("--- %s ping statistics ---\n",
		ft_strlen(session->resolved_host) > 0 ? session->resolved_host
			: session->options.target);
	print_summary(session);
}
