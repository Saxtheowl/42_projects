#include "ft_ssl.h"

#include <stdlib.h>
#include <time.h>
#include <fcntl.h>
#include <unistd.h>

int read_all(FILE *f, unsigned char **buf, size_t *len)
{
    size_t cap = 4096;
    size_t used = 0;
    unsigned char *tmp = malloc(cap);
    if (!tmp)
        return -1;
    size_t n;
    while ((n = fread(tmp + used, 1, cap - used, f)) > 0)
    {
        used += n;
        if (used == cap)
        {
            size_t new_cap = cap * 2;
            unsigned char *new_buf = realloc(tmp, new_cap);
            if (!new_buf)
            {
                free(tmp);
                return -1;
            }
            tmp = new_buf;
            cap = new_cap;
        }
    }
    if (ferror(f))
    {
        free(tmp);
        return -1;
    }
    *buf = tmp;
    *len = used;
    return 0;
}

int write_all(FILE *f, const unsigned char *buf, size_t len)
{
    size_t written = 0;
    while (written < len)
    {
        size_t n = fwrite(buf + written, 1, len - written, f);
        if (n == 0)
            return -1;
        written += n;
    }
    return 0;
}

int write_base64_wrapped(FILE *f, const unsigned char *buf, size_t len)
{
    size_t line = 0;
    for (size_t i = 0; i < len; ++i)
    {
        fputc(buf[i], f);
        line++;
        if (line == 64 && i + 1 != len)
        {
            fputc('\n', f);
            line = 0;
        }
    }
    fputc('\n', f);
    return ferror(f) ? -1 : 0;
}

int generate_salt(unsigned char salt[8])
{
    int fd = open("/dev/urandom", O_RDONLY);
    if (fd >= 0)
    {
        ssize_t n = read(fd, salt, 8);
        close(fd);
        if (n == 8)
            return 0;
    }
    srand((unsigned int)time(NULL));
    for (int i = 0; i < 8; ++i)
        salt[i] = (unsigned char)(rand() & 0xFF);
    return 0;
}

int has_salted_header(const unsigned char *buf, size_t len)
{
    if (len < 16)
        return 0;
    return (buf[0] == 'S' && buf[1] == 'a' && buf[2] == 'l' && buf[3] == 't' &&
            buf[4] == 'e' && buf[5] == 'd' && buf[6] == '_' && buf[7] == '_');
}
