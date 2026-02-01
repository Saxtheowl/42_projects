/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_ssl.h                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FT_SSL_H
# define FT_SSL_H

# include <unistd.h>
# include <stdlib.h>
# include <fcntl.h>
# include <stdint.h>

# define BUFFER_SIZE 4096

typedef struct s_flags
{
	int		p;
	int		q;
	int		r;
}	t_flags;

typedef struct s_cipher_flags
{
	int		decode;
	int		base64;
	char	*in_file;
	char	*out_file;
	char	*key;
	char	*iv;
	int		in_fd;
	int		out_fd;
}	t_cipher_flags;

typedef struct s_md5_ctx
{
	uint32_t	state[4];
	uint32_t	count[2];
	uint8_t		buffer[64];
}	t_md5_ctx;

typedef struct s_sha256_ctx
{
	uint32_t	state[8];
	uint64_t	bitlen;
	uint32_t	datalen;
	uint8_t		data[64];
}	t_sha256_ctx;

size_t		ft_strlen(const char *s);
void		ft_putstr(const char *s);
void		ft_putchar(char c);
int			ft_strcmp(const char *s1, const char *s2);
void		*ft_memcpy(void *dst, const void *src, size_t n);
void		*ft_memset(void *b, int c, size_t len);

void		md5_init(t_md5_ctx *ctx);
void		md5_update(t_md5_ctx *ctx, const uint8_t *input, size_t len);
void		md5_final(uint8_t digest[16], t_md5_ctx *ctx);
void		md5_hash(const uint8_t *data, size_t len, uint8_t digest[16]);

void		sha256_init(t_sha256_ctx *ctx);
void		sha256_update(t_sha256_ctx *ctx, const uint8_t *data, size_t len);
void		sha256_final(t_sha256_ctx *ctx, uint8_t hash[32]);
void		sha256_hash(const uint8_t *data, size_t len, uint8_t hash[32]);

void		print_hash_hex(const uint8_t *hash, size_t len);
int			process_command(int argc, char **argv);

char		*base64_encode(const uint8_t *data, size_t len, size_t *out_len);
uint8_t		*base64_decode(const char *data, size_t len, size_t *out_len);
int			process_base64(int argc, char **argv);

void		des_encrypt_block(const uint8_t *in, uint8_t *out, uint64_t key);
void		des_decrypt_block(const uint8_t *in, uint8_t *out, uint64_t key);
int			des_ecb_encrypt(const uint8_t *in, size_t len, uint8_t *out,
				uint64_t key);
int			des_ecb_decrypt(const uint8_t *in, size_t len, uint8_t *out,
				uint64_t key);
int			des_cbc_encrypt(const uint8_t *in, size_t len, uint8_t *out,
				uint64_t key, uint8_t *iv);
int			des_cbc_decrypt(const uint8_t *in, size_t len, uint8_t *out,
				uint64_t key, uint8_t *iv);
int			process_des_ecb(int argc, char **argv);
int			process_des_cbc(int argc, char **argv);

uint8_t		*read_all_stdin(size_t *len);
int			parse_cipher_flags(int argc, char **argv, t_cipher_flags *flags);
uint64_t	hex_to_key(const char *hex);
void		hex_to_bytes(const char *hex, uint8_t *bytes, size_t len);

#endif
