#include "ft_ping.h"

#include <errno.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#define FT_PING_TIMEOUT_MS 1000.0

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

	sockfd = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
	if (sockfd < 0)
	{
		fprintf(stderr, "ft_ping: socket failed (errno %d)\n", errno);
		return (-1);
	}
	session->sockfd = sockfd;
	ttl = FT_PING_DEFAULT_TTL;
	if (setsockopt(sockfd, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0)
		fprintf(stderr, "ft_ping: warning: cannot set TTL (errno %d)\n", errno);
	return (0);
}

static void	print_banner(const t_session *session)
{
	const char	*host;

	host = session->resolved_host[0] ? session->resolved_host : session->options.target;
	printf("PING %s (%s) %d(%zu) bytes of data.\n",
		host, session->resolved_ip,
		FT_PING_PAYLOAD_SIZE, (size_t)FT_PING_PACKET_SIZE);
}

static int	send_echo_request(t_session *session, unsigned short sequence)
{
	unsigned char	packet[FT_PING_PACKET_SIZE];
	struct icmphdr	*icmp;
	struct timeval	*payload_ts;

	ft_bzero(packet, sizeof(packet));
	icmp = (struct icmphdr *)packet;
	icmp->type = ICMP_ECHO;
	icmp->code = 0;
	icmp->un.echo.id = htons(session->ident);
	icmp->un.echo.sequence = htons(sequence);
	payload_ts = (struct timeval *)(packet + sizeof(struct icmphdr));
	gettimeofday(payload_ts, NULL);
	icmp->checksum = ft_icmp_checksum(packet, sizeof(packet));
	if (sendto(session->sockfd, packet, sizeof(packet), 0,
			(struct sockaddr *)&session->dest, sizeof(session->dest)) < 0)
	{
		fprintf(stderr, "ft_ping: sendto failed (errno %d)\n", errno);
		return (-1);
	}
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

	if (!inet_ntop(AF_INET, &info->addr.sin_addr, addr_str, sizeof(addr_str)))
		ft_strlcpy(addr_str, session->resolved_ip, sizeof(addr_str));
	description = icmp_description(info->type, info->code);
	if (info->seq > 0)
		printf("From %s icmp_seq=%u %s (type=%u code=%u)\n",
			addr_str, info->seq, description, info->type, info->code);
	else
		printf("From %s %s (type=%u code=%u)\n",
			addr_str, description, info->type, info->code);
}

static int	receive_once(t_session *session, double timeout_ms, t_reply_info *info)
{
	unsigned char	buffer[1024];
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
	ft_bzero(info, sizeof(*info));
	ft_bzero(&msg, sizeof(msg));
	ft_bzero(&info->addr, sizeof(info->addr));
	iov.iov_base = buffer;
	iov.iov_len = sizeof(buffer);
	msg.msg_name = &info->addr;
	msg.msg_namelen = sizeof(info->addr);
	msg.msg_iov = &iov;
	msg.msg_iovlen = 1;
	bytes = recvmsg(session->sockfd, &msg, 0);
	if (bytes < 0)
	{
		if (errno == EAGAIN || errno == EWOULDBLOCK)
			return (1);
		if (errno == EINTR)
			return (-2);
		fprintf(stderr, "ft_ping: recvmsg failed (errno %d)\n", errno);
		return (-1);
	}
	if (bytes == 0 || (msg.msg_flags & MSG_TRUNC))
		return (2);
	if ((size_t)bytes < sizeof(struct iphdr) + sizeof(struct icmphdr))
		return (2);
	ip = (struct iphdr *)buffer;
	ip_header_len = (size_t)ip->ihl * 4;
	if (ip_header_len < sizeof(struct iphdr) || bytes < (ssize_t)(ip_header_len + sizeof(struct icmphdr)))
		return (2);
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
		return (0);
	}
	info->is_echo = 0;
	info->seq = extract_inner_sequence(session,
			buffer, bytes, ip_header_len);
	return (2);
}

static int	wait_for_reply(t_session *session, const struct timeval *send_time,
			t_reply_info *reply, int *has_reply)
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
		if (elapsed >= FT_PING_TIMEOUT_MS)
			break;
		remaining = FT_PING_TIMEOUT_MS - elapsed;
		ret = receive_once(session, remaining, &temp);
		if (ret == 0)
		{
			if (!stored)
			{
				*reply = temp;
				stored = 1;
			}
		}
		else if (ret == 1)
			break;
		else if (ret == 2)
		{
			if (session->options.verbose)
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

static void	print_reply(const t_session *session, const t_reply_info *reply)
{
	char	addr_str[INET_ADDRSTRLEN];

	if (!inet_ntop(AF_INET, &reply->addr.sin_addr, addr_str, sizeof(addr_str)))
		ft_strlcpy(addr_str, session->resolved_ip, sizeof(addr_str));
	printf("%zu bytes from %s: icmp_seq=%u ttl=%u time=%.3f ms\n",
		(size_t)FT_PING_PACKET_SIZE, addr_str, reply->seq, reply->ttl, reply->rtt_ms);
}

int	ft_ping_run(const t_options *opts)
{
	t_session	session;
	int			status;

	init_session(&session, opts);
	if (resolve_target(&session) != 0)
		return (-1);
	if (open_socket(&session) != 0)
		return (-1);
	signal(SIGINT, handle_sigint);
	print_banner(&session);
	gettimeofday(&session.start_time, NULL);
	status = 0;
	while (!g_stop)
	{
		struct timeval	send_time;
		t_reply_info	reply;
		int				has_reply;

		gettimeofday(&send_time, NULL);
		if (send_echo_request(&session, session.sequence) != 0)
		{
			status = -1;
			break;
		}
		if (wait_for_reply(&session, &send_time, &reply, &has_reply) != 0)
		{
			status = -1;
			break;
		}
		if (has_reply)
		{
			ft_stats_on_reply(&session.stats, reply.rtt_ms);
			print_reply(&session, &reply);
		}
		else if (!g_stop)
			printf("Request timeout for icmp_seq %u\n", session.sequence);
		session.sequence++;
	}
	if (session.stats.sent > 0)
	{
		printf("\n");
		ft_stats_print(&session);
	}
	if (session.sockfd >= 0)
		close(session.sockfd);
	return (status);
}
