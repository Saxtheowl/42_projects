/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   base64.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ssl.h"

static const char	g_b64_table[] = 
	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static int	b64_char_to_val(char c)
{
	if (c >= 'A' && c <= 'Z')
		return (c - 'A');
	if (c >= 'a' && c <= 'z')
		return (c - 'a' + 26);
	if (c >= '0' && c <= '9')
		return (c - '0' + 52);
	if (c == '+')
		return (62);
	if (c == '/')
		return (63);
	return (-1);
}

char	*base64_encode(const uint8_t *data, size_t len, size_t *out_len)
{
	char	*result;
	size_t	i;
	size_t	j;
	uint32_t	triple;

	*out_len = ((len + 2) / 3) * 4;
	result = malloc(*out_len + 1);
	if (!result)
		return (NULL);
	i = 0;
	j = 0;
	while (i < len)
	{
		triple = ((uint32_t)data[i++]) << 16;
		if (i < len)
			triple |= ((uint32_t)data[i++]) << 8;
		if (i < len)
			triple |= data[i++];
		result[j++] = g_b64_table[(triple >> 18) & 0x3F];
		result[j++] = g_b64_table[(triple >> 12) & 0x3F];
		result[j++] = (i > len + 1) ? '=' : g_b64_table[(triple >> 6) & 0x3F];
		result[j++] = (i > len) ? '=' : g_b64_table[triple & 0x3F];
	}
	result[j] = '\0';
	return (result);
}

static size_t	count_padding(const char *data, size_t len)
{
	size_t	padding;

	padding = 0;
	if (len > 0 && data[len - 1] == '=')
		padding++;
	if (len > 1 && data[len - 2] == '=')
		padding++;
	return (padding);
}

static size_t	filter_input(const char *data, size_t len, char *filtered)
{
	size_t	i;
	size_t	j;

	i = 0;
	j = 0;
	while (i < len)
	{
		if ((data[i] >= 'A' && data[i] <= 'Z')
			|| (data[i] >= 'a' && data[i] <= 'z')
			|| (data[i] >= '0' && data[i] <= '9')
			|| data[i] == '+' || data[i] == '/' || data[i] == '=')
			filtered[j++] = data[i];
		i++;
	}
	return (j);
}

uint8_t	*base64_decode(const char *data, size_t len, size_t *out_len)
{
	char	*filtered;
	uint8_t	*result;
	size_t	flen;
	size_t	padding;
	size_t	i;
	size_t	j;
	uint32_t	quad;

	filtered = malloc(len + 1);
	if (!filtered)
		return (NULL);
	flen = filter_input(data, len, filtered);
	if (flen % 4 != 0)
	{
		free(filtered);
		return (NULL);
	}
	padding = count_padding(filtered, flen);
	*out_len = (flen / 4) * 3 - padding;
	result = malloc(*out_len + 1);
	if (!result)
	{
		free(filtered);
		return (NULL);
	}
	i = 0;
	j = 0;
	while (i < flen)
	{
		quad = b64_char_to_val(filtered[i++]) << 18;
		quad |= b64_char_to_val(filtered[i++]) << 12;
		if (filtered[i] != '=')
			quad |= b64_char_to_val(filtered[i]) << 6;
		i++;
		if (filtered[i] != '=')
			quad |= b64_char_to_val(filtered[i]);
		i++;
		result[j++] = (quad >> 16) & 0xFF;
		if (j < *out_len)
			result[j++] = (quad >> 8) & 0xFF;
		if (j < *out_len)
			result[j++] = quad & 0xFF;
	}
	free(filtered);
	return (result);
}

static int	process_base64_stdin(t_cipher_flags *flags)
{
	uint8_t	*data;
	size_t	len;
	size_t	out_len;

	data = read_all_stdin(&len);
	if (!data && len == 0)
		return (0);
	if (!data)
		return (1);
	if (flags->decode)
	{
		uint8_t *decoded = base64_decode((char *)data, len, &out_len);
		if (!decoded)
		{
			ft_putstr("Error: Invalid base64 input\n");
			free(data);
			return (1);
		}
		write(flags->out_fd, decoded, out_len);
		free(decoded);
	}
	else
	{
		char *encoded = base64_encode(data, len, &out_len);
		if (!encoded)
		{
			free(data);
			return (1);
		}
		write(flags->out_fd, encoded, out_len);
		write(flags->out_fd, "\n", 1);
		free(encoded);
	}
	free(data);
	return (0);
}

int	process_base64(int argc, char **argv)
{
	t_cipher_flags	flags;

	if (parse_cipher_flags(argc, argv, &flags) != 0)
		return (1);
	return (process_base64_stdin(&flags));
}
