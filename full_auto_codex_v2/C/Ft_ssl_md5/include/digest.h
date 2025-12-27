#ifndef DIGEST_H
#define DIGEST_H

#include <stddef.h>
#include <stdint.h>

/* MD5 */
typedef struct s_md5_ctx
{
    uint32_t    state[4];
    uint64_t    bitcount;
    unsigned char buffer[64];
}   t_md5_ctx;

void    md5_init(t_md5_ctx *ctx);
void    md5_update(t_md5_ctx *ctx, const unsigned char *data, size_t len);
void    md5_final(unsigned char digest[16], t_md5_ctx *ctx);
void    md5_hash(const unsigned char *data, size_t len, unsigned char digest[16]);

/* SHA256 */
typedef struct s_sha256_ctx
{
    uint32_t    state[8];
    uint64_t    bitcount;
    unsigned char buffer[64];
}   t_sha256_ctx;

void    sha256_init(t_sha256_ctx *ctx);
void    sha256_update(t_sha256_ctx *ctx, const unsigned char *data, size_t len);
void    sha256_final(unsigned char digest[32], t_sha256_ctx *ctx);
void    sha256_hash(const unsigned char *data, size_t len, unsigned char digest[32]);

#endif
