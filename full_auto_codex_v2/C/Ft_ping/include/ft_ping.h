#ifndef FT_PING_H
# define FT_PING_H

# include <arpa/inet.h>
# include <netdb.h>
# include <netinet/ip.h>
# include <netinet/ip_icmp.h>
# include <stddef.h>
# include <sys/time.h>

# define FT_PING_DEFAULT_TTL 64
# define FT_PING_DEFAULT_PAYLOAD_SIZE 56
# define FT_PING_MAX_PAYLOAD_SIZE 65400
# define FT_PING_INTERVAL_SEC 1

typedef struct s_options
{
	const char	*target;
	const char	*source_ip;
	int		 verbose;
	long	 count; /* <=0 means infinite */
	int		 ttl;   /* <=0 means default */
	int		 tos;   /* <0 means default */
	double	 interval_ms; /* <=0 means default */
	double	 timeout_ms; /* <=0 means default */
	double	 deadline_ms; /* <=0 means no deadline */
	size_t	 payload_size; /* payload length in bytes */
	unsigned char	payload_pattern[FT_PING_MAX_PAYLOAD_SIZE];
	size_t			pattern_len;
	int		 quiet;
	int		 print_timestamp;
	int		 resolve_reply;
	int		 stop_on_reply;
}	t_options;

typedef struct s_stats
{
	unsigned int	sent;
	unsigned int	received;
	unsigned int	duplicates;
	unsigned int	out_of_order;
	unsigned short	last_seq;
	int				has_last_seq;
	double			min_rtt;
	double			max_rtt;
	double			sum_rtt;
	double			sum_rtt_squared;
}	t_stats;

typedef struct s_session
{
	int				 sockfd;
	struct sockaddr_in dest;
	t_options		 options;
	t_stats			 stats;
	unsigned short	 ident;
	unsigned short	 sequence;
	size_t			 packet_size;
	int				 has_source;
	struct in_addr	 source_addr;
	struct timeval	 start_time;
	char			 resolved_host[NI_MAXHOST];
	char			 resolved_ip[INET_ADDRSTRLEN];
}	t_session;

/* options.c */
int		ft_parse_options(int argc, char **argv, t_options *opts);

/* ping.c */
int		ft_ping_run(const t_options *opts);

/* checksum.c */
unsigned short	ft_icmp_checksum(const void *data, size_t len);

/* stats.c */
void	ft_stats_init(t_stats *stats);
void	ft_stats_on_send(t_stats *stats);
int		ft_stats_on_reply(t_stats *stats, unsigned short seq, double rtt_ms);
void	ft_stats_print(const t_session *session);

/* utils.c */
double		ft_time_diff_ms(const struct timeval *start, const struct timeval *end);
size_t		ft_strlen(const char *s);
int			ft_strcmp(const char *s1, const char *s2);
int			ft_strncmp(const char *s1, const char *s2, size_t n);
size_t		ft_strlcpy(char *dst, const char *src, size_t size);
void		*ft_memcpy(void *dst, const void *src, size_t n);
int			ft_isdigit(int c);
long		ft_atol(const char *str, int *ok);
void		ft_bzero(void *ptr, size_t len);
void		*ft_memset(void *ptr, int value, size_t len);

#endif
