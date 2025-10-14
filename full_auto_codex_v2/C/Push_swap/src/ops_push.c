#include "push_swap.h"

static void push(t_stack *src, t_stack *dst)
{
    t_node *node;

    node = stack_take_top_node(src);
    if (!node)
        return ;
    stack_add_top_node(dst, node);
}

void    op_pa(t_program *ps)
{
    push(&ps->b, &ps->a);
    ps_record_op("pa");
}

void    op_pb(t_program *ps)
{
    push(&ps->a, &ps->b);
    ps_record_op("pb");
}
