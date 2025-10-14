#include "push_swap.h"

static void rotate(t_stack *stack)
{
    t_node *node;

    if (!stack || stack->size < 2)
        return ;
    node = stack_take_top_node(stack);
    stack_add_bottom_node(stack, node);
}

static void reverse_rotate(t_stack *stack)
{
    t_node *node;

    if (!stack || stack->size < 2)
        return ;
    node = stack_take_bottom_node(stack);
    stack_add_top_node(stack, node);
}

void    op_ra(t_program *ps)
{
    rotate(&ps->a);
    ps_record_op("ra");
}

void    op_rb(t_program *ps)
{
    rotate(&ps->b);
    ps_record_op("rb");
}

void    op_rr(t_program *ps)
{
    rotate(&ps->a);
    rotate(&ps->b);
    ps_record_op("rr");
}

void    op_rra(t_program *ps)
{
    reverse_rotate(&ps->a);
    ps_record_op("rra");
}

void    op_rrb(t_program *ps)
{
    reverse_rotate(&ps->b);
    ps_record_op("rrb");
}

void    op_rrr(t_program *ps)
{
    reverse_rotate(&ps->a);
    reverse_rotate(&ps->b);
    ps_record_op("rrr");
}
