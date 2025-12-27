#include "ft_ping.h"

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define FT_PING_DEFAULT_TIMEOUT_MS 1000.0
#define FT_PING_DEFAULT_INTERVAL_MS (FT_PING_INTERVAL_SEC * 1000.0)

typedef struct s_reply_info
{
	struct sockaddr_in	addr;
	double				rtt_ms;
	uint8_t				ttl;
	uint8_t				type;
	uint8_t				code;
	unsigned short		seq;
	int					is_echo;
}	t_reply_info;

static volatile sig_atomic_t	g_stop = 0;

static void	handle_sigint(int sig)
{
	(void)sig;
	g_stop = 1;
}

static void	init_session(t_session *session, const t_options *opts)
{
	ft_bzero(session, sizeof(*session));
	session->options = *opts;
	session->sockfd = -1;
	session->ident = (unsigned short)getpid();
	session->sequence = 1;
	session->packet_size = sizeof(struct icmphdr)
		+ (session->options.payload_size > 0 ? session->options.payload_size : FT_PING_DEFAULT_PAYLOAD_SIZE);
	session->has_source = 0;
	ft_stats_init(&session->stats);
}

static int	resolve_target(t_session *session)
{
	struct addrinfo	hints;
	struct addrinfo	*result;
	int				ret;

	ft_bzero(&hints, sizeof(hints));
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_RAW;
	hints.ai_protocol = IPPROTO_ICMP;
	hints.ai_flags = AI_CANONNAME;
	ret = getaddrinfo(session->options.target, NULL, &hints, &result);
	if (ret != 0)
	{
		fprintf(stderr, "ft_ping: %s: %s\n",
			session->options.target, gai_strerror(ret));
		return (-1);
	}
	session->dest.sin_family = AF_INET;
	session->dest.sin_port = 0;
	if (result->ai_addrlen >= sizeof(session->dest))
		ft_memcpy(&session->dest, result->ai_addr, sizeof(session->dest));
	else
	{
		struct sockaddr_in	*addr_in;

		addr_in = (struct sockaddr_in *)result->ai_addr;
		session->dest.sin_addr = addr_in->sin_addr;
	}
	if (result->ai_canonname)
		ft_strlcpy(session->resolved_host, result->ai_canonname,
			sizeof(session->resolved_host));
	else
		session->resolved_host[0] = '\0';
	if (!inet_ntop(AF_INET, &session->dest.sin_addr,
			session->resolved_ip, sizeof(session->resolved_ip)))
	{
		fprintf(stderr, "ft_ping: inet_ntop failed\n");
		freeaddrinfo(result);
		return (-1);
	}
	freeaddrinfo(result);
	return (0);
}

