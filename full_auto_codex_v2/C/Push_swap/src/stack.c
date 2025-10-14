#include "push_swap.h"

#include <stdlib.h>

void stack_init(t_stack *stack, char name)
{
    stack->top = NULL;
    stack->bottom = NULL;
    stack->size = 0;
    stack->name = name;
}

void stack_clear(t_stack *stack)
{
    t_node *cur;
    t_node *next;

    cur = stack->top;
    while (cur)
    {
        next = cur->next;
        free(cur);
        cur = next;
    }
    stack->top = NULL;
    stack->bottom = NULL;
    stack->size = 0;
}

static t_node *create_node(int value)
{
    t_node *node;

    node = (t_node *)malloc(sizeof(t_node));
    if (!node)
        return (NULL);
    node->value = value;
    node->next = NULL;
    node->prev = NULL;
    node->index = 0;
    return (node);
}

int stack_push_top(t_stack *stack, int value)
{
    t_node *node;

    node = create_node(value);
    if (!node)
        return (-1);
    stack_add_top_node(stack, node);
    return (0);
}

int stack_push_bottom(t_stack *stack, int value)
{
    t_node *node;

    node = create_node(value);
    if (!node)
        return (-1);
    stack_add_bottom_node(stack, node);
    return (0);
}

void stack_add_top_node(t_stack *stack, t_node *node)
{
    if (!node)
        return ;
    node->prev = NULL;
    node->next = stack->top;
    if (stack->top)
        stack->top->prev = node;
    stack->top = node;
    if (!stack->bottom)
        stack->bottom = node;
    stack->size++;
}

void stack_add_bottom_node(t_stack *stack, t_node *node)
{
    if (!node)
        return ;
    node->next = NULL;
    node->prev = stack->bottom;
    if (stack->bottom)
        stack->bottom->next = node;
    stack->bottom = node;
    if (!stack->top)
        stack->top = node;
    stack->size++;
}

t_node  *stack_take_top_node(t_stack *stack)
{
    t_node *node;

    if (stack->size == 0)
        return (NULL);
    node = stack->top;
    stack->top = node->next;
    if (stack->top)
        stack->top->prev = NULL;
    else
        stack->bottom = NULL;
    node->next = NULL;
    node->prev = NULL;
    stack->size--;
    return (node);
}

t_node  *stack_take_bottom_node(t_stack *stack)
{
    t_node *node;

    if (stack->size == 0)
        return (NULL);
    node = stack->bottom;
    stack->bottom = node->prev;
    if (stack->bottom)
        stack->bottom->next = NULL;
    else
        stack->top = NULL;
    node->next = NULL;
    node->prev = NULL;
    stack->size--;
    return (node);
}
int stack_is_sorted(const t_stack *stack)
{
    t_node *cur;

    if (!stack || stack->size <= 1)
        return (1);
    cur = stack->top;
    while (cur && cur->next)
    {
        if (cur->value > cur->next->value)
            return (0);
        cur = cur->next;
    }
    return (1);
}
