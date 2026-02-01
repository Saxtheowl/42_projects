/* ************************************************************************** */
/*                                                                            */
/*   ft_traceroute - Network path tracing tool                                */
/*   Traces route to a host using ICMP or UDP                                 */
/*                                                                            */
/* ************************************************************************** */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <netinet/ip_icmp.h>
#include <netinet/udp.h>
#include <arpa/inet.h>
#include <netdb.h>

#define MAX_HOPS 30
#define NPROBES 3
#define TIMEOUT_SEC 1
#define BASE_PORT 33434
#define PACKET_SIZE 60

typedef struct s_trace
{
	int				sock_send;
	int				sock_recv;
	struct sockaddr_in	dest;
	char			*hostname;
	int				max_hops;
	int				nprobes;
	int				use_icmp;
}	t_trace;

static unsigned short	checksum(void *data, int len)
{
	unsigned short	*buf = data;
	unsigned int	sum = 0;
	unsigned short	result;

	while (len > 1)
	{
		sum += *buf++;
		len -= 2;
	}
	if (len == 1)
		sum += *(unsigned char *)buf;

	sum = (sum >> 16) + (sum & 0xFFFF);
	sum += (sum >> 16);
	result = ~sum;
	return (result);
}

static double	get_time_ms(void)
{
	struct timeval	tv;

	gettimeofday(&tv, NULL);
	return (tv.tv_sec * 1000.0 + tv.tv_usec / 1000.0);
}

static int	resolve_hostname(const char *hostname, struct sockaddr_in *addr)
{
	struct hostent	*host;

	memset(addr, 0, sizeof(*addr));
	addr->sin_family = AF_INET;

	if (inet_pton(AF_INET, hostname, &addr->sin_addr) == 1)
		return (0);

	host = gethostbyname(hostname);
	if (!host)
	{
		fprintf(stderr, "Cannot resolve %s: %s\n", hostname, hstrerror(h_errno));
		return (-1);
	}

	memcpy(&addr->sin_addr, host->h_addr_list[0], sizeof(addr->sin_addr));
	return (0);
}

static int	create_sockets(t_trace *trace)
{

	/* ICMP receive socket */
	trace->sock_recv = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
	if (trace->sock_recv < 0)
	{
		perror("socket (ICMP)");
		return (-1);
	}

	/* Set timeout */
	struct timeval tv = {TIMEOUT_SEC, 0};
	setsockopt(trace->sock_recv, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));

	if (trace->use_icmp)
	{
		/* ICMP send socket */
		trace->sock_send = socket(AF_INET, SOCK_RAW, IPPROTO_ICMP);
		if (trace->sock_send < 0)
		{
			perror("socket (ICMP send)");
			close(trace->sock_recv);
			return (-1);
		}
	}
	else
	{
		/* UDP send socket */
		trace->sock_send = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
		if (trace->sock_send < 0)
		{
			perror("socket (UDP)");
			close(trace->sock_recv);
			return (-1);
		}
	}

	return (0);
}

