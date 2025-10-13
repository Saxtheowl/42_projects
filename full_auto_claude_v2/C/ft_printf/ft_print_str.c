/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_print_str.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: auto-generated <noreply@anthropic.com>     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by auto-gen          #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by auto-gen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_printf.h"

int	ft_print_str(char *s)
{
	if (!s)
		return (ft_putstr("(null)"));
	return (ft_putstr(s));
}
