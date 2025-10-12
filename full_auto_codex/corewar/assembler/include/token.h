#ifndef TOKEN_H
#define TOKEN_H

#include <stddef.h>

typedef enum e_token_type
{
    TOK_DIRECTIVE,
    TOK_IDENTIFIER,
    TOK_LABEL,
    TOK_NUMBER,
    TOK_STRING,
    TOK_SEPARATOR,
    TOK_COLON,
    TOK_PERCENT,
    TOK_NEWLINE,
    TOK_EOF
}   t_token_type;

typedef struct s_token
{
    t_token_type   type;
    char           *text;
    int             line;
    int             column;
}   t_token;

typedef struct s_token_list
{
    t_token *data;
    size_t   size;
    size_t   capacity;
}   t_token_list;

void        token_list_init(t_token_list *list);
void        token_list_push(t_token_list *list, t_token token);
void        token_list_free(t_token_list *list);
const char *token_type_name(t_token_type type);

#endif
