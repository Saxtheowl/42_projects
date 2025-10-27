#ifndef MINITALK_H
# define MINITALK_H

# include <signal.h>
# include <stddef.h>
# include <sys/types.h>

size_t	ft_strlen(const char *s);
int		ft_isdigit(int c);
void	ft_putstr_fd(const char *s, int fd);
void	ft_putnbr_fd(int n, int fd);
int		parse_pid(const char *str, pid_t *pid);

#endif
