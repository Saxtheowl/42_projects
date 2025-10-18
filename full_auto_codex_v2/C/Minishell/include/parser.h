#ifndef PARSER_H
# define PARSER_H

# include "ast.h"
# include "token.h"
# include "minishell.h"

t_ast	*ms_parse(t_token *tokens, t_ms *ms);

#endif
