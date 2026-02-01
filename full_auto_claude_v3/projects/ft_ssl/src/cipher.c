/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   cipher.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ssl.h"

uint8_t	*read_all_stdin(size_t *len)
{
	uint8_t	buffer[BUFFER_SIZE];
	uint8_t	*data;
	uint8_t	*new_data;
	ssize_t	bytes;
	size_t	total;

	data = NULL;
	total = 0;
	bytes = read(0, buffer, BUFFER_SIZE);
	while (bytes > 0)
	{
		new_data = malloc(total + bytes);
		if (!new_data)
			return (free(data), NULL);
		if (data)
		{
			ft_memcpy(new_data, data, total);
			free(data);
		}
		ft_memcpy(new_data + total, buffer, bytes);
		data = new_data;
		total += bytes;
		bytes = read(0, buffer, BUFFER_SIZE);
	}
	*len = total;
	return (data);
}

static int	hex_char_to_val(char c)
{
	if (c >= '0' && c <= '9')
		return (c - '0');
	if (c >= 'a' && c <= 'f')
		return (c - 'a' + 10);
	if (c >= 'A' && c <= 'F')
		return (c - 'A' + 10);
	return (-1);
}

uint64_t	hex_to_key(const char *hex)
{
	uint64_t	key;
	int			i;
	int			val;

	key = 0;
	i = 0;
	while (hex[i] && i < 16)
	{
		val = hex_char_to_val(hex[i]);
		if (val < 0)
			return (0);
		key = (key << 4) | val;
		i++;
	}
	while (i < 16)
	{
		key = key << 4;
		i++;
	}
	return (key);
}

void	hex_to_bytes(const char *hex, uint8_t *bytes, size_t len)
{
	size_t	i;
	int		high;
	int		low;

	i = 0;
	while (i < len)
	{
		high = hex_char_to_val(hex[i * 2]);
		low = hex_char_to_val(hex[i * 2 + 1]);
		if (high < 0)
			high = 0;
		if (low < 0)
			low = 0;
		bytes[i] = (high << 4) | low;
		i++;
	}
}

