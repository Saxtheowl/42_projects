#ifndef MD5_H
#define MD5_H

#include <stddef.h>
#include <stdint.h>

typedef struct s_md5_ctx
{
    uint32_t    state[4];
    uint64_t    bitcount;
    unsigned char buffer[64];
}   t_md5_ctx;

void    md5_init(t_md5_ctx *ctx);
void    md5_update(t_md5_ctx *ctx, const unsigned char *data, size_t len);
void    md5_final(unsigned char digest[16], t_md5_ctx *ctx);

#endif
