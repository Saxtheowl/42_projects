#include "bsq.h"
#include <unistd.h>

static void write_newline(void)
{
    ssize_t ret;

    ret = write(1, "\n", 1);
    (void)ret;
}

static int process_map(t_map *map)
{
    t_square best_square;

    if (!map || !map_validate(map))
    {
        print_error();
        map_free(map);
        return (0);
    }
    best_square = solve_bsq(map);
    apply_solution(map, &best_square);
    map_print(map);
    map_free(map);
    return (1);
}

static void process_file(const char *filename)
{
    t_map *map;

    map = map_parse_from_file(filename);
    process_map(map);
}

static void process_stdin(void)
{
    t_map *map;

    map = map_parse_from_stdin();
    process_map(map);
}

int main(int argc, char **argv)
{
    int i;

    if (argc == 1)
    {
        process_stdin();
    }
    else
    {
        i = 1;
        while (i < argc)
        {
            process_file(argv[i]);
            if (i < argc - 1)
                write_newline();
            i++;
        }
    }
    return (0);
}
