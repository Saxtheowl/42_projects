#include "tokenizer.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void usage(const char *prog)
{
    fprintf(stderr, "Usage: %s [options] file.s\n", prog);
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -o <file>         output file (ignored for now)\n");
    fprintf(stderr, "  --show-tokens     dump token stream\n");
}

static void print_tokens(const t_token_list *list)
{
    size_t i;
    for (i = 0; i < list->size; ++i)
    {
        const t_token *tok = &list->data[i];
        printf("[%4d:%3d] %-10s %s\n",
               tok->line,
               tok->column,
               token_type_name(tok->type),
               tok->text ? tok->text : "");
    }
}

int main(int argc, char **argv)
{
    const char *input = NULL;
    const char *output = NULL;
    int show_tokens = 0;
    int i;
    t_token_list tokens;
    char *error = NULL;

    for (i = 1; i < argc; ++i)
    {
        if (strcmp(argv[i], "--show-tokens") == 0)
        {
            show_tokens = 1;
        }
        else if (strcmp(argv[i], "-o") == 0)
        {
            if (i + 1 >= argc)
            {
                usage(argv[0]);
                return 1;
            }
            output = argv[++i];
        }
        else if (argv[i][0] == '-')
        {
            usage(argv[0]);
            return 1;
        }
        else if (input == NULL)
        {
            input = argv[i];
        }
        else
        {
            usage(argv[0]);
            return 1;
        }
    }
    if (!input)
    {
        usage(argv[0]);
        return 1;
    }
    (void)output;

    if (tokenize_file(input, &tokens, &error) != 0)
    {
        fprintf(stderr, "Error: %s\n", error ? error : "tokenization failed");
        free(error);
        return 1;
    }
    if (show_tokens)
        print_tokens(&tokens);
    else
        printf("%s: parsed %zu tokens. (Assembler backend not implemented yet)\n", input, tokens.size);
    token_list_free(&tokens);
    free(error);
    return 0;
}
