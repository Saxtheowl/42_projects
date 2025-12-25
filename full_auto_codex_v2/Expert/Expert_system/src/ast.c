#include "ast.h"
#include <stdlib.h>
#include <stdio.h>

t_ast	*ast_new_symbol(char c)
{
	t_ast *n = malloc(sizeof(t_ast));
	if (!n)
		return NULL;
	n->type = NODE_SYMBOL;
	n->symbol = c;
	n->left = NULL;
	n->right = NULL;
	return n;
}

t_ast	*ast_new_unary(t_node_type type, t_ast *child)
{
	t_ast *n = malloc(sizeof(t_ast));
	if (!n)
		return NULL;
	n->type = type;
	n->symbol = 0;
	n->left = child;
	n->right = NULL;
	return n;
}

t_ast	*ast_new_binary(t_node_type type, t_ast *left, t_ast *right)
{
	t_ast *n = malloc(sizeof(t_ast));
	if (!n)
		return NULL;
	n->type = type;
	n->symbol = 0;
	n->left = left;
	n->right = right;
	return n;
}

void	ast_free(t_ast *node)
{
	if (!node)
		return;
	ast_free(node->left);
	ast_free(node->right);
	free(node);
}

static t_ast	*dup_node(const t_ast *node)
{
	if (!node)
		return NULL;
	if (node->type == NODE_SYMBOL)
		return ast_new_symbol(node->symbol);
	if (node->right)
		return ast_new_binary(node->type, dup_node(node->left), dup_node(node->right));
	return ast_new_unary(node->type, dup_node(node->left));
}

t_ast	*ast_clone(const t_ast *node)
{
	return dup_node(node);
}

int	ast_contains_symbol(const t_ast *node, char symbol)
{
	if (!node)
		return 0;
	if (node->type == NODE_SYMBOL)
		return node->symbol == symbol;
	return ast_contains_symbol(node->left, symbol) || ast_contains_symbol(node->right, symbol);
}

void	ast_print(const t_ast *node)
{
	if (!node)
		return;
	if (node->type == NODE_SYMBOL)
	{
		printf("%c", node->symbol);
		return;
	}
	if (node->type == NODE_NOT)
	{
		printf("!");
		ast_print(node->left);
		return;
	}
	printf("(");
	ast_print(node->left);
	if (node->type == NODE_AND)
		printf(" + ");
	else if (node->type == NODE_OR)
		printf(" | ");
	else if (node->type == NODE_XOR)
		printf(" ^ ");
	ast_print(node->right);
	printf(")");
}
