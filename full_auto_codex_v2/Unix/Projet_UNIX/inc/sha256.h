#ifndef SHA256_H
#define SHA256_H

#include <stddef.h>
#include <stdint.h>

#define SHA256_DIGEST_LENGTH 32

typedef struct s_sha256
{
    uint32_t    state[8];
    uint64_t    bitlen;
    uint8_t     buffer[64];
    size_t      buffer_len;
}   t_sha256;

void    sha256_init(t_sha256 *ctx);
void    sha256_update(t_sha256 *ctx, const uint8_t *data, size_t len);
void    sha256_final(t_sha256 *ctx, uint8_t digest[SHA256_DIGEST_LENGTH]);
void    sha256_hex(const uint8_t digest[SHA256_DIGEST_LENGTH], char out_hex[65]);
void    sha256_compute(const uint8_t *data, size_t len, uint8_t digest[SHA256_DIGEST_LENGTH]);

#endif