static int	open_socket(t_session *session)
{
	int	sockfd;
	int	ttl;
	int	tos;
	struct sockaddr_in	local;

	sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
	if (sockfd < 0)
	{
		fprintf(stderr, "ft_ping: socket failed (errno %d)\n", errno);
		return (-1);
	}
	session->sockfd = sockfd;
	if (session->options.source_ip)
	{
		ft_bzero(&local, sizeof(local));
		local.sin_family = AF_INET;
		if (inet_pton(AF_INET, session->options.source_ip, &local.sin_addr) != 1)
		{
			fprintf(stderr, "ft_ping: invalid source address '%s'\n",
				session->options.source_ip);
			return (-1);
		}
		if (bind(sockfd, (struct sockaddr *)&local, sizeof(local)) < 0)
		{
			fprintf(stderr, "ft_ping: bind source failed (errno %d)\n", errno);
			return (-1);
		}
		session->source_addr = local.sin_addr;
		session->has_source = 1;
	}
	ttl = (session->options.ttl > 0) ? session->options.ttl : FT_PING_DEFAULT_TTL;
	if (setsockopt(sockfd, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0)
		fprintf(stderr, "ft_ping: warning: cannot set TTL (errno %d)\n", errno);
	tos = session->options.tos;
	if (tos >= 0)
	{
		if (setsockopt(sockfd, IPPROTO_IP, IP_TOS, &tos, sizeof(tos)) < 0)
			fprintf(stderr, "ft_ping: warning: cannot set TOS (errno %d)\n", errno);
	}
	return (0);
}

static void	print_banner(const t_session *session)
{
	const char	*host;

	host = session->resolved_host[0] ? session->resolved_host : session->options.target;
	printf("PING %s (%s) %d(%zu) bytes of data.\n",
		host, session->resolved_ip,
		(int)session->options.payload_size, session->packet_size);
}

static int	send_echo_request(t_session *session, unsigned short sequence)
{
	unsigned char	*packet;
	struct icmphdr	*icmp;
	struct timeval	*payload_ts;
	size_t			offset;

	packet = (unsigned char *)malloc(session->packet_size);
	if (!packet)
	{
		fprintf(stderr, "ft_ping: malloc failed\n");
		return (-1);
	}
	ft_bzero(packet, session->packet_size);
	icmp = (struct icmphdr *)packet;
	icmp->type = ICMP_ECHO;
	icmp->code = 0;
	icmp->un.echo.id = htons(session->ident);
	icmp->un.echo.sequence = htons(sequence);
	payload_ts = (struct timeval *)(packet + sizeof(struct icmphdr));
	gettimeofday(payload_ts, NULL);
	offset = sizeof(struct icmphdr) + sizeof(struct timeval);
	if (session->options.pattern_len > 0 && offset < session->packet_size)
	{
		size_t	i;
		size_t	fill_len;

		fill_len = session->packet_size - offset;
		i = 0;
		while (i < fill_len)
		{
			packet[offset + i] = session->options.payload_pattern[i % session->options.pattern_len];
			i++;
		}
	}
	icmp->checksum = ft_icmp_checksum(packet, session->packet_size);
	if (sendto(session->sockfd, packet, session->packet_size, 0,
			(struct sockaddr *)&session->dest, sizeof(session->dest)) < 0)
	{
		fprintf(stderr, "ft_ping: sendto failed (errno %d)\n", errno);
		free(packet);
		return (-1);
	}
	free(packet);
	ft_stats_on_send(&session->stats);
	return (0);
}

static int	set_socket_timeout(int sockfd, double timeout_ms)
{
	struct timeval	tv;
	long			micros;

	if (timeout_ms < 0.0)
		timeout_ms = 0.0;
	micros = (long)(timeout_ms * 1000.0);
	if (micros < 0)
		micros = 0;
	tv.tv_sec = micros / 1000000;
	tv.tv_usec = micros % 1000000;
	if (setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv)) < 0)
		return (-1);
	return (0);
}

static unsigned short	extract_inner_sequence(const t_session *session,
			const unsigned char *buffer, ssize_t bytes, size_t outer_ip_len)
{
	const unsigned char	*cursor;
	const struct iphdr	*inner_ip;
	const struct icmphdr	*inner_icmp;
	ssize_t				remaining;
	size_t				inner_ip_len;

	if (bytes <= (ssize_t)(outer_ip_len + sizeof(struct icmphdr)))
		return (0);
	cursor = buffer + outer_ip_len + sizeof(struct icmphdr);
	remaining = bytes - (ssize_t)(outer_ip_len + sizeof(struct icmphdr));
	if (remaining < (ssize_t)sizeof(struct iphdr))
		return (0);
	inner_ip = (const struct iphdr *)cursor;
	inner_ip_len = inner_ip->ihl * 4;
	if (inner_ip_len < sizeof(struct iphdr) || remaining < (ssize_t)(inner_ip_len + sizeof(struct icmphdr)))
		return (0);
	if (inner_ip->protocol != IPPROTO_ICMP)
		return (0);
	inner_icmp = (const struct icmphdr *)(cursor + inner_ip_len);
	if (inner_icmp->un.echo.id != htons(session->ident))
		return (0);
	return (ntohs(inner_icmp->un.echo.sequence));
}

