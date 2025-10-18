#ifndef LEXER_H
# define LEXER_H

# include "minishell.h"
# include "token.h"

t_token	*ms_lex_line(const char *line, t_ms *ms);

#endif
