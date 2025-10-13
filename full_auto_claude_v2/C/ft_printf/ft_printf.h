/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_printf.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: auto-generated <noreply@anthropic.com>     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by auto-gen          #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by auto-gen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_PRINTF_H
# define FT_PRINTF_H

# include <stdarg.h>
# include <unistd.h>
# include <stdlib.h>

/* Main function */
int		ft_printf(const char *format, ...);

/* Conversion handlers */
int		ft_print_char(int c);
int		ft_print_str(char *s);
int		ft_print_ptr(unsigned long ptr);
int		ft_print_nbr(int n);
int		ft_print_unsigned(unsigned int n);
int		ft_print_hex(unsigned int n, int uppercase);

/* Helper functions */
int		ft_putchar(char c);
int		ft_putstr(char *s);
int		ft_strlen(char *s);
void	ft_putnbr_base(unsigned long n, char *base, int *count);

#endif
