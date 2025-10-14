#include "push_swap.h"

#include <stdlib.h>

int main(int argc, char **argv)
{
    t_program   ps;

    if (ps_parse_args(&ps, argc, argv) == -1)
        return (EXIT_FAILURE);
    if (!stack_is_sorted(&ps.a))
        run_algorithm(&ps);
    ps_cleanup(&ps);
    return (EXIT_SUCCESS);
}
