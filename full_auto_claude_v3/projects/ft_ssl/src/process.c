/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   process.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ft_ssl.h"

typedef struct s_hash_func
{
	void	(*hash)(const uint8_t *, size_t, uint8_t *);
	size_t	digest_len;
	char	*name;
	char	*name_upper;
}	t_hash_func;

static uint8_t	*read_stdin(size_t *len)
{
	uint8_t	buffer[BUFFER_SIZE];
	uint8_t	*data;
	uint8_t	*new_data;
	ssize_t	bytes_read;
	size_t	total;

	data = NULL;
	total = 0;
	bytes_read = read(0, buffer, BUFFER_SIZE);
	while (bytes_read > 0)
	{
		new_data = malloc(total + bytes_read);
		if (!new_data)
			return (free(data), NULL);
		if (data)
		{
			ft_memcpy(new_data, data, total);
			free(data);
		}
		ft_memcpy(new_data + total, buffer, bytes_read);
		data = new_data;
		total += bytes_read;
		bytes_read = read(0, buffer, BUFFER_SIZE);
	}
	*len = total;
	return (data);
}

static uint8_t	*read_file(const char *filename, size_t *len)
{
	int		fd;
	uint8_t	*data;
	uint8_t	*new_data;
	uint8_t	buffer[BUFFER_SIZE];
	ssize_t	bytes_read;
	size_t	total;

	fd = open(filename, O_RDONLY);
	if (fd < 0)
		return (NULL);
	data = NULL;
	total = 0;
	bytes_read = read(fd, buffer, BUFFER_SIZE);
	while (bytes_read > 0)
	{
		new_data = malloc(total + bytes_read);
		if (!new_data)
		{
			free(data);
			close(fd);
			return (NULL);
		}
		if (data)
		{
			ft_memcpy(new_data, data, total);
			free(data);
		}
		ft_memcpy(new_data + total, buffer, bytes_read);
		data = new_data;
		total += bytes_read;
		bytes_read = read(fd, buffer, BUFFER_SIZE);
	}
	close(fd);
	*len = total;
	return (data);
}

static void	output_string(const char *algo_upper, const char *str,
	uint8_t *hash, size_t hlen, t_flags *flags)
{
	if (flags->q)
	{
		print_hash_hex(hash, hlen);
		ft_putchar('\n');
	}
	else if (flags->r)
	{
		print_hash_hex(hash, hlen);
		ft_putstr(" \"");
		ft_putstr(str);
		ft_putstr("\"\n");
	}
	else
	{
		ft_putstr(algo_upper);
		ft_putstr(" (\"");
		ft_putstr(str);
		ft_putstr("\") = ");
		print_hash_hex(hash, hlen);
		ft_putchar('\n');
	}
}

static void	output_file(const char *algo_upper, const char *filename,
	uint8_t *hash, size_t hlen, t_flags *flags)
{
	if (flags->q)
	{
		print_hash_hex(hash, hlen);
		ft_putchar('\n');
	}
	else if (flags->r)
	{
		print_hash_hex(hash, hlen);
		ft_putchar(' ');
		ft_putstr(filename);
		ft_putchar('\n');
	}
	else
	{
		ft_putstr(algo_upper);
		ft_putstr(" (");
		ft_putstr(filename);
		ft_putstr(") = ");
		print_hash_hex(hash, hlen);
		ft_putchar('\n');
	}
}

static void	output_stdin(const uint8_t *data, size_t len,
	uint8_t *hash, size_t hlen, t_flags *flags)
{
	if (flags->p)
	{
		if (flags->q)
		{
			write(1, data, len);
			print_hash_hex(hash, hlen);
			ft_putchar('\n');
		}
		else
		{
			ft_putstr("(\"");
			write(1, data, len);
			if (len > 0 && data[len - 1] == '\n')
				write(1, "\b", 1);
			ft_putstr("\")= ");
			print_hash_hex(hash, hlen);
			ft_putchar('\n');
		}
	}
	else if (flags->q)
	{
		print_hash_hex(hash, hlen);
		ft_putchar('\n');
	}
	else
	{
		ft_putstr("(stdin)= ");
		print_hash_hex(hash, hlen);
		ft_putchar('\n');
	}
}

