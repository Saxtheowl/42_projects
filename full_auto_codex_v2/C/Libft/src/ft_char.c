#include "libft.h"

#include <limits.h>

int ft_isalpha(int c)
{
    return ((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z'));
}

int ft_isdigit(int c)
{
    return (c >= '0' && c <= '9');
}

int ft_isalnum(int c)
{
    return (ft_isalpha(c) || ft_isdigit(c));
}

int ft_isascii(int c)
{
    return (c >= 0 && c <= 127);
}

int ft_isprint(int c)
{
    return (c >= 32 && c <= 126);
}

int ft_toupper(int c)
{
    if (c >= 'a' && c <= 'z')
        return (c - 32);
    return (c);
}

int ft_tolower(int c)
{
    if (c >= 'A' && c <= 'Z')
        return (c + 32);
    return (c);
}

int ft_atoi(const char *str)
{
    long    result;
    long    sign;

    result = 0;
    sign = 1;
    while (*str && (*str == ' ' || (*str >= '\t' && *str <= '\r')))
        str++;
    if (*str == '+' || *str == '-')
    {
        if (*str == '-')
            sign = -1;
        str++;
    }
    while (ft_isdigit(*str))
    {
        result = result * 10 + (*str - '0');
        if (sign == 1 && result > INT_MAX)
            return (INT_MAX);
        if (sign == -1 && -result < INT_MIN)
            return (INT_MIN);
        str++;
    }
    return ((int)(result * sign));
}