static const char	*icmp_description(uint8_t type, uint8_t code)
{
	if (type == ICMP_DEST_UNREACH)
	{
		if (code == ICMP_NET_UNREACH)
			return ("Destination Net Unreachable");
		if (code == ICMP_HOST_UNREACH)
			return ("Destination Host Unreachable");
		if (code == ICMP_PORT_UNREACH)
			return ("Destination Port Unreachable");
		if (code == ICMP_FRAG_NEEDED)
			return ("Fragmentation Needed and DF set");
		return ("Destination Unreachable");
	}
	if (type == ICMP_TIME_EXCEEDED)
	{
		if (code == ICMP_EXC_TTL)
			return ("Time to live exceeded");
		return ("Fragment reassembly time exceeded");
	}
	if (type == ICMP_REDIRECT)
		return ("Redirect Message");
	if (type == ICMP_SOURCE_QUENCH)
		return ("Source Quench");
	if (type == ICMP_PARAMETERPROB)
		return ("Parameter Problem");
	return ("ICMP message");
}

static void	print_verbose_message(const t_session *session, const t_reply_info *info)
{
	char		addr_str[INET_ADDRSTRLEN];
	const char	*description;
	struct timeval	now;
	char		hostbuf[NI_MAXHOST];
	const char	*display_host;

	if (!inet_ntop(AF_INET, &info->addr.sin_addr, addr_str, sizeof(addr_str)))
		ft_strlcpy(addr_str, session->resolved_ip, sizeof(addr_str));
	display_host = addr_str;
	if (session->options.resolve_reply)
	{
		if (getnameinfo((struct sockaddr *)&info->addr, sizeof(info->addr),
				hostbuf, sizeof(hostbuf), NULL, 0, NI_NAMEREQD) == 0)
			display_host = hostbuf;
	}
	description = icmp_description(info->type, info->code);
	gettimeofday(&now, NULL);
	if (session->options.print_timestamp)
		printf("[%ld.%03ld] ",
			(long)now.tv_sec, (long)(now.tv_usec / 1000));
	if (info->seq > 0)
		printf("From %s icmp_seq=%u %s (type=%u code=%u)\n",
			display_host, info->seq, description, info->type, info->code);
	else
		printf("From %s %s (type=%u code=%u)\n",
			display_host, description, info->type, info->code);
}

