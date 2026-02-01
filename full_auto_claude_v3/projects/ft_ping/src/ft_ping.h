/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_ping.h                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_PING_H
# define FT_PING_H

# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <unistd.h>
# include <sys/types.h>
# include <sys/socket.h>
# include <sys/time.h>
# include <netinet/in.h>
# include <netinet/ip.h>
# include <netinet/ip_icmp.h>
# include <arpa/inet.h>
# include <netdb.h>
# include <signal.h>
# include <errno.h>
# include <math.h>

# define PACKET_SIZE 64
# define ICMP_HDR_SIZE 8
# define DATA_SIZE (PACKET_SIZE - ICMP_HDR_SIZE)

typedef struct s_ping
{
	int				sockfd;
	char			*hostname;
	char			ip_str[INET_ADDRSTRLEN];
	struct sockaddr_in	dest_addr;
	int				verbose;
	int				seq;
	int				sent;
	int				received;
	double			min_rtt;
	double			max_rtt;
	double			total_rtt;
	double			total_rtt_sq;
	pid_t			pid;
}	t_ping;

extern t_ping	g_ping;

int		resolve_hostname(t_ping *ping);
void	send_ping(t_ping *ping);
void	receive_ping(t_ping *ping);
void	print_stats(t_ping *ping);
void	print_usage(void);
void	print_help(void);

size_t	ft_strlen(const char *s);
int		ft_strcmp(const char *s1, const char *s2);
void	*ft_memset(void *b, int c, size_t len);
void	*ft_memcpy(void *dst, const void *src, size_t n);

#endif
