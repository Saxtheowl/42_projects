#include "ft_ssl.h"

#include "digest.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int hash_buffer(const unsigned char *data, size_t len, t_algo algo, unsigned char *out, unsigned int *out_len)
{
    if (algo == ALGO_MD5)
    {
        md5_hash(data, len, out);
        *out_len = 16;
        return 0;
    }
    if (algo == ALGO_SHA256)
    {
        sha256_hash(data, len, out);
        *out_len = 32;
        return 0;
    }
    return -1;
}

int hash_file(const char *path, t_algo algo, unsigned char *out, unsigned int *out_len)
{
    FILE *f = fopen(path, "rb");
    if (!f)
        return -1;

    unsigned char buf[4096];
    size_t n;
    int ret = 0;

    if (algo == ALGO_MD5)
    {
        t_md5_ctx ctx;
        md5_init(&ctx);
        while ((n = fread(buf, 1, sizeof(buf), f)) > 0)
            md5_update(&ctx, buf, n);
        md5_final(out, &ctx);
        *out_len = 16;
    }
    else if (algo == ALGO_SHA256)
    {
        t_sha256_ctx ctx;
        sha256_init(&ctx);
        while ((n = fread(buf, 1, sizeof(buf), f)) > 0)
            sha256_update(&ctx, buf, n);
        sha256_final(out, &ctx);
        *out_len = 32;
    }
    else
        ret = -1;

    fclose(f);
    return ret;
}

int hash_stdin(t_algo algo, unsigned char *out, unsigned int *out_len)
{
    unsigned char buf[4096];
    size_t n;
    int ret = 0;

    if (algo == ALGO_MD5)
    {
        t_md5_ctx ctx;
        md5_init(&ctx);
        while ((n = fread(buf, 1, sizeof(buf), stdin)) > 0)
            md5_update(&ctx, buf, n);
        md5_final(out, &ctx);
        *out_len = 16;
    }
    else if (algo == ALGO_SHA256)
    {
        t_sha256_ctx ctx;
        sha256_init(&ctx);
        while ((n = fread(buf, 1, sizeof(buf), stdin)) > 0)
            sha256_update(&ctx, buf, n);
        sha256_final(out, &ctx);
        *out_len = 32;
    }
    else
        ret = -1;
    return ret;
}

void print_hex(const unsigned char *buf, unsigned int len)
{
    for (unsigned int i = 0; i < len; ++i)
        printf("%02x", buf[i]);
}

const char *algo_name(t_algo algo)
{
    return (algo == ALGO_MD5) ? "MD5" : "SHA256";
}