static int	receive_once(t_session *session, double timeout_ms, t_reply_info *info)
{
	size_t			buffer_len;
	unsigned char	*buffer;
	struct iovec	iov;
	struct msghdr	msg;
	ssize_t			bytes;
	struct iphdr	*ip;
	size_t			ip_header_len;
	struct icmphdr	*icmp;
	struct timeval	now;

	if (set_socket_timeout(session->sockfd, timeout_ms) < 0)
	{
		fprintf(stderr, "ft_ping: setsockopt failed (errno %d)\n", errno);
		return (-1);
	}
	buffer_len = session->packet_size + 128;
	if (buffer_len < 1024)
		buffer_len = 1024;
	buffer = (unsigned char *)malloc(buffer_len);
	if (!buffer)
	{
		fprintf(stderr, "ft_ping: malloc failed\n");
		return (-1);
	}
	ft_bzero(info, sizeof(*info));
	ft_bzero(&msg, sizeof(msg));
	ft_bzero(&info->addr, sizeof(info->addr));
	iov.iov_base = buffer;
	iov.iov_len = buffer_len;
	msg.msg_name = &info->addr;
	msg.msg_namelen = sizeof(info->addr);
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;
	bytes = recvmsg(session->sockfd, &msg, 0);
	if (bytes < 0)
	{
		if (errno == EAGAIN || errno == EWOULDBLOCK)
		{
			free(buffer);
			return (1);
		}
		if (errno == EINTR)
		{
			free(buffer);
			return (-2);
		}
		fprintf(stderr, "ft_ping: recvmsg failed (errno %d)\n", errno);
		free(buffer);
		return (-1);
	}
	if (bytes == 0 || (msg.msg_flags & MSG_TRUNC))
	{
		free(buffer);
		return (2);
	}
	if ((size_t)bytes < sizeof(struct iphdr) + sizeof(struct icmphdr))
	{
		free(buffer);
		return (2);
	}
	ip = (struct iphdr *)buffer;
	ip_header_len = (size_t)ip->ihl * 4;
	if (ip_header_len < sizeof(struct iphdr) || bytes < (ssize_t)(ip_header_len + sizeof(struct icmphdr)))
	{
		free(buffer);
		return (2);
	}
	icmp = (struct icmphdr *)(buffer + ip_header_len);
	info->type = icmp->type;
	info->code = icmp->code;
	if (icmp->type == ICMP_ECHOREPLY && icmp->un.echo.id == htons(session->ident))
	{
		struct timeval	*sent_ts;

		gettimeofday(&now, NULL);
		sent_ts = (struct timeval *)((unsigned char *)icmp + sizeof(struct icmphdr));
		info->rtt_ms = ft_time_diff_ms(sent_ts, &now);
		info->ttl = ip->ttl;
		info->seq = ntohs(icmp->un.echo.sequence);
		info->is_echo = 1;
		free(buffer);
		return (0);
	}
	info->is_echo = 0;
	info->seq = extract_inner_sequence(session,
			buffer, bytes, ip_header_len);
	free(buffer);
	return (2);
}

static int	wait_for_reply(t_session *session, const struct timeval *send_time,
			t_reply_info *reply, int *has_reply, double timeout_ms)
{
	int	stored;

	stored = 0;
	while (!g_stop)
	{
		struct timeval	now;
		double			elapsed;
		double			remaining;
		t_reply_info	temp;
		int				ret;

		gettimeofday(&now, NULL);
		elapsed = ft_time_diff_ms(send_time, &now);
		if (elapsed >= timeout_ms)
			break;
		remaining = timeout_ms - elapsed;
		ret = receive_once(session, remaining, &temp);
		if (ret == 0)
		{
			if (!stored)
			{
				*reply = temp;
				stored = 1;
			}
			else
			{
				session->stats.duplicates++;
				if (!session->options.quiet)
				{
					char	addr_str[INET_ADDRSTRLEN];

					if (!inet_ntop(AF_INET, &temp.addr.sin_addr, addr_str, sizeof(addr_str)))
						ft_strlcpy(addr_str, session->resolved_ip, sizeof(addr_str));
					printf("%zu bytes from %s: icmp_seq=%u ttl=%u time=%.3f ms (DUP!)\n",
						session->packet_size, addr_str, temp.seq, temp.ttl, temp.rtt_ms);
				}
			}
		}
		else if (ret == 1)
			break;
		else if (ret == 2)
		{
			if (session->options.verbose && !session->options.quiet)
				print_verbose_message(session, &temp);
		}
		else if (ret == -2)
			continue;
		else if (ret < 0)
			return (-1);
	}
	*has_reply = stored;
	return (0);
}

static void	print_reply(const t_session *session, const t_reply_info *reply, int out_of_order)
{
	char	addr_str[INET_ADDRSTRLEN];
	struct timeval	now;
	char	hostbuf[NI_MAXHOST];
	const char	*display_host;

	if (session->options.quiet)
		return;
	if (!inet_ntop(AF_INET, &reply->addr.sin_addr, addr_str, sizeof(addr_str)))
		ft_strlcpy(addr_str, session->resolved_ip, sizeof(addr_str));
	display_host = addr_str;
	if (session->options.resolve_reply)
	{
		if (getnameinfo((struct sockaddr *)&reply->addr, sizeof(reply->addr),
				hostbuf, sizeof(hostbuf), NULL, 0, NI_NAMEREQD) == 0)
			display_host = hostbuf;
	}
	gettimeofday(&now, NULL);
	if (session->options.print_timestamp)
		printf("[%ld.%03ld] ", (long)now.tv_sec, (long)(now.tv_usec / 1000));
	printf("%zu bytes from %s: icmp_seq=%u ttl=%u time=%.3f ms",
		session->packet_size, display_host, reply->seq, reply->ttl, reply->rtt_ms);
	if (out_of_order)
		printf(" (OUT-OF-ORDER)");
	printf("\n");
}

