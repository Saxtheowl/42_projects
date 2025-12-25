#pragma once

#include "ast.h"

typedef enum e_token_type
{
	TK_SYMBOL,
	TK_NOT,
	TK_AND,
	TK_OR,
	TK_XOR,
	TK_LPAREN,
	TK_RPAREN,
	TK_IMPLIES,
	TK_BICOND,
	TK_END,
	TK_INVALID
}	t_token_type;

typedef struct s_token
{
	t_token_type	type;
	char			value;
}	t_token;

int		parse_expression(const char *line, t_ast **out_ast);
int		parse_rule(const char *line, t_ast **premise, t_ast **conclusion, int *is_bicond);
