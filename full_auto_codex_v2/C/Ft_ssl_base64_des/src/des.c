#include "ft_ssl.h"
#include "des_tables.h"

#include <string.h>
#include <stdlib.h>
#include "md5.h"

static unsigned int left_rotate28(unsigned int v, int shift)
{
    return ((v << shift) | (v >> (28 - shift))) & 0x0FFFFFFF;
}

static void permute(const unsigned char *in, unsigned char *out, const unsigned char *table, int out_len)
{
    memset(out, 0, (out_len + 7) / 8);
    for (int i = 0; i < out_len; ++i)
    {
        int bit = (in[(table[i] - 1) / 8] >> (7 - ((table[i] - 1) % 8))) & 1;
        out[i / 8] |= bit << (7 - (i % 8));
    }
}

int des_derive_subkeys(const unsigned char key[8], unsigned char subkeys_enc[16][6], unsigned char subkeys_dec[16][6])
{
    unsigned char perm56[7];
    permute(key, perm56, g_pc1, 56);

    unsigned int c = ((unsigned int)perm56[0] << 20) | ((unsigned int)perm56[1] << 12) | ((unsigned int)perm56[2] << 4) | ((unsigned int)perm56[3] >> 4);
    c &= 0x0FFFFFFF;
    unsigned int d = (((unsigned int)perm56[3] & 0x0F) << 24) | ((unsigned int)perm56[4] << 16) | ((unsigned int)perm56[5] << 8) | (unsigned int)perm56[6];
    d &= 0x0FFFFFFF;

    for (int round = 0; round < 16; ++round)
    {
        c = left_rotate28(c, g_shifts[round]);
        d = left_rotate28(d, g_shifts[round]);
        unsigned long cd = ((unsigned long)c << 28) | d;
        unsigned char cd_bytes[7];
        for (int i = 0; i < 7; ++i)
            cd_bytes[i] = (cd >> (48 - 8 * (i + 1))) & 0xFF;
        permute(cd_bytes, subkeys_enc[round], g_pc2, 48);
        memcpy(subkeys_dec[15 - round], subkeys_enc[round], 6);
    }
    return 0;
}

static unsigned int feistel(unsigned int r, const unsigned char subkey[6])
{
    static const unsigned char g_exp[48] = {
        32, 1, 2, 3, 4, 5,
        4, 5, 6, 7, 8, 9,
        8, 9, 10, 11, 12, 13,
        12, 13, 14, 15, 16, 17,
        16, 17, 18, 19, 20, 21,
        20, 21, 22, 23, 24, 25,
        24, 25, 26, 27, 28, 29,
        28, 29, 30, 31, 32, 1
    };
    unsigned char r_bytes[4] = {
        (r >> 24) & 0xFF,
        (r >> 16) & 0xFF,
        (r >> 8) & 0xFF,
        r & 0xFF
    };
    unsigned char expanded[6];
    permute(r_bytes, expanded, g_exp, 48);
    unsigned long x = ((unsigned long)expanded[0] << 40) | ((unsigned long)expanded[1] << 32)
        | ((unsigned long)expanded[2] << 24) | ((unsigned long)expanded[3] << 16)
        | ((unsigned long)expanded[4] << 8) | (unsigned long)expanded[5];
    unsigned long sk = ((unsigned long)subkey[0] << 40) | ((unsigned long)subkey[1] << 32)
        | ((unsigned long)subkey[2] << 24) | ((unsigned long)subkey[3] << 16)
        | ((unsigned long)subkey[4] << 8) | (unsigned long)subkey[5];
    x ^= sk;

    unsigned int s_out = 0;
    for (int i = 0; i < 8; ++i)
    {
        unsigned char block6 = (x >> (42 - 6 * i)) & 0x3F;
        int row = ((block6 & 0x20) >> 4) | (block6 & 0x01);
        int col = (block6 >> 1) & 0x0F;
        s_out = (s_out << 4) | g_sboxes[i][row * 16 + col];
    }

    unsigned char s_bytes[4] = {
        (s_out >> 24) & 0xFF,
        (s_out >> 16) & 0xFF,
        (s_out >> 8) & 0xFF,
        s_out & 0xFF
    };
    unsigned char perm32[4];
    permute(s_bytes, perm32, g_p, 32);
    return ((unsigned int)perm32[0] << 24) | ((unsigned int)perm32[1] << 16) | ((unsigned int)perm32[2] << 8) | (unsigned int)perm32[3];
}

