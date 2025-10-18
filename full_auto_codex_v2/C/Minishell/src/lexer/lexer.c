#include "lexer.h"
#include "env.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct s_builder
{
	char	*data;
	size_t	len;
	size_t	cap;
	int		had_quotes;
}	t_builder;

typedef struct s_lexer
{
	const char	*line;
	size_t		pos;
	t_ms		*ms;
	int			error;
}	t_lexer;

static int	builder_reserve(t_builder *b, size_t needed)
{
	char	*tmp;
	size_t	new_cap;

	if (b->len + needed + 1 <= b->cap)
		return (0);
	new_cap = b->cap ? b->cap * 2 : 32;
	while (new_cap < b->len + needed + 1)
		new_cap *= 2;
	tmp = realloc(b->data, new_cap);
	if (!tmp)
		return (1);
	b->data = tmp;
	b->cap = new_cap;
	return (0);
}

static int	builder_append_char(t_builder *b, char c)
{
	if (builder_reserve(b, 1))
		return (1);
	b->data[b->len++] = c;
	b->data[b->len] = '\0';
	return (0);
}

static int	builder_append_str(t_builder *b, const char *s)
{
	size_t	len;

	if (!s)
		return (0);
	len = strlen(s);
	if (builder_reserve(b, len))
		return (1);
	memcpy(b->data + b->len, s, len);
	b->len += len;
	b->data[b->len] = '\0';
	return (0);
}

static char	current_char(t_lexer *lx)
{
	return (lx->line[lx->pos]);
}

static char	peek_char(t_lexer *lx, size_t offset)
{
	return (lx->line[lx->pos + offset]);
}

static void	advance(t_lexer *lx, size_t count)
{
	lx->pos += count;
}

static int	is_operator_char(char c)
{
	return (c == '|' || c == '<' || c == '>');
}

static char	*builder_extract(t_builder *b)
{
	return (b->data);
}

static int	is_name_start(char c)
{
	return (isalpha((unsigned char)c) || c == '_');
}

static int	is_name_char(char c)
{
	return (isalnum((unsigned char)c) || c == '_');
}

static int	append_exit_status(t_builder *b, t_ms *ms)
{
	char	buffer[12];

	snprintf(buffer, sizeof(buffer), "%d", ms->last_status);
	return (builder_append_str(b, buffer));
}

static int	append_variable(t_builder *b, t_ms *ms, t_lexer *lx)
{
	size_t	start;
	size_t	len;
	char	*name;
	const char	*value;

	if (!is_name_start(current_char(lx)))
		return (builder_append_char(b, '$'));
	start = lx->pos;
	while (current_char(lx) && is_name_char(current_char(lx)))
		advance(lx, 1);
	len = lx->pos - start;
	name = malloc(len + 1);
	if (!name)
		return (1);
	memcpy(name, lx->line + start, len);
	name[len] = '\0';
	value = ms_env_get(ms, name);
	free(name);
	return (builder_append_str(b, value ? value : ""));
}

static int	handle_dollar(t_builder *b, t_ms *ms, t_lexer *lx)
{
	char	next;

	advance(lx, 1);
	next = current_char(lx);
	if (next == '?')
	{
		advance(lx, 1);
		return (append_exit_status(b, ms));
	}
	if (next == '\0')
		return (builder_append_char(b, '$'));
	return (append_variable(b, ms, lx));
}

static int	parse_single_quote(t_builder *b, t_lexer *lx)
{
	b->had_quotes = 1;
	advance(lx, 1);
	while (current_char(lx) && current_char(lx) != '\'')
	{
		if (builder_append_char(b, current_char(lx)))
			return (1);
		advance(lx, 1);
	}
	if (current_char(lx) != '\'')
		return (1);
	advance(lx, 1);
	return (0);
}

static int	parse_double_quote(t_builder *b, t_lexer *lx, t_ms *ms)
{
	b->had_quotes = 1;
	advance(lx, 1);
	while (current_char(lx) && current_char(lx) != '"')
	{
		if (current_char(lx) == '$')
		{
			if (handle_dollar(b, ms, lx))
				return (1);
			continue ;
		}
		if (builder_append_char(b, current_char(lx)))
			return (1);
		advance(lx, 1);
	}
	if (current_char(lx) != '"')
		return (1);
	advance(lx, 1);
	return (0);
}

static int	parse_word(t_lexer *lx, t_builder *b)
{
	if (builder_reserve(b, 0))
		return (1);
	while (current_char(lx))
	{
		if (isspace((unsigned char)current_char(lx)) || is_operator_char(current_char(lx)))
			break ;
		if (current_char(lx) == '\'')
		{
			if (parse_single_quote(b, lx))
				return (1);
			continue ;
		}
		if (current_char(lx) == '"')
		{
			if (parse_double_quote(b, lx, lx->ms))
				return (1);
			continue ;
		}
		if (current_char(lx) == '$')
		{
			if (handle_dollar(b, lx->ms, lx))
				return (1);
			continue ;
		}
		if (builder_append_char(b, current_char(lx)))
			return (1);
		advance(lx, 1);
	}
	return (0);
}

static int	emit_operator(t_lexer *lx, t_token **out)
{
	t_token_type	type;
	t_token			*node;
	char			c;

	c = current_char(lx);
	if (c == '|')
	{
		type = TOK_PIPE;
		advance(lx, 1);
	}
	else if (c == '<')
	{
		if (peek_char(lx, 1) == '<')
		{
			type = TOK_HEREDOC;
			advance(lx, 2);
		}
		else
		{
			type = TOK_REDIR_IN;
			advance(lx, 1);
		}
	}
	else
	{
		if (peek_char(lx, 1) == '>')
		{
			type = TOK_REDIR_APPEND;
			advance(lx, 2);
		}
		else
		{
			type = TOK_REDIR_OUT;
			advance(lx, 1);
		}
	}
	node = token_new(type, NULL, 0);
	if (!node)
		return (1);
	token_append(out, node);
	return (0);
}

static int	emit_word(t_lexer *lx, t_token **out)
{
	t_builder	b;
	char		*word;
	t_token		*node;

	memset(&b, 0, sizeof(b));
	if (parse_word(lx, &b))
 	{
		free(b.data);
		return (1);
	}
	if (!b.data)
		return (1);
	word = builder_extract(&b);
	node = token_new(TOK_WORD, word, b.had_quotes);
	free(word);
	if (!node)
		return (1);
	token_append(out, node);
	return (0);
}

static void	report_unclosed_quote(t_ms *ms)
{
	fprintf(stderr, "minishell: syntax error: unclosed quote\n");
	ms->last_status = 258;
}

t_token	*ms_lex_line(const char *line, t_ms *ms)
{
	t_lexer	lx;
	t_token	*tokens;

	if (!line)
		return (NULL);
	memset(&lx, 0, sizeof(lx));
	lx.line = line;
	lx.ms = ms;
	tokens = NULL;
	while (current_char(&lx))
	{
		if (isspace((unsigned char)current_char(&lx)))
		{
			advance(&lx, 1);
			continue ;
		}
		if (is_operator_char(current_char(&lx)))
		{
			if (emit_operator(&lx, &tokens))
				goto error;
			continue ;
		}
		if (emit_word(&lx, &tokens))
		{
			report_unclosed_quote(ms);
			goto error;
		}
	}
	return (tokens);
error:
	token_clear(&tokens);
	return (NULL);
}
