#ifndef FT_SERVICES_CONFIG_H
#define FT_SERVICES_CONFIG_H

#include <stddef.h>

struct ft_services_config {
    int port;
    char *log_path;
    int backlog;
    char *welcome;
    int max_connections;
};

int load_config(const char *path, struct ft_services_config *cfg);
void free_config(struct ft_services_config *cfg);

#endif
