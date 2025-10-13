/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print_nbr.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: auto-generated <noreply@anthropic.com>     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by auto-gen          #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by auto-gen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_printf.h"

int	ft_print_nbr(int n)
{
	int		count;
	long	nb;

	count = 0;
	nb = n;
	if (nb < 0)
	{
		count += ft_putchar('-');
		nb = -nb;
	}
	ft_putnbr_base(nb, "0123456789", &count);
	return (count);
}
