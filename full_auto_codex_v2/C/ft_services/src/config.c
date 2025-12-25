#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int parse_int(const char *value, int *out) {
    char *end;
    long v = strtol(value, &end, 10);
    if (*end != '\0')
        return -1;
    *out = (int)v;
    return 0;
}

int load_config(const char *path, struct ft_services_config *cfg) {
    FILE *f = fopen(path, "r");
    if (!f)
        return -1;
    char line[256];
    while (fgets(line, sizeof line, f)) {
        char *eq = strchr(line, '=');
        if (!eq)
            continue;
        *eq = '\0';
        char *key = line;
        char *value = eq + 1;
        char *nl = strpbrk(value, "\r\n");
        if (nl)
            *nl = '\0';
        if (strcmp(key, "port") == 0) {
            if (parse_int(value, &cfg->port) != 0) {
                fclose(f);
                return -1;
            }
        } else if (strcmp(key, "backlog") == 0) {
            if (parse_int(value, &cfg->backlog) != 0) {
                fclose(f);
                return -1;
            }
        } else if (strcmp(key, "log_path") == 0) {
            cfg->log_path = strdup(value);
            if (!cfg->log_path) {
                fclose(f);
                return -1;
            }
        } else if (strcmp(key, "welcome") == 0) {
            cfg->welcome = strdup(value);
            if (!cfg->welcome) {
                fclose(f);
                return -1;
            }
        } else if (strcmp(key, "max_connections") == 0) {
            if (parse_int(value, &cfg->max_connections) != 0) {
                fclose(f);
                return -1;
            }
        }
    }
    fclose(f);
    return 0;
}

void free_config(struct ft_services_config *cfg) {
    free(cfg->log_path);
    free(cfg->welcome);
}
