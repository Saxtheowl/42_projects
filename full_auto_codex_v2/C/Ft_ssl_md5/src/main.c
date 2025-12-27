#include "ft_ssl.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "digest.h"

#define MD5_DIGEST_LENGTH 16
#define SHA256_DIGEST_LENGTH 32

static int read_stdin_buffer(unsigned char **out_buf, size_t *out_len)
{
    size_t cap = 4096;
    size_t len = 0;
    unsigned char *buf = malloc(cap);
    if (!buf)
        return -1;
    size_t n;
    unsigned char tmp[4096];
    while ((n = fread(tmp, 1, sizeof(tmp), stdin)) > 0)
    {
        if (len + n > cap)
        {
            size_t new_cap = cap * 2;
            while (len + n > new_cap)
                new_cap *= 2;
            unsigned char *new_buf = realloc(buf, new_cap);
            if (!new_buf)
            {
                free(buf);
                return -1;
            }
            buf = new_buf;
            cap = new_cap;
        }
        memcpy(buf + len, tmp, n);
        len += n;
    }
    *out_buf = buf;
    *out_len = len;
    return 0;
}

static void print_usage(void)
{
    fprintf(stderr, "usage: ft_ssl command [command opts] [command args]\n");
}

static int error_missing_arg(void)
{
    fprintf(stderr, "ft_ssl: option requires an argument -- s\n");
    print_usage();
    return -2;
}

static int error_unknown_opt(const char *opt)
{
    fprintf(stderr, "ft_ssl: illegal option -- %s\n", opt);
    print_usage();
    return -2;
}

static int error_invalid_cmd(const char *cmd)
{
    fprintf(stderr, "ft_ssl: Error: '%s' is an invalid command.\n", cmd);
    print_usage();
    return -2;
}

int parse_args(int argc, char **argv, t_opts *opts)
{
    if (argc < 2)
        return -1;
    if (strcmp(argv[1], "md5") == 0)
        opts->algo = ALGO_MD5;
    else if (strcmp(argv[1], "sha256") == 0)
        opts->algo = ALGO_SHA256;
    else
        return error_invalid_cmd(argv[1]);
    opts->quiet = 0;
    opts->reverse = 0;
    opts->actions = calloc((size_t)argc, sizeof(t_action));
    if (!opts->actions)
        return -1;
    opts->action_count = 0;
    opts->files = NULL;
    opts->file_count = 0;
    opts->stdin_cache = NULL;
    opts->stdin_cache_len = 0;
    opts->stdin_cached = 0;
    for (int i = 2; i < argc; ++i)
    {
        if (strcmp(argv[i], "-q") == 0)
            opts->quiet = 1;
        else if (strcmp(argv[i], "-r") == 0)
            opts->reverse = 1;
        else if (strcmp(argv[i], "-p") == 0)
        {
            opts->actions[opts->action_count].type = ACT_P;
            opts->actions[opts->action_count].data = NULL;
            opts->action_count++;
        }
        else if (strcmp(argv[i], "-s") == 0 && i + 1 < argc)
        {
            opts->actions[opts->action_count].type = ACT_S;
            opts->actions[opts->action_count].data = argv[++i];
            opts->action_count++;
        }
        else if (strcmp(argv[i], "-s") == 0)
            return error_missing_arg();
        else if (argv[i][0] == '-')
            return error_unknown_opt(argv[i]);
        else
        {
            opts->files = &argv[i];
            opts->file_count = argc - i;
            break;
        }
    }
    return 0;
}

static void print_result(const char *label, const char *target, const unsigned char *hash, unsigned int len, const t_opts *opts, int is_string)
{
    if (opts->quiet)
    {
        print_hex(hash, len);
        printf("\n");
        return;
    }
    if (opts->reverse)
    {
        print_hex(hash, len);
        if (is_string)
            printf(" \"%s\"\n", target);
        else
            printf(" %s\n", target);
        return;
    }
    if (is_string)
        printf("%s (\"%s\") = ", label, target);
    else
        printf("%s (%s) = ", label, target);
    print_hex(hash, len);
    printf("\n");
}

