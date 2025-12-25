#include "parser.h"
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

typedef struct s_stack
{
	t_ast	**data;
	int		size;
	int		cap;
}	t_stack;

static int	push(t_stack *s, t_ast *n)
{
	if (s->size == s->cap)
	{
		int new_cap = s->cap == 0 ? 8 : s->cap * 2;
		t_ast **tmp = realloc(s->data, new_cap * sizeof(t_ast *));
		if (!tmp)
			return 0;
		s->data = tmp;
		s->cap = new_cap;
	}
	s->data[s->size++] = n;
	return 1;
}

static t_ast	*pop(t_stack *s)
{
	if (s->size == 0)
		return NULL;
	return s->data[--s->size];
}

static int	precedence(t_token_type t)
{
	if (t == TK_NOT)
		return 4;
	if (t == TK_AND)
		return 3;
	if (t == TK_OR)
		return 2;
	if (t == TK_XOR)
		return 1;
	return 0;
}

static int	is_right_assoc(t_token_type t)
{
	return t == TK_NOT;
}

static char	*my_strndup(const char *s, size_t n)
{
	char *out = malloc(n + 1);
	if (!out)
		return NULL;
	memcpy(out, s, n);
	out[n] = '\0';
	return out;
}

static char	*my_strdup(const char *s)
{
	size_t len = strlen(s);
	return my_strndup(s, len);
}

static t_token	next_token(const char **p)
{
	while (isspace((unsigned char)**p))
		(*p)++;
	if (**p == '\0')
		return (t_token){TK_END, 0};
	if (**p == '#')
		return (t_token){TK_END, 0};
	if (**p == '!')
	{
		(*p)++;
		return (t_token){TK_NOT, 0};
	}
	if (**p == '+')
	{
		(*p)++;
		return (t_token){TK_AND, 0};
	}
	if (**p == '|')
	{
		(*p)++;
		return (t_token){TK_OR, 0};
	}
	if (**p == '^')
	{
		(*p)++;
		return (t_token){TK_XOR, 0};
	}
	if (**p == '(')
		return (t_token){TK_LPAREN, *(*p)++};
	if (**p == ')')
		return (t_token){TK_RPAREN, *(*p)++};
	if (**p == '=' && *(*p + 1) == '>')
	{
		*p += 2;
		return (t_token){TK_IMPLIES, 0};
	}
	if (**p == '<' && *(*p + 1) == '=' && *(*p + 2) == '>')
	{
		*p += 3;
		return (t_token){TK_BICOND, 0};
	}
	if (isupper((unsigned char)**p))
	{
		char c = *(*p)++;
		return (t_token){TK_SYMBOL, c};
	}
	return (t_token){TK_INVALID, 0};
}

static int	build_op(t_stack *out, t_token_type op)
{
	if (op == TK_NOT)
	{
		t_ast *a = pop(out);
		if (!a)
			return 0;
		return push(out, ast_new_unary(NODE_NOT, a));
	}
	t_ast *r = pop(out);
	t_ast *l = pop(out);
	if (!l || !r)
		return 0;
	t_node_type t = (op == TK_AND) ? NODE_AND : (op == TK_OR) ? NODE_OR : NODE_XOR;
	return push(out, ast_new_binary(t, l, r));
}

int	parse_expression(const char *line, t_ast **out_ast)
{
	const char *p = line;
	t_token tok;
	t_token opstack[128];
	int op_top = 0;
	t_stack out = {0};
	while ((tok = next_token(&p)).type != TK_END)
	{
		if (tok.type == TK_INVALID)
			return 0;
		if (tok.type == TK_SYMBOL)
		{
			if (!push(&out, ast_new_symbol(tok.value)))
				return 0;
		}
		else if (tok.type == TK_NOT || tok.type == TK_AND || tok.type == TK_OR || tok.type == TK_XOR)
		{
			while (op_top > 0)
			{
				t_token_type top = opstack[op_top - 1].type;
				if (top == TK_LPAREN)
					break;
				if ((precedence(top) > precedence(tok.type)) ||
					(precedence(top) == precedence(tok.type) && !is_right_assoc(tok.type)))
				{
					op_top--;
					if (!build_op(&out, top))
						return 0;
				}
				else
					break;
			}
			opstack[op_top++] = tok;
		}
		else if (tok.type == TK_LPAREN)
			opstack[op_top++] = tok;
		else if (tok.type == TK_RPAREN)
		{
			int matched = 0;
			while (op_top > 0)
			{
				t_token_type top = opstack[--op_top].type;
				if (top == TK_LPAREN)
				{
					matched = 1;
					break;
				}
				if (!build_op(&out, top))
					return 0;
			}
			if (!matched)
				return 0;
		}
		else if (tok.type == TK_IMPLIES || tok.type == TK_BICOND)
		{
			/* stop at arrow, handled by caller */
			break;
		}
	}
	while (op_top > 0)
	{
		t_token_type top = opstack[--op_top].type;
		if (top == TK_LPAREN || top == TK_RPAREN)
			return 0;
		if (!build_op(&out, top))
			return 0;
	}
	if (out.size != 1)
		return 0;
	*out_ast = pop(&out);
	free(out.data);
	return 1;
}

int	parse_rule(const char *line, t_ast **premise, t_ast **conclusion, int *is_bicond)
{
	const char *arrow = strstr(line, "<=>");
	*is_bicond = 0;
	if (arrow)
	{
		*is_bicond = 1;
	}
	else
		arrow = strstr(line, "=>");
	if (!arrow)
		return 0;
	size_t prem_len = arrow - line;
	char *lhs = my_strndup(line, prem_len);
	char *rhs = my_strdup(arrow + (*is_bicond ? 3 : 2));
	if (!lhs || !rhs)
	{
		free(lhs);
		free(rhs);
		return 0;
	}
	int ok = parse_expression(lhs, premise) && parse_expression(rhs, conclusion);
	free(lhs);
	free(rhs);
	return ok;
}
