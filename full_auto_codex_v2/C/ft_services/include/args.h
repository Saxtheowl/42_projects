#ifndef FT_SERVICES_ARGS_H
#define FT_SERVICES_ARGS_H

struct ft_services_args {
    const char *config_path;
};

int parse_args(int argc, char **argv, struct ft_services_args *args);

#endif
