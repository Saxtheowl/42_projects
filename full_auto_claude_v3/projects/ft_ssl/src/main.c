/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ssl.h"

static void	print_usage(void)
{
	ft_putstr("usage: ft_ssl command [flags] [file/string]\n");
}

static void	print_invalid_command(const char *cmd)
{
	ft_putstr("ft_ssl: Error: '");
	ft_putstr(cmd);
	ft_putstr("' is an invalid command.\n\n");
	ft_putstr("Standard commands:\n\n");
	ft_putstr("Message Digest commands:\nmd5\nsha256\n\n");
	ft_putstr("Cipher commands:\nbase64\ndes\ndes-ecb\ndes-cbc\n");
}

static int	is_hash_command(const char *cmd)
{
	return (ft_strcmp(cmd, "md5") == 0 || ft_strcmp(cmd, "sha256") == 0);
}

int	main(int argc, char **argv)
{
	if (argc < 2)
	{
		print_usage();
		return (1);
	}
	if (is_hash_command(argv[1]))
		return (process_command(argc, argv));
	if (ft_strcmp(argv[1], "base64") == 0)
		return (process_base64(argc, argv));
	if (ft_strcmp(argv[1], "des") == 0 || ft_strcmp(argv[1], "des-ecb") == 0)
		return (process_des_ecb(argc, argv));
	if (ft_strcmp(argv[1], "des-cbc") == 0)
		return (process_des_cbc(argc, argv));
	print_invalid_command(argv[1]);
	return (1);
}