static void process_block(const unsigned char in[8], unsigned char out[8], const unsigned char subkeys[16][6])
{
    unsigned char permuted[8];
    permute(in, permuted, g_ip, 64);
    unsigned int l = ((unsigned int)permuted[0] << 24) | ((unsigned int)permuted[1] << 16) | ((unsigned int)permuted[2] << 8) | (unsigned int)permuted[3];
    unsigned int r = ((unsigned int)permuted[4] << 24) | ((unsigned int)permuted[5] << 16) | ((unsigned int)permuted[6] << 8) | (unsigned int)permuted[7];

    for (int i = 0; i < 16; ++i)
    {
        unsigned int tmp = r;
        r = l ^ feistel(r, subkeys[i]);
        l = tmp;
    }
    unsigned char pre_out[8];
    pre_out[0] = (r >> 24) & 0xFF;
    pre_out[1] = (r >> 16) & 0xFF;
    pre_out[2] = (r >> 8) & 0xFF;
    pre_out[3] = r & 0xFF;
    pre_out[4] = (l >> 24) & 0xFF;
    pre_out[5] = (l >> 16) & 0xFF;
    pre_out[6] = (l >> 8) & 0xFF;
    pre_out[7] = l & 0xFF;

    permute(pre_out, out, g_ip_inv, 64);
}

void des_encrypt_buffer(const unsigned char *in, size_t len, unsigned char *out, const unsigned char subkeys[16][6])
{
    for (size_t i = 0; i < len; i += 8)
        process_block(in + i, out + i, subkeys);
}

void des_decrypt_buffer(const unsigned char *in, size_t len, unsigned char *out, const unsigned char subkeys[16][6])
{
    for (size_t i = 0; i < len; i += 8)
        process_block(in + i, out + i, subkeys);
}

size_t des_pkcs7_pad(unsigned char **buf, size_t len)
{
    size_t pad = 8 - (len % 8);
    size_t new_len = len + pad;
    unsigned char *padded = realloc(*buf, new_len);
    if (!padded)
        return 0;
    for (size_t i = 0; i < pad; ++i)
        padded[len + i] = (unsigned char)pad;
    *buf = padded;
    return new_len;
}

int remove_pkcs7(unsigned char *buf, size_t *len)
{
    if (*len == 0)
        return -1;
    unsigned char pad = buf[*len - 1];
    if (pad == 0 || pad > 8 || pad > *len)
        return -1;
    for (size_t i = 0; i < pad; ++i)
        if (buf[*len - 1 - i] != pad)
            return -1;
    *len -= pad;
    return 0;
}

void des_cbc_process(const unsigned char *in, size_t len, unsigned char *out, const unsigned char subkeys[16][6], const unsigned char iv[8], int decrypt)
{
    unsigned char prev[8];
    memcpy(prev, iv, 8);
    unsigned char block[8];

    if (!decrypt)
    {
        for (size_t i = 0; i < len; i += 8)
        {
            for (int j = 0; j < 8; ++j)
                block[j] = in[i + j] ^ prev[j];
            process_block(block, out + i, subkeys);
            memcpy(prev, out + i, 8);
        }
    }
    else
    {
        for (size_t i = 0; i < len; i += 8)
        {
            process_block(in + i, block, subkeys);
            for (int j = 0; j < 8; ++j)
                out[i + j] = block[j] ^ prev[j];
            memcpy(prev, in + i, 8);
        }
    }
}

int derive_key_iv_md5(const char *password, const unsigned char *salt, unsigned char key[8], unsigned char iv[8])
{
    unsigned char md_buf[16];
    unsigned char prev[16];
    int prev_len = 0;
    int needed = 8 + 8;
    unsigned char out[32];
    int out_len = 0;

    while (needed > 0)
    {
        t_md5_ctx ctx;
        md5_init(&ctx);
        if (prev_len)
            md5_update(&ctx, prev, prev_len);
        md5_update(&ctx, (const unsigned char *)password, strlen(password));
        md5_update(&ctx, salt, 8);
        md5_final(md_buf, &ctx);
        memcpy(out + out_len, md_buf, 16);
        memcpy(prev, md_buf, 16);
        prev_len = 16;
        out_len += 16;
        needed -= 16;
    }
    memcpy(key, out, 8);
    memcpy(iv, out + 8, 8);
    return 0;
}
