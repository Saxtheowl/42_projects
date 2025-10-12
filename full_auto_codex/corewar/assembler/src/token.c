#include "token.h"

#include <stdlib.h>
#include <string.h>

static char *xstrdup(const char *s)
{
    size_t len = strlen(s);
    char *copy = (char *)malloc(len + 1);
    if (!copy)
        return NULL;
    memcpy(copy, s, len + 1);
    return copy;
}

void token_list_init(t_token_list *list)
{
    list->data = NULL;
    list->size = 0;
    list->capacity = 0;
}

void token_list_push(t_token_list *list, t_token token)
{
    if (list->size + 1 > list->capacity)
    {
        size_t new_capacity = (list->capacity == 0) ? 16 : list->capacity * 2;
        t_token *new_data = (t_token *)realloc(list->data, new_capacity * sizeof(t_token));
        if (!new_data)
            return;
        list->data = new_data;
        list->capacity = new_capacity;
    }
    if (token.text)
        token.text = xstrdup(token.text);
    list->data[list->size++] = token;
}

void token_list_free(t_token_list *list)
{
    size_t i;

    for (i = 0; i < list->size; ++i)
        free(list->data[i].text);
    free(list->data);
    list->data = NULL;
    list->size = 0;
    list->capacity = 0;
}

const char *token_type_name(t_token_type type)
{
    static const char *names[] = {
        "DIRECTIVE",
        "IDENT",
        "LABEL",
        "NUMBER",
        "STRING",
        "SEPARATOR",
        "PERCENT",
        "NEWLINE",
        "EOF"
    };
    if (type < 0 || type > TOK_EOF)
        return "UNKNOWN";
    return names[type];
}
