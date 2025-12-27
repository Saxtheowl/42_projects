#ifndef FT_SSL_H
#define FT_SSL_H

#include <stddef.h>

typedef enum e_algo
{
    ALGO_MD5,
    ALGO_SHA256
}   t_algo;

typedef enum e_action_type
{
    ACT_P,
    ACT_S
}   t_action_type;

typedef struct s_action
{
    t_action_type   type;
    char            *data;
}   t_action;

typedef struct s_opts
{
    t_algo  algo;
    int     quiet;
    int     reverse;
    t_action *actions;
    int     action_count;
    char    **files;
    int     file_count;
    unsigned char   *stdin_cache;
    size_t  stdin_cache_len;
    int     stdin_cached;
}   t_opts;

int     parse_args(int argc, char **argv, t_opts *opts);
int     hash_buffer(const unsigned char *data, size_t len, t_algo algo, unsigned char *out, unsigned int *out_len);
int     hash_file(const char *path, t_algo algo, unsigned char *out, unsigned int *out_len);
int     hash_stdin(t_algo algo, unsigned char *out, unsigned int *out_len);
void    print_hex(const unsigned char *buf, unsigned int len);
const char  *algo_name(t_algo algo);

#endif
