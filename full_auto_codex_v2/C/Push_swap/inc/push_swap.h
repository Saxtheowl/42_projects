#ifndef PUSH_SWAP_H
#define PUSH_SWAP_H

#include <stddef.h>

typedef struct s_node
{
    int             value;
    int             index;
    struct s_node   *next;
    struct s_node   *prev;
}   t_node;

typedef struct s_stack
{
    t_node  *top;
    t_node  *bottom;
    size_t  size;
    char    name;
}   t_stack;

typedef struct s_program
{
    t_stack a;
    t_stack b;
}   t_program;

/* parsing */
int     ps_parse_args(t_program *ps, int argc, char **argv);

/* stack */
void    stack_init(t_stack *stack, char name);
void    stack_clear(t_stack *stack);
int     stack_push_top(t_stack *stack, int value);
int     stack_push_bottom(t_stack *stack, int value);
void    stack_add_top_node(t_stack *stack, t_node *node);
void    stack_add_bottom_node(t_stack *stack, t_node *node);
t_node  *stack_take_top_node(t_stack *stack);
t_node  *stack_take_bottom_node(t_stack *stack);
int     stack_is_sorted(const t_stack *stack);

/* utils */
size_t  ps_strlen(const char *s);
char    *ps_strdup(const char *s);
char    **ps_split(const char *s);
void    ps_free_split(char **split);
long    ps_atol(const char *s, int *ok);
int     ps_strcmp(const char *s1, const char *s2);
void    ps_putstr_fd(const char *s, int fd);

/* operations (to be implemented later) */
void    op_sa(t_program *ps);
void    op_sb(t_program *ps);
void    op_ss(t_program *ps);
void    op_pa(t_program *ps);
void    op_pb(t_program *ps);
void    op_ra(t_program *ps);
void    op_rb(t_program *ps);
void    op_rr(t_program *ps);
void    op_rra(t_program *ps);
void    op_rrb(t_program *ps);
void    op_rrr(t_program *ps);

void    ps_record_op(const char *op);

/* cleanup */
void    ps_cleanup(t_program *ps);

/* sorting */
void    run_algorithm(t_program *ps);

#endif