int	ft_ping_run(const t_options *opts)
{
	t_session	session;
	int			status;
	long		interval_us;
	double		timeout_ms;
	double		deadline_ms;

	init_session(&session, opts);
	if (resolve_target(&session) != 0)
		return (-1);
	if (open_socket(&session) != 0)
		return (-1);
	signal(SIGINT, handle_sigint);
	print_banner(&session);
	gettimeofday(&session.start_time, NULL);
	status = 0;
	if (session.options.interval_ms > 0.0)
		interval_us = (long)(session.options.interval_ms * 1000.0);
	else
		interval_us = (long)(FT_PING_DEFAULT_INTERVAL_MS * 1000.0);
	if (interval_us < 0)
		interval_us = 0;
	if (session.options.timeout_ms > 0.0)
		timeout_ms = session.options.timeout_ms;
	else
		timeout_ms = FT_PING_DEFAULT_TIMEOUT_MS;
	if (session.options.deadline_ms > 0.0)
		deadline_ms = session.options.deadline_ms;
	else
		deadline_ms = -1.0;
	while (!g_stop)
	{
		struct timeval	send_time;
		t_reply_info	reply;
		int				has_reply;
		double			loop_timeout;

		if (session.options.count > 0 && session.sequence > (unsigned short)session.options.count)
			break;
		if (deadline_ms > 0.0)
		{
			struct timeval	now;
			double			elapsed_total;

			gettimeofday(&now, NULL);
			elapsed_total = ft_time_diff_ms(&session.start_time, &now);
			if (elapsed_total >= deadline_ms)
				break;
			loop_timeout = timeout_ms;
			if (loop_timeout > deadline_ms - elapsed_total)
				loop_timeout = deadline_ms - elapsed_total;
			if (loop_timeout < 0.0)
				loop_timeout = 0.0;
		}
		else
			loop_timeout = timeout_ms;
		gettimeofday(&send_time, NULL);
		if (send_echo_request(&session, session.sequence) != 0)
		{
			status = -1;
			break;
		}
		if (wait_for_reply(&session, &send_time, &reply, &has_reply, loop_timeout) != 0)
		{
			status = -1;
			break;
		}
		if (has_reply)
		{
			int	out_of_order;

			out_of_order = ft_stats_on_reply(&session.stats, reply.seq, reply.rtt_ms);
			print_reply(&session, &reply, out_of_order);
			if (session.options.stop_on_reply)
				break;
		}
		else if (!g_stop && !session.options.quiet)
		{
			struct timeval	now;

			if (session.options.print_timestamp)
			{
				gettimeofday(&now, NULL);
				printf("[%ld.%03ld] ", (long)now.tv_sec, (long)(now.tv_usec / 1000));
			}
			printf("Request timeout for icmp_seq %u\n", session.sequence);
		}
		session.sequence++;
		if (!g_stop && session.options.count != 0)
			usleep(interval_us);
	}
	if (session.stats.sent > 0)
	{
		printf("\n");
		ft_stats_print(&session);
	}
	if (session.sockfd >= 0)
		close(session.sockfd);
	if (status == 0 && session.stats.sent > 0)
	{
		double	loss_pct;

		loss_pct = ((double)(session.stats.sent - session.stats.received)
				/ session.stats.sent) * 100.0;
		if (loss_pct > 0.0)
			status = 1;
	}
	return (status);
}
