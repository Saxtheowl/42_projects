#include "libft.h"

#include <unistd.h>

void    ft_putchar_fd(char c, int fd)
{
    write(fd, &c, 1);
}

void    ft_putstr_fd(char const *s, int fd)
{
    if (!s)
        return ;
    write(fd, s, ft_strlen(s));
}

void    ft_putendl_fd(char const *s, int fd)
{
    if (!s)
        return ;
    ft_putstr_fd(s, fd);
    write(fd, "\n", 1);
}

void    ft_putnbr_fd(int n, int fd)
{
    long nb;

    nb = n;
    if (nb < 0)
    {
        ft_putchar_fd('-', fd);
        nb = -nb;
    }
    if (nb >= 10)
    {
        ft_putnbr_fd((int)(nb / 10), fd);
        ft_putnbr_fd((int)(nb % 10), fd);
    }
    else
        ft_putchar_fd((char)(nb + '0'), fd);
}