static int process_string(const t_opts *opts, const char *str)
{
    unsigned char out[SHA256_DIGEST_LENGTH];
    unsigned int out_len = 0;
    if (hash_buffer((const unsigned char *)str, strlen(str), opts->algo, out, &out_len) != 0)
        return -1;
    print_result(algo_name(opts->algo), str, out, out_len, opts, 1);
    return 0;
}

static int process_file(const t_opts *opts, const char *path)
{
    unsigned char out[SHA256_DIGEST_LENGTH];
    unsigned int out_len = 0;
    if (hash_file(path, opts->algo, out, &out_len) != 0)
    {
        fprintf(stderr, "ft_ssl: %s: No such file or directory\n", path);
        return -1;
    }
    print_result(algo_name(opts->algo), path, out, out_len, opts, 0);
    return 0;
}

static int process_stdin(const t_opts *opts)
{
    unsigned char out[SHA256_DIGEST_LENGTH];
    unsigned int out_len = 0;
    if (hash_stdin(opts->algo, out, &out_len) != 0)
        return -1;
    print_result(algo_name(opts->algo), "stdin", out, out_len, opts, 0);
    return 0;
}

static int process_p_option(const t_opts *opts)
{
    unsigned char out[SHA256_DIGEST_LENGTH];
    unsigned int out_len = 0;

    if (!opts->stdin_cached)
    {
        if (read_stdin_buffer((unsigned char **)&opts->stdin_cache, (size_t *)&opts->stdin_cache_len) != 0)
            return -1;
        ((t_opts *)opts)->stdin_cached = 1;
    }
    if (opts->stdin_cache_len > 0)
        fwrite(opts->stdin_cache, 1, opts->stdin_cache_len, stdout);
    if (opts->stdin_cache_len == 0 || opts->stdin_cache[opts->stdin_cache_len - 1] != '\n')
        putchar('\n');
    if (hash_buffer(opts->stdin_cache, opts->stdin_cache_len, opts->algo, out, &out_len) != 0)
        return -1;
    print_result(algo_name(opts->algo), "stdin", out, out_len, opts, 0);
    return 0;
}

int main(int argc, char **argv)
{
    t_opts opts;
    opts.actions = NULL;
    opts.stdin_cache = NULL;

    int parse_ret = parse_args(argc, argv, &opts);
    if (parse_ret != 0)
    {
        free(opts.actions);
        free(opts.stdin_cache);
        if (parse_ret != -2)
            print_usage();
        return EXIT_FAILURE;
    }
    /* process actions (-p/-s) in the order provided */
    for (int i = 0; i < opts.action_count; ++i)
    {
        if (opts.actions[i].type == ACT_P)
        {
            if (process_p_option(&opts) != 0)
            {
                free(opts.actions);
                free(opts.stdin_cache);
                return EXIT_FAILURE;
            }
        }
        else if (opts.actions[i].type == ACT_S)
        {
            if (process_string(&opts, opts.actions[i].data) != 0)
            {
                free(opts.actions);
                free(opts.stdin_cache);
                return EXIT_FAILURE;
            }
        }
    }
    /* stdin if no -s/files/-p provided */
    if (opts.action_count == 0 && opts.file_count == 0)
    {
        if (process_stdin(&opts) != 0)
        {
            free(opts.actions);
            free(opts.stdin_cache);
            return EXIT_FAILURE;
        }
        free(opts.actions);
        free(opts.stdin_cache);
        return EXIT_SUCCESS;
    }
    int file_status = 0;
    for (int i = 0; i < opts.file_count; ++i)
    {
        if (process_file(&opts, opts.files[i]) != 0)
            file_status = 1;
    }
    free(opts.actions);
    free(opts.stdin_cache);
    return file_status == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
