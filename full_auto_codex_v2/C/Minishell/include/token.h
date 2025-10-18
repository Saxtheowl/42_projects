#ifndef TOKEN_H
# define TOKEN_H

# include <stddef.h>

typedef enum e_token_type
{
	TOK_WORD,
	TOK_PIPE,
	TOK_REDIR_IN,
	TOK_REDIR_OUT,
	TOK_REDIR_APPEND,
	TOK_HEREDOC
}	t_token_type;

typedef struct s_token
{
	t_token_type		type;
	char				*value;
	int					quoted;
	struct s_token		*next;
}	t_token;

t_token	*token_new(t_token_type type, const char *value, int quoted);
void		token_append(t_token **list, t_token *node);
void		token_clear(t_token **list);
size_t		token_count(const t_token *list);

#endif
