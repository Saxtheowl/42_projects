#include "tokenizer.h"

#include <ctype.h>
#include <stdio.h>
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

static int push_token(t_token_list *list, t_token_type type, const char *text, int line, int column)
{
    t_token token;

    token.type = type;
    token.text = text ? xstrdup(text) : NULL;
    token.line = line;
    token.column = column;
    token_list_push(list, token);
    return 0;
}

static int read_line(FILE *fp, char **buffer, size_t *capacity, size_t *length)
{
    int ch;
    size_t len = 0;

    if (*buffer == NULL)
    {
        *capacity = 128;
        *buffer = (char *)malloc(*capacity);
        if (!*buffer)
            return 0;
    }
    while ((ch = fgetc(fp)) != EOF)
    {
        if (len + 1 >= *capacity)
        {
            size_t new_capacity = *capacity * 2;
            char *tmp = (char *)realloc(*buffer, new_capacity);
            if (!tmp)
                return 0;
            *buffer = tmp;
            *capacity = new_capacity;
        }
        (*buffer)[len++] = (char)ch;
        if (ch == '\n')
            break;
    }
    if (len == 0 && ch == EOF)
        return 0;
    (*buffer)[len] = '\0';
    *length = len;
    return 1;
}

static int is_identifier_char(int c)
{
    return (isalnum(c) || c == '_' || c == '.');
}

static int is_number_char(int c)
{
    return (isdigit(c) || c == 'x' || c == 'X');
}

static int tokenize_line(const char *line, t_token_list *list, int line_no, char **error_msg)
{
    int col = 1;
    const char *p = line;

    while (*p)
    {
        if (*p == '\n')
        {
            push_token(list, TOK_NEWLINE, NULL, line_no, col);
            return 0;
        }
        if (*p == ';' || *p == '#')
            return push_token(list, TOK_NEWLINE, NULL, line_no, col);
        if (isspace((unsigned char)*p))
        {
            ++p;
            ++col;
            continue;
        }
        if (*p == '"')
        {
            const char *start = ++p;
            int start_col = col;
            while (*p && *p != '"')
            {
                if (*p == '\\' && p[1] != '\0')
                    ++p;
                ++p;
            }
            if (*p != '"')
            {
                if (error_msg)
                {
                    *error_msg = xstrdup("Unterminated string literal");
                }
                return -1;
            }
            size_t len = (size_t)(p - start);
            char *text = (char *)malloc(len + 1);
            if (!text)
                return -1;
            memcpy(text, start, len);
            text[len] = '\0';
            push_token(list, TOK_STRING, text, line_no, start_col);
            free(text);
            ++p; ++col;
            continue;
        }
        if (*p == '%')
        {
            push_token(list, TOK_PERCENT, "%", line_no, col);
            ++p; ++col;
            continue;
        }
        if (*p == ',')
        {
            push_token(list, TOK_SEPARATOR, ",", line_no, col);
            ++p; ++col;
            continue;
        }
        if (*p == ':' )
        {
            push_token(list, TOK_SEPARATOR, ":", line_no, col);
            ++p; ++col;
            continue;
        }
        if (*p == '-' || isdigit((unsigned char)*p))
        {
            const char *start = p;
            int start_col = col;
            if (*p == '-')
            {
                ++p; ++col;
            }
            while (is_number_char((unsigned char)*p))
            {
                ++p; ++col;
            }
            size_t len = (size_t)(p - start);
            char *text = (char *)malloc(len + 1);
            if (!text)
                return -1;
            memcpy(text, start, len);
            text[len] = '\0';
            push_token(list, TOK_NUMBER, text, line_no, start_col);
            free(text);
            continue;
        }
        if (isalpha((unsigned char)*p) || *p == '.' || *p == '_')
        {
            const char *start = p;
            int start_col = col;
            while (is_identifier_char((unsigned char)*p))
            {
                ++p; ++col;
            }
            size_t len = (size_t)(p - start);
            char *text = (char *)malloc(len + 1);
            if (!text)
                return -1;
            memcpy(text, start, len);
            text[len] = '\0';
            if (*p == ':')
            {
                push_token(list, TOK_LABEL, text, line_no, start_col);
                ++p; ++col;
            }
            else if (text[0] == '.')
            {
                push_token(list, TOK_DIRECTIVE, text, line_no, start_col);
            }
            else
            {
                push_token(list, TOK_IDENTIFIER, text, line_no, start_col);
            }
            free(text);
            continue;
        }
        if (error_msg)
            *error_msg = xstrdup("Unexpected character");
        return -1;
    }
    push_token(list, TOK_NEWLINE, NULL, line_no, col);
    return 0;
}

int tokenize_file(const char *path, t_token_list *list, char **error_msg)
{
    FILE *fp;
    char *line = NULL;
    size_t capacity = 0;
    size_t len;
    int line_no = 1;

    token_list_init(list);
    fp = fopen(path, "r");
    if (!fp)
    {
        if (error_msg)
        {
            size_t msg_len = strlen(path) + 32;
            *error_msg = (char *)malloc(msg_len);
            if (*error_msg)
                snprintf(*error_msg, msg_len, "Cannot open file: %s", path);
        }
        return -1;
    }
    while (read_line(fp, &line, &capacity, &len))
    {
        if (tokenize_line(line, list, line_no, error_msg) != 0)
        {
            fclose(fp);
            free(line);
            return -1;
        }
        ++line_no;
    }
    fclose(fp);
    free(line);
    push_token(list, TOK_EOF, NULL, line_no, 1);
    return 0;
}
