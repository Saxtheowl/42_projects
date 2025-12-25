#pragma once

typedef enum e_node_type
{
	NODE_SYMBOL,
	NODE_NOT,
	NODE_AND,
	NODE_OR,
	NODE_XOR
}	t_node_type;

typedef struct s_ast
{
	t_node_type	type;
	char			symbol; /* valid if type == NODE_SYMBOL */
	struct s_ast	*left;
	struct s_ast	*right;
}	t_ast;

t_ast	*ast_new_symbol(char c);
t_ast	*ast_new_unary(t_node_type type, t_ast *child);
t_ast	*ast_new_binary(t_node_type type, t_ast *left, t_ast *right);
t_ast	*ast_clone(const t_ast *node);
int		ast_contains_symbol(const t_ast *node, char symbol);
void	ast_print(const t_ast *node);
void	ast_free(t_ast *node);
