#include "push_swap.h"

static void stack_swap(t_stack *stack)
{
    t_node *first;
    t_node *second;

    if (!stack || stack->size < 2)
        return ;
    first = stack->top;
    second = first->next;
    first->next = second->next;
    if (second->next)
        second->next->prev = first;
    else
        stack->bottom = first;
    second->prev = NULL;
    second->next = first;
    first->prev = second;
    stack->top = second;
}

void    op_sa(t_program *ps)
{
    stack_swap(&ps->a);
    ps_record_op("sa");
}

void    op_sb(t_program *ps)
{
    stack_swap(&ps->b);
    ps_record_op("sb");
}

void    op_ss(t_program *ps)
{
    stack_swap(&ps->a);
    stack_swap(&ps->b);
    ps_record_op("ss");
}
