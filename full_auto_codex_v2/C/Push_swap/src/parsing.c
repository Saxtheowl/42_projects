#include "push_swap.h"

#include <stdlib.h>

static int  value_exists(const t_stack *stack, int value)
{
    t_node *cur = stack->top;

    while (cur)
    {
        if (cur->value == value)
            return (1);
        cur = cur->next;
    }
    return (0);
}

static int  parse_tokens(t_program *ps, char **tokens)
{
    int     ok;
    long    value;

    for (size_t i = 0; tokens && tokens[i]; ++i)
    {
        value = ps_atol(tokens[i], &ok);
        if (!ok)
        {
            ps_putstr_fd("Error\n", 2);
            ps_free_split(tokens);
            return (-1);
        }
        if (value_exists(&ps->a, (int)value))
        {
            ps_putstr_fd("Error\n", 2);
            ps_free_split(tokens);
            return (-1);
        }
        if (stack_push_bottom(&ps->a, (int)value) == -1)
        {
            ps_free_split(tokens);
            return (-1);
        }
    }
    ps_free_split(tokens);
    return (0);
}

int ps_parse_args(t_program *ps, int argc, char **argv)
{
    char    **tokens;

    if (argc < 2)
        return (-1);
    stack_init(&ps->a, 'a');
    stack_init(&ps->b, 'b');
    for (int i = 1; i < argc; ++i)
    {
        if (ps_strlen(argv[i]) == 0)
            continue;
        tokens = ps_split(argv[i]);
        if (!tokens)
            return (-1);
        if (parse_tokens(ps, tokens) == -1)
        {
            stack_clear(&ps->a);
            return (-1);
        }
    }
    if (ps->a.size == 0)
    {
        stack_clear(&ps->a);
        return (-1);
    }
    return (0);
}
