#include "push_swap.h"

#include <limits.h>
#include <stdlib.h>

static int  cmp_int(const void *a, const void *b)
{
    int ia = *(const int *)a;
    int ib = *(const int *)b;
    if (ia < ib)
        return (-1);
    if (ia > ib)
        return (1);
    return (0);
}

static int *stack_to_array(const t_stack *stack)
{
    int     *arr;
    size_t  i;
    t_node  *cur;

    arr = (int *)malloc(sizeof(int) * stack->size);
    if (!arr)
        return (NULL);
    cur = stack->top;
    i = 0;
    while (cur)
    {
        arr[i++] = cur->value;
        cur = cur->next;
    }
    return (arr);
}

static void assign_indices(t_stack *stack)
{
    int     *values;
    int     *sorted;
    size_t  size;
    t_node  *cur;

    size = stack->size;
    values = stack_to_array(stack);
    if (!values)
        return ;
    sorted = (int *)malloc(sizeof(int) * size);
    if (!sorted)
    {
        free(values);
        return ;
    }
    for (size_t i = 0; i < size; ++i)
        sorted[i] = values[i];
    qsort(sorted, size, sizeof(int), cmp_int);
    cur = stack->top;
    while (cur)
    {
        for (size_t i = 0; i < size; ++i)
        {
            if (sorted[i] == cur->value)
            {
                cur->index = (int)i;
                break;
            }
        }
        cur = cur->next;
    }
    free(values);
    free(sorted);
}

static void sort_three(t_program *ps)
{
    int a = ps->a.top->index;
    int b = ps->a.top->next->index;
    int c = ps->a.top->next->next->index;

    if (a < b && b < c)
        return ;
    if (a > b && a < c)
        op_sa(ps);
    else if (a > b && b > c)
    {
        op_sa(ps);
        op_rra(ps);
    }
    else if (a > b && a > c && b < c)
    {
        op_ra(ps);
    }
    else if (a < b && a < c && b > c)
    {
        op_sa(ps);
        op_ra(ps);
    }
    else if (a < b && a > c)
    {
        op_rra(ps);
    }
}

static size_t find_min_position(t_stack *stack)
{
    t_node  *cur;
    int     min_index;
    size_t  min_pos;
    size_t  pos;

    cur = stack->top;
    min_index = INT_MAX;
    min_pos = 0;
    pos = 0;
    while (cur)
    {
        if (cur->index < min_index)
        {
            min_index = cur->index;
            min_pos = pos;
        }
        cur = cur->next;
        pos++;
    }
    return (min_pos);
}

static void push_min_to_b(t_program *ps)
{
    size_t pos;
    size_t size;

    pos = find_min_position(&ps->a);
    size = ps->a.size;
    if (pos <= size / 2)
        while (pos-- > 0)
            op_ra(ps);
    else
    {
        size_t count = size - pos;
        while (count-- > 0)
            op_rra(ps);
    }
    op_pb(ps);
}

static void sort_small(t_program *ps)
{
    if (ps->a.size == 2 && ps->a.top->index > ps->a.top->next->index)
        op_sa(ps);
    else if (ps->a.size == 3)
        sort_three(ps);
    else if (ps->a.size <= 5)
    {
        while (ps->a.size > 3)
            push_min_to_b(ps);
        sort_three(ps);
        while (ps->b.size)
            op_pa(ps);
    }
}

static void radix_sort(t_program *ps)
{
    size_t  max_bits;
    size_t  size;
    size_t  i;
    size_t  j;
    int     max_index;

    max_index = (int)(ps->a.size - 1);
    max_bits = 0;
    while ((max_index >> max_bits) != 0)
        max_bits++;
    for (i = 0; i < max_bits; ++i)
    {
        size = ps->a.size;
        j = 0;
        while (j++ < size)
        {
            if (((ps->a.top->index >> i) & 1) == 0)
                op_pb(ps);
            else
                op_ra(ps);
        }
        while (ps->b.size)
            op_pa(ps);
    }
}

void    run_algorithm(t_program *ps)
{
    assign_indices(&ps->a);
    if (stack_is_sorted(&ps->a))
        return ;
    if (ps->a.size <= 5)
    {
        sort_small(ps);
        return ;
    }
    radix_sort(ps);
}
