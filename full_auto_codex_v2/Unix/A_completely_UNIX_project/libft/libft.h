#ifndef LIBFT_H
#define LIBFT_H

#include <stddef.h>
#include <stdint.h>

size_t	ft_strlen(const char *s);
int		ft_strcmp(const char *s1, const char *s2);
int		ft_strncmp(const char *s1, const char *s2, size_t n);
void	*ft_memcpy(void *dst, const void *src, size_t n);
void	ft_bzero(void *s, size_t n);
void	*ft_calloc(size_t count, size_t size);
void	ft_putstr_fd(const char *s, int fd);
void	ft_putendl_fd(const char *s, int fd);
void	ft_putchar_fd(char c, int fd);

#endif