static int	send_probe_udp(t_trace *trace, int ttl, int probe)
{
	char				packet[PACKET_SIZE];
	struct sockaddr_in	dest;
	int					port;

	/* Set TTL */
	if (setsockopt(trace->sock_send, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0)
	{
		perror("setsockopt TTL");
		return (-1);
	}

	/* Different port for each probe */
	port = BASE_PORT + (ttl - 1) * trace->nprobes + probe;

	dest = trace->dest;
	dest.sin_port = htons(port);

	/* Send UDP packet */
	memset(packet, 0x40, sizeof(packet));
	if (sendto(trace->sock_send, packet, sizeof(packet), 0,
			   (struct sockaddr *)&dest, sizeof(dest)) < 0)
	{
		perror("sendto");
		return (-1);
	}

	return (0);
}

static int	send_probe_icmp(t_trace *trace, int ttl, int seq)
{
	char			packet[64];
	struct icmphdr	*icmp;

	/* Set TTL */
	if (setsockopt(trace->sock_send, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0)
	{
		perror("setsockopt TTL");
		return (-1);
	}

	/* Build ICMP packet */
	memset(packet, 0, sizeof(packet));
	icmp = (struct icmphdr *)packet;
	icmp->type = ICMP_ECHO;
	icmp->code = 0;
	icmp->un.echo.id = htons(getpid() & 0xFFFF);
	icmp->un.echo.sequence = htons(seq);
	icmp->checksum = 0;
	icmp->checksum = checksum(icmp, sizeof(*icmp) + 56);

	if (sendto(trace->sock_send, packet, sizeof(packet), 0,
			   (struct sockaddr *)&trace->dest, sizeof(trace->dest)) < 0)
	{
		perror("sendto");
		return (-1);
	}

	return (0);
}

static int	recv_reply(t_trace *trace, struct sockaddr_in *from,
					   int *icmp_type, int *icmp_code)
{
	char			buf[512];
	struct iphdr	*ip;
	struct icmphdr	*icmp;
	socklen_t		fromlen;
	ssize_t			n;

	fromlen = sizeof(*from);
	n = recvfrom(trace->sock_recv, buf, sizeof(buf), 0,
				 (struct sockaddr *)from, &fromlen);

	if (n < 0)
	{
		if (errno == EAGAIN || errno == EWOULDBLOCK)
			return (0);  /* Timeout */
		return (-1);
	}

	/* Parse IP header */
	ip = (struct iphdr *)buf;
	if (ip->protocol != IPPROTO_ICMP)
		return (0);

	/* Parse ICMP header */
	icmp = (struct icmphdr *)(buf + (ip->ihl * 4));
	*icmp_type = icmp->type;
	*icmp_code = icmp->code;

	return (1);
}

static void	print_addr(struct sockaddr_in *addr)
{
	char			hostname[NI_MAXHOST];
	char			ipstr[INET_ADDRSTRLEN];

	inet_ntop(AF_INET, &addr->sin_addr, ipstr, sizeof(ipstr));

	/* Try reverse DNS */
	if (getnameinfo((struct sockaddr *)addr, sizeof(*addr),
					hostname, sizeof(hostname), NULL, 0, 0) == 0)
	{
		printf("%s (%s)", hostname, ipstr);
	}
	else
	{
		printf("%s", ipstr);
	}
}

static int	traceroute(t_trace *trace)
{
	int					ttl;
	int					probe;
	int					done;
	double				send_time;
	double				rtt;
	struct sockaddr_in	from;
	struct sockaddr_in	last_from;
	int					icmp_type, icmp_code;
	int					got_reply;
	int					seq = 0;

	printf("traceroute to %s (%s), %d hops max, %d byte packets\n",
		   trace->hostname, inet_ntoa(trace->dest.sin_addr),
		   trace->max_hops, PACKET_SIZE);

	done = 0;
	for (ttl = 1; ttl <= trace->max_hops && !done; ttl++)
	{
		printf("%2d ", ttl);
		fflush(stdout);

		memset(&last_from, 0, sizeof(last_from));

		for (probe = 0; probe < trace->nprobes; probe++)
		{
			send_time = get_time_ms();

			if (trace->use_icmp)
			{
				if (send_probe_icmp(trace, ttl, seq++) < 0)
					return (-1);
			}
			else
			{
				if (send_probe_udp(trace, ttl, probe) < 0)
					return (-1);
			}

			got_reply = recv_reply(trace, &from, &icmp_type, &icmp_code);

			if (got_reply < 0)
				return (-1);

			if (got_reply == 0)
			{
				printf(" *");
			}
			else
			{
				rtt = get_time_ms() - send_time;

				/* Print address if different from last */
				if (from.sin_addr.s_addr != last_from.sin_addr.s_addr)
				{
					printf(" ");
					print_addr(&from);
				}
				printf("  %.3f ms", rtt);

				last_from = from;

				/* Check if destination reached */
				if (icmp_type == ICMP_ECHOREPLY ||
					icmp_type == ICMP_DEST_UNREACH)
				{
					if (from.sin_addr.s_addr == trace->dest.sin_addr.s_addr ||
						icmp_type == ICMP_DEST_UNREACH)
					{
						done = 1;
					}
				}
			}
		}
		printf("\n");
	}

	return (0);
}

static void	print_usage(const char *prog)
{
	printf("Usage: %s [options] host\n", prog);
	printf("Options:\n");
	printf("  -m max_ttl   Set max number of hops (default: %d)\n", MAX_HOPS);
	printf("  -q nqueries  Set number of probes per hop (default: %d)\n", NPROBES);
	printf("  -I           Use ICMP ECHO instead of UDP\n");
	printf("  -h           Show this help\n");
}

int	main(int argc, char **argv)
{
	t_trace	trace;
	int		opt;

	/* Initialize */
	memset(&trace, 0, sizeof(trace));
	trace.max_hops = MAX_HOPS;
	trace.nprobes = NPROBES;
	trace.use_icmp = 0;

	/* Parse options */
	while ((opt = getopt(argc, argv, "m:q:Ih")) != -1)
	{
		switch (opt)
		{
			case 'm':
				trace.max_hops = atoi(optarg);
				break;
			case 'q':
				trace.nprobes = atoi(optarg);
				break;
			case 'I':
				trace.use_icmp = 1;
				break;
			case 'h':
				print_usage(argv[0]);
				return (0);
			default:
				print_usage(argv[0]);
				return (1);
		}
	}

	if (optind >= argc)
	{
		print_usage(argv[0]);
		return (1);
	}

	trace.hostname = argv[optind];

	/* Check root */
	if (getuid() != 0)
	{
		fprintf(stderr, "Must run as root\n");
		return (1);
	}

	/* Resolve hostname */
	if (resolve_hostname(trace.hostname, &trace.dest) < 0)
		return (1);

	/* Create sockets */
	if (create_sockets(&trace) < 0)
		return (1);

	/* Run traceroute */
	int ret = traceroute(&trace);

	/* Cleanup */
	close(trace.sock_send);
	close(trace.sock_recv);

	return (ret == 0 ? 0 : 1);
}
