#include "args.h"
#include <string.h>

int parse_args(int argc, char **argv, struct ft_services_args *args) {
    args->config_path = NULL;
    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "--config") == 0 && i + 1 < argc) {
            args->config_path = argv[++i];
        }
    }
    return 0;
}
