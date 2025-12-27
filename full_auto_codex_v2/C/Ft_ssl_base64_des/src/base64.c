#include "ft_ssl.h"

#include <stdlib.h>
#include <string.h>

static const char g_b64_alphabet[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

int base64_encode(const unsigned char *in, size_t in_len, unsigned char **out, size_t *out_len)
{
    size_t enc_len = ((in_len + 2) / 3) * 4;
    unsigned char *res = malloc(enc_len + 1);
    if (!res)
        return -1;
    size_t i = 0, j = 0;
    while (i < in_len)
    {
        size_t rem = in_len - i;
        unsigned int octet_a = in[i++];
        unsigned int octet_b = (rem > 1) ? in[i++] : 0;
        unsigned int octet_c = (rem > 2) ? in[i++] : 0;

        unsigned int triple = (octet_a << 16) | (octet_b << 8) | octet_c;
        res[j++] = g_b64_alphabet[(triple >> 18) & 0x3F];
        res[j++] = g_b64_alphabet[(triple >> 12) & 0x3F];
        res[j++] = (rem > 1) ? g_b64_alphabet[(triple >> 6) & 0x3F] : '=';
        res[j++] = (rem > 2) ? g_b64_alphabet[triple & 0x3F] : '=';
    }
    res[enc_len] = '\0';
    *out = res;
    *out_len = enc_len;
    return 0;
}

static int b64_value(int c)
{
    if ('A' <= c && c <= 'Z')
        return c - 'A';
    if ('a' <= c && c <= 'z')
        return c - 'a' + 26;
    if ('0' <= c && c <= '9')
        return c - '0' + 52;
    if (c == '+')
        return 62;
    if (c == '/')
        return 63;
    if (c == '=')
        return -2;
    return -1;
}

int base64_decode(const unsigned char *in, size_t in_len, unsigned char **out, size_t *out_len)
{
    /* strip whitespace */
    unsigned char *clean = malloc(in_len);
    if (!clean)
        return -1;
    size_t clen = 0;
    for (size_t k = 0; k < in_len; ++k)
    {
        unsigned char c = in[k];
        if (c == '\n' || c == '\r' || c == ' ' || c == '\t')
            continue;
        clean[clen++] = c;
    }

    if (clen % 4 != 0)
    {
        free(clean);
        return -1;
    }
    size_t dec_len = (clen / 4) * 3;
    unsigned char *res = malloc(dec_len);
    if (!res)
    {
        free(clean);
        return -1;
    }

    size_t i = 0, j = 0;
    while (i < clen)
    {
        int v0 = b64_value(clean[i++]);
        int v1 = b64_value(clean[i++]);
        int v2 = b64_value(clean[i++]);
        int v3 = b64_value(clean[i++]);
        if (v0 < 0 || v1 < 0 || v2 == -1 || v3 == -1)
        {
            free(res);
            free(clean);
            return -1;
        }

        unsigned int triple = (unsigned int)(v0 << 18) | (unsigned int)(v1 << 12);
        res[j++] = (triple >> 16) & 0xFF;
        if (v2 != -2)
        {
            triple |= (unsigned int)(v2 << 6);
            res[j++] = (triple >> 8) & 0xFF;
            if (v3 != -2)
            {
                triple |= (unsigned int)v3;
                res[j++] = triple & 0xFF;
            }
        }
        else if (v3 == -2)
        {
            /* == padding */
        }
        else
        {
            free(res);
            free(clean);
            return -1;
        }
    }
    free(clean);
    *out = res;
    *out_len = j;
    return 0;
}