int	parse_cipher_flags(int argc, char **argv, t_cipher_flags *flags)
{
	int	i;

	flags->decode = 0;
	flags->in_file = NULL;
	flags->out_file = NULL;
	flags->key = NULL;
	flags->iv = NULL;
	flags->base64 = 0;
	flags->in_fd = 0;
	flags->out_fd = 1;
	i = 2;
	while (i < argc)
	{
		if (ft_strcmp(argv[i], "-d") == 0)
			flags->decode = 1;
		else if (ft_strcmp(argv[i], "-e") == 0)
			flags->decode = 0;
		else if (ft_strcmp(argv[i], "-a") == 0)
			flags->base64 = 1;
		else if (ft_strcmp(argv[i], "-i") == 0 && i + 1 < argc)
			flags->in_file = argv[++i];
		else if (ft_strcmp(argv[i], "-o") == 0 && i + 1 < argc)
			flags->out_file = argv[++i];
		else if (ft_strcmp(argv[i], "-k") == 0 && i + 1 < argc)
			flags->key = argv[++i];
		else if (ft_strcmp(argv[i], "-v") == 0 && i + 1 < argc)
			flags->iv = argv[++i];
		i++;
	}
	if (flags->in_file)
	{
		flags->in_fd = open(flags->in_file, O_RDONLY);
		if (flags->in_fd < 0)
		{
			ft_putstr("Error: Cannot open input file\n");
			return (1);
		}
		dup2(flags->in_fd, 0);
	}
	if (flags->out_file)
	{
		flags->out_fd = open(flags->out_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
		if (flags->out_fd < 0)
		{
			ft_putstr("Error: Cannot open output file\n");
			return (1);
		}
	}
	return (0);
}

static uint8_t	*add_pkcs7_padding(const uint8_t *data, size_t len, size_t *padded_len)
{
	uint8_t	*result;
	uint8_t	pad;
	size_t	i;

	pad = 8 - (len % 8);
	*padded_len = len + pad;
	result = malloc(*padded_len);
	if (!result)
		return (NULL);
	ft_memcpy(result, data, len);
	i = len;
	while (i < *padded_len)
	{
		result[i] = pad;
		i++;
	}
	return (result);
}

static size_t	remove_pkcs7_padding(uint8_t *data, size_t len)
{
	uint8_t	pad;

	if (len == 0)
		return (0);
	pad = data[len - 1];
	if (pad > 8 || pad == 0)
		return (len);
	return (len - pad);
}

int	process_des_ecb(int argc, char **argv)
{
	t_cipher_flags	flags;
	uint8_t		*data;
	uint8_t		*padded;
	uint8_t		*output;
	size_t		len;
	size_t		padded_len;
	uint64_t	key;

	if (parse_cipher_flags(argc, argv, &flags) != 0)
		return (1);
	if (!flags.key)
	{
		ft_putstr("Error: -k key required\n");
		return (1);
	}
	key = hex_to_key(flags.key);
	data = read_all_stdin(&len);
	if (!data && len == 0)
		return (0);
	if (!data)
		return (1);
	if (flags.decode)
	{
		if (flags.base64)
		{
			size_t dec_len;
			uint8_t *decoded = base64_decode((char *)data, len, &dec_len);
			free(data);
			data = decoded;
			len = dec_len;
		}
		output = malloc(len);
		if (!output)
			return (free(data), 1);
		des_ecb_decrypt(data, len, output, key);
		len = remove_pkcs7_padding(output, len);
		write(flags.out_fd, output, len);
	}
	else
	{
		padded = add_pkcs7_padding(data, len, &padded_len);
		if (!padded)
			return (free(data), 1);
		output = malloc(padded_len);
		if (!output)
			return (free(data), free(padded), 1);
		des_ecb_encrypt(padded, padded_len, output, key);
		if (flags.base64)
		{
			size_t enc_len;
			char *encoded = base64_encode(output, padded_len, &enc_len);
			write(flags.out_fd, encoded, enc_len);
			write(flags.out_fd, "\n", 1);
			free(encoded);
		}
		else
			write(flags.out_fd, output, padded_len);
		free(padded);
	}
	free(data);
	free(output);
	return (0);
}

int	process_des_cbc(int argc, char **argv)
{
	t_cipher_flags	flags;
	uint8_t		*data;
	uint8_t		*padded;
	uint8_t		*output;
	uint8_t		iv[8];
	size_t		len;
	size_t		padded_len;
	uint64_t	key;

	if (parse_cipher_flags(argc, argv, &flags) != 0)
		return (1);
	if (!flags.key)
	{
		ft_putstr("Error: -k key required\n");
		return (1);
	}
	key = hex_to_key(flags.key);
	if (flags.iv)
		hex_to_bytes(flags.iv, iv, 8);
	else
		ft_memset(iv, 0, 8);
	data = read_all_stdin(&len);
	if (!data && len == 0)
		return (0);
	if (!data)
		return (1);
	if (flags.decode)
	{
		if (flags.base64)
		{
			size_t dec_len;
			uint8_t *decoded = base64_decode((char *)data, len, &dec_len);
			free(data);
			data = decoded;
			len = dec_len;
		}
		output = malloc(len);
		if (!output)
			return (free(data), 1);
		des_cbc_decrypt(data, len, output, key, iv);
		len = remove_pkcs7_padding(output, len);
		write(flags.out_fd, output, len);
	}
	else
	{
		padded = add_pkcs7_padding(data, len, &padded_len);
		if (!padded)
			return (free(data), 1);
		output = malloc(padded_len);
		if (!output)
			return (free(data), free(padded), 1);
		des_cbc_encrypt(padded, padded_len, output, key, iv);
		if (flags.base64)
		{
			size_t enc_len;
			char *encoded = base64_encode(output, padded_len, &enc_len);
			write(flags.out_fd, encoded, enc_len);
			write(flags.out_fd, "\n", 1);
			free(encoded);
		}
		else
			write(flags.out_fd, output, padded_len);
		free(padded);
	}
	free(data);
	free(output);
	return (0);
}
