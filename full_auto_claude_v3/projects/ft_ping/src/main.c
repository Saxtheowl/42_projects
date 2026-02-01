/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ping.h"

t_ping	g_ping;

static volatile int	g_running = 1;
static volatile int	g_send_ping = 1;

static void	sig_handler(int sig)
{
	if (sig == SIGINT)
		g_running = 0;
	else if (sig == SIGALRM)
		g_send_ping = 1;
}

static int	create_socket(t_ping *ping)
{
	int				ttl;
	struct timeval	tv;

	ping->sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
	if (ping->sockfd < 0)
	{
		if (errno == EPERM || errno == EACCES)
			fprintf(stderr, "ft_ping: Lacking privilege for raw socket\n");
		else
			perror("ft_ping: socket");
		return (-1);
	}
	ttl = 64;
	if (setsockopt(ping->sockfd, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0)
	{
		perror("ft_ping: setsockopt TTL");
		return (-1);
	}
	tv.tv_sec = 1;
	tv.tv_usec = 0;
	if (setsockopt(ping->sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0)
	{
		perror("ft_ping: setsockopt timeout");
		return (-1);
	}
	return (0);
}

static int	parse_args(t_ping *ping, int argc, char **argv)
{
	int	i;

	ping->verbose = 0;
	ping->hostname = NULL;
	i = 1;
	while (i < argc)
	{
		if (ft_strcmp(argv[i], "-v") == 0)
			ping->verbose = 1;
		else if (ft_strcmp(argv[i], "-h") == 0)
		{
			print_help();
			return (1);
		}
		else if (argv[i][0] == '-')
		{
			fprintf(stderr, "ft_ping: invalid option -- '%c'\n", argv[i][1]);
			print_usage();
			return (-1);
		}
		else if (!ping->hostname)
			ping->hostname = argv[i];
		else
		{
			fprintf(stderr, "ft_ping: too many arguments\n");
			return (-1);
		}
		i++;
	}
	if (!ping->hostname)
	{
		print_usage();
		return (-1);
	}
	return (0);
}

static void	init_ping(t_ping *ping)
{
	ping->seq = 1;
	ping->sent = 0;
	ping->received = 0;
	ping->min_rtt = 0;
	ping->max_rtt = 0;
	ping->total_rtt = 0;
	ping->total_rtt_sq = 0;
	ping->pid = getpid() & 0xFFFF;
}

static void	ping_loop(t_ping *ping)
{
	printf("PING %s (%s) %d(%d) bytes of data.\n",
		ping->hostname, ping->ip_str, DATA_SIZE, PACKET_SIZE + 20);
	signal(SIGINT, sig_handler);
	signal(SIGALRM, sig_handler);
	while (g_running)
	{
		if (g_send_ping)
		{
			send_ping(ping);
			g_send_ping = 0;
			alarm(1);
		}
		receive_ping(ping);
	}
	print_stats(ping);
}

int	main(int argc, char **argv)
{
	int	ret;

	if (argc < 2)
	{
		print_usage();
		return (1);
	}
	ft_memset(&g_ping, 0, sizeof(g_ping));
	ret = parse_args(&g_ping, argc, argv);
	if (ret != 0)
		return (ret < 0 ? 1 : 0);
	if (getuid() != 0)
	{
		fprintf(stderr, "ft_ping: This program requires root privileges\n");
		return (1);
	}
	init_ping(&g_ping);
	if (resolve_hostname(&g_ping) < 0)
		return (1);
	if (create_socket(&g_ping) < 0)
		return (1);
	ping_loop(&g_ping);
	close(g_ping.sockfd);
	return (g_ping.received > 0 ? 0 : 1);
}
