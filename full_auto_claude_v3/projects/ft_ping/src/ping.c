/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ping.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ping.h"

static uint16_t	checksum(void *data, int len)
{
	uint16_t	*buf;
	uint32_t	sum;
	uint16_t	result;

	buf = (uint16_t *)data;
	sum = 0;
	while (len > 1)
	{
		sum += *buf++;
		len -= 2;
	}
	if (len == 1)
		sum += *(uint8_t *)buf;
	sum = (sum >> 16) + (sum & 0xFFFF);
	sum += (sum >> 16);
	result = ~sum;
	return (result);
}

int	resolve_hostname(t_ping *ping)
{
	struct addrinfo	hints;
	struct addrinfo	*res;
	int				ret;

	ft_memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_RAW;
	hints.ai_protocol = IPPROTO_ICMP;
	ret = getaddrinfo(ping->hostname, NULL, &hints, &res);
	if (ret != 0)
	{
		fprintf(stderr, "ft_ping: %s: Name or service not known\n",
			ping->hostname);
		return (-1);
	}
	ft_memcpy(&ping->dest_addr, res->ai_addr, sizeof(ping->dest_addr));
	inet_ntop(AF_INET, &ping->dest_addr.sin_addr, ping->ip_str,
		INET_ADDRSTRLEN);
	freeaddrinfo(res);
	return (0);
}

void	send_ping(t_ping *ping)
{
	char			packet[PACKET_SIZE];
	struct icmphdr	*icmp;
	struct timeval	*tv;
	ssize_t			bytes_sent;

	ft_memset(packet, 0, PACKET_SIZE);
	icmp = (struct icmphdr *)packet;
	icmp->type = ICMP_ECHO;
	icmp->code = 0;
	icmp->un.echo.id = htons(ping->pid);
	icmp->un.echo.sequence = htons(ping->seq);
	tv = (struct timeval *)(packet + ICMP_HDR_SIZE);
	gettimeofday(tv, NULL);
	icmp->checksum = 0;
	icmp->checksum = checksum(packet, PACKET_SIZE);
	bytes_sent = sendto(ping->sockfd, packet, PACKET_SIZE, 0,
			(struct sockaddr *)&ping->dest_addr, sizeof(ping->dest_addr));
	if (bytes_sent < 0)
	{
		if (ping->verbose)
			perror("ft_ping: sendto");
	}
	else
	{
		ping->sent++;
		ping->seq++;
	}
}

static double	calc_rtt(struct timeval *sent, struct timeval *received)
{
	double	rtt;

	rtt = (received->tv_sec - sent->tv_sec) * 1000.0;
	rtt += (received->tv_usec - sent->tv_usec) / 1000.0;
	return (rtt);
}

static void	update_stats(t_ping *ping, double rtt)
{
	if (ping->received == 1 || rtt < ping->min_rtt)
		ping->min_rtt = rtt;
	if (rtt > ping->max_rtt)
		ping->max_rtt = rtt;
	ping->total_rtt += rtt;
	ping->total_rtt_sq += rtt * rtt;
}

static void	print_reply(t_ping *ping, int bytes, struct iphdr *ip,
	struct icmphdr *icmp, double rtt)
{
	printf("%d bytes from %s: icmp_seq=%d ttl=%d time=%.3f ms\n",
		bytes - (int)(ip->ihl * 4),
		ping->ip_str,
		ntohs(icmp->un.echo.sequence),
		ip->ttl,
		rtt);
}

static void	print_error(t_ping *ping, struct iphdr *ip, struct icmphdr *icmp)
{
	if (icmp->type == ICMP_DEST_UNREACH)
		printf("From %s icmp_seq=%d Destination Unreachable\n",
			ping->ip_str, ntohs(icmp->un.echo.sequence));
	else if (icmp->type == ICMP_TIME_EXCEEDED)
		printf("From %s icmp_seq=%d Time to live exceeded\n",
			ping->ip_str, ntohs(icmp->un.echo.sequence));
	else if (ping->verbose)
		printf("From %s: icmp_type=%d icmp_code=%d\n",
			ping->ip_str, icmp->type, icmp->code);
	(void)ip;
}

void	receive_ping(t_ping *ping)
{
	char			buffer[512];
	struct iovec	iov;
	struct msghdr	msg;
	ssize_t			bytes;
	struct iphdr	*ip;
	struct icmphdr	*icmp;
	struct timeval	*sent_tv;
	struct timeval	recv_tv;
	double			rtt;

	ft_memset(&msg, 0, sizeof(msg));
	iov.iov_base = buffer;
	iov.iov_len = sizeof(buffer);
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;
	bytes = recvmsg(ping->sockfd, &msg, 0);
	if (bytes < 0)
	{
		if (errno != EINTR && ping->verbose)
			perror("ft_ping: recvmsg");
		return ;
	}
	gettimeofday(&recv_tv, NULL);
	ip = (struct iphdr *)buffer;
	icmp = (struct icmphdr *)(buffer + (ip->ihl * 4));
	if (icmp->type == ICMP_ECHOREPLY
		&& ntohs(icmp->un.echo.id) == ping->pid)
	{
		sent_tv = (struct timeval *)(buffer + (ip->ihl * 4) + ICMP_HDR_SIZE);
		rtt = calc_rtt(sent_tv, &recv_tv);
		ping->received++;
		update_stats(ping, rtt);
		print_reply(ping, bytes, ip, icmp, rtt);
	}
	else if (icmp->type != ICMP_ECHOREPLY && ping->verbose)
		print_error(ping, ip, icmp);
}

void	print_stats(t_ping *ping)
{
	double	avg;
	double	mdev;
	int		loss;

	printf("\n--- %s ping statistics ---\n", ping->hostname);
	loss = 0;
	if (ping->sent > 0)
		loss = 100 - (ping->received * 100 / ping->sent);
	printf("%d packets transmitted, %d received, %d%% packet loss\n",
		ping->sent, ping->received, loss);
	if (ping->received > 0)
	{
		avg = ping->total_rtt / ping->received;
		mdev = sqrt((ping->total_rtt_sq / ping->received) - (avg * avg));
		printf("rtt min/avg/max/mdev = %.3f/%.3f/%.3f/%.3f ms\n",
			ping->min_rtt, avg, ping->max_rtt, mdev);
	}
}
