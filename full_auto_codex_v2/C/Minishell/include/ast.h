#ifndef AST_H
# define AST_H

# include <stddef.h>

typedef enum e_redirect_type
{
	REDIR_INPUT,
	REDIR_OUTPUT,
	REDIR_APPEND,
	REDIR_HEREDOC
}	t_redirect_type;

typedef struct s_redirect
{
	t_redirect_type		type;
	char				*target;
	int					heredoc_expand;
	struct s_redirect	*next;
}	t_redirect;

typedef struct s_command
{
	char		**argv;
	t_redirect	*redirects;
}	t_command;

typedef enum e_ast_type
{
	AST_COMMAND,
	AST_PIPELINE
}	t_ast_type;

typedef struct s_ast
{
	t_ast_type		type;
	union
	{
		t_command	command;
		struct
		{
			struct s_ast	*left;
			struct s_ast	*right;
		}	pipeline;
	}	as;
}	t_ast;

void	ast_free(t_ast *node);

#endif