static void	process_stdin_hash(t_hash_func *hf, t_flags *flags)
{
	uint8_t	*data;
	uint8_t	hash[64];
	size_t	len;

	data = read_stdin(&len);
	if (!data && len == 0)
	{
		hf->hash((uint8_t *)"", 0, hash);
		output_stdin((uint8_t *)"", 0, hash, hf->digest_len, flags);
		return ;
	}
	if (!data)
		return ;
	hf->hash(data, len, hash);
	output_stdin(data, len, hash, hf->digest_len, flags);
	free(data);
}

static void	process_string_hash(t_hash_func *hf, const char *str, t_flags *fl)
{
	uint8_t	hash[64];
	size_t	len;

	len = ft_strlen(str);
	hf->hash((const uint8_t *)str, len, hash);
	output_string(hf->name_upper, str, hash, hf->digest_len, fl);
}

static int	process_file_hash(t_hash_func *hf, const char *fn, t_flags *fl)
{
	uint8_t	*data;
	uint8_t	hash[64];
	size_t	len;

	data = read_file(fn, &len);
	if (!data && len == 0)
	{
		hf->hash((uint8_t *)"", 0, hash);
		output_file(hf->name_upper, fn, hash, hf->digest_len, fl);
		return (0);
	}
	if (!data)
	{
		ft_putstr("ft_ssl: ");
		ft_putstr(hf->name);
		ft_putstr(": ");
		ft_putstr(fn);
		ft_putstr(": No such file or directory\n");
		return (1);
	}
	hf->hash(data, len, hash);
	output_file(hf->name_upper, fn, hash, hf->digest_len, fl);
	free(data);
	return (0);
}

static int	is_flag(const char *arg)
{
	return (arg[0] == '-' && arg[1] != '\0'
		&& (arg[1] == 'p' || arg[1] == 'q' || arg[1] == 'r' || arg[1] == 's')
		&& arg[2] == '\0');
}

static int	parse_flags(int argc, char **argv, t_flags *flags, int *idx)
{
	int	i;

	i = 2;
	flags->p = 0;
	flags->q = 0;
	flags->r = 0;
	while (i < argc && is_flag(argv[i]))
	{
		if (ft_strcmp(argv[i], "-p") == 0)
			flags->p = 1;
		else if (ft_strcmp(argv[i], "-q") == 0)
			flags->q = 1;
		else if (ft_strcmp(argv[i], "-r") == 0)
			flags->r = 1;
		else if (ft_strcmp(argv[i], "-s") == 0)
			break ;
		i++;
	}
	*idx = i;
	return (0);
}

int	process_command(int argc, char **argv)
{
	t_hash_func	hf;
	t_flags		flags;
	int			i;
	int			stdin_done;
	int			ret;

	if (ft_strcmp(argv[1], "md5") == 0)
	{
		hf.hash = md5_hash;
		hf.digest_len = 16;
		hf.name = "md5";
		hf.name_upper = "MD5";
	}
	else
	{
		hf.hash = sha256_hash;
		hf.digest_len = 32;
		hf.name = "sha256";
		hf.name_upper = "SHA256";
	}
	parse_flags(argc, argv, &flags, &i);
	stdin_done = 0;
	ret = 0;
	if (flags.p || (i >= argc))
	{
		process_stdin_hash(&hf, &flags);
		stdin_done = 1;
	}
	while (i < argc)
	{
		if (ft_strcmp(argv[i], "-s") == 0)
		{
			if (i + 1 >= argc)
			{
				ft_putstr("ft_ssl: ");
				ft_putstr(hf.name);
				ft_putstr(": -s: No such file or directory\n");
				ret = 1;
				i++;
			}
			else
			{
				process_string_hash(&hf, argv[i + 1], &flags);
				i += 2;
			}
		}
		else if (ft_strcmp(argv[i], "-p") == 0 && !stdin_done)
		{
			process_stdin_hash(&hf, &flags);
			stdin_done = 1;
			i++;
		}
		else if (is_flag(argv[i]))
			i++;
		else
		{
			if (process_file_hash(&hf, argv[i], &flags) != 0)
				ret = 1;
			i++;
		}
	}
	return (ret);
}
