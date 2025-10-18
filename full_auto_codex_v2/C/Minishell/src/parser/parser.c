#include "parser.h"
#include "token.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct s_parser
{
	t_token	*current;
	t_ms	*ms;
	int		error;
}	t_parser;

static t_token_type	peek_type(t_parser *p)
{
	if (!p->current)
		return (-1);
	return (p->current->type);
}

static t_token	*consume(t_parser *p)
{
	t_token	*tok;

	tok = p->current;
	if (p->current)
		p->current = p->current->next;
	return (tok);
}

static void	parser_error(t_parser *p, const char *msg)
{
	if (!p->error)
	{
		fprintf(stderr, "minishell: syntax error: %s\n", msg);
		p->ms->last_status = 258;
		p->error = 1;
	}
}

static char	*strdup_safe(const char *s)
{
	char	*copy;

	copy = strdup(s ? s : "");
	return (copy);
}

static int	append_arg(char ***arr, size_t *count, const char *value)
{
	char	**tmp;

	tmp = realloc(*arr, sizeof(char *) * (*count + 2));
	if (!tmp)
		return (1);
	*arr = tmp;
	(*arr)[*count] = strdup_safe(value);
	if (!(*arr)[*count])
		return (1);
	(*count)++;
	(*arr)[*count] = NULL;
	return (0);
}

static int	append_redirect(t_redirect **list, t_redirect_type type,
		const char *target, int heredoc_expand)
{
	t_redirect	*node;
	t_redirect	*iter;

	node = malloc(sizeof(*node));
	if (!node)
		return (1);
	node->type = type;
	node->target = strdup_safe(target);
	if (!node->target)
	{
		free(node);
		return (1);
	}
	node->heredoc_expand = heredoc_expand;
	node->heredoc_data = NULL;
	node->next = NULL;
	if (!*list)
		*list = node;
	else
	{
		iter = *list;
		while (iter->next)
			iter = iter->next;
		iter->next = node;
	}
	return (0);
}

static t_redirect_type	token_to_redirect(t_token_type type)
{
	if (type == TOK_REDIR_IN)
		return (REDIR_INPUT);
	if (type == TOK_REDIR_OUT)
		return (REDIR_OUTPUT);
	if (type == TOK_REDIR_APPEND)
		return (REDIR_APPEND);
	return (REDIR_HEREDOC);
}

static t_ast	*parse_command(t_parser *p)
{
	char		**argv;
	size_t		count;
	t_redirect	*redir;
	t_token		*tok;
	t_ast		*node;

	argv = NULL;
	count = 0;
	redir = NULL;
	while (p->current && (peek_type(p) == TOK_WORD
			|| peek_type(p) == TOK_REDIR_IN
			|| peek_type(p) == TOK_REDIR_OUT
			|| peek_type(p) == TOK_REDIR_APPEND
			|| peek_type(p) == TOK_HEREDOC))
	{
		tok = consume(p);
		if (tok->type == TOK_WORD)
		{
			if (append_arg(&argv, &count, tok->value))
				goto error;
		}
	else
	{
		int heredoc_expand;

		if (!p->current || peek_type(p) != TOK_WORD)
		{
			parser_error(p, "redirection without target");
			goto error;
		}
		heredoc_expand = 1;
		if (tok->type == TOK_HEREDOC && p->current->quoted)
			heredoc_expand = 0;
		if (append_redirect(&redir, token_to_redirect(tok->type),
				p->current->value, heredoc_expand))
			goto error;
		consume(p);
	}
	}
	if (!argv && !redir)
	{
		parser_error(p, "expected command");
		goto error;
	}
	node = malloc(sizeof(*node));
	if (!node)
		goto error;
	node->type = AST_COMMAND;
	node->as.command.argv = argv;
	node->as.command.redirects = redir;
	return (node);
error:
	if (argv)
	{
		while (count > 0)
			free(argv[--count]);
		free(argv);
	}
	if (redir)
	{
		t_redirect	*tmp;

		while (redir)
		{
			tmp = redir->next;
			free(redir->target);
			free(redir);
			redir = tmp;
		}
	}
	return (NULL);
}

static t_ast	*parse_pipeline(t_parser *p)
{
	t_ast	*left;
	t_ast	*right;
	t_ast	*node;

	left = parse_command(p);
	if (!left)
		return (NULL);
	while (peek_type(p) == TOK_PIPE)
	{
		consume(p);
		right = parse_command(p);
		if (!right)
		{
			ast_free(left);
			return (NULL);
		}
		node = malloc(sizeof(*node));
		if (!node)
		{
			ast_free(left);
			ast_free(right);
			return (NULL);
		}
		node->type = AST_PIPELINE;
		node->as.pipeline.left = left;
		node->as.pipeline.right = right;
		left = node;
	}
	return (left);
}

t_ast	*ms_parse(t_token *tokens, t_ms *ms)
{
	t_parser	parser;
	t_ast		*ast;

	parser.current = tokens;
	parser.ms = ms;
	parser.error = 0;
	ast = parse_pipeline(&parser);
	if (!ast)
		return (NULL);
	if (parser.current != NULL)
	{
		parser_error(&parser, "unexpected token");
		ast_free(ast);
		return (NULL);
	}
	return (ast);
}
