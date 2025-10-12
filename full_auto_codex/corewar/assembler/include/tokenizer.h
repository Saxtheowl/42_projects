#ifndef TOKENIZER_H
#define TOKENIZER_H

#include "token.h"

int tokenize_file(const char *path, t_token_list *list, char **error_msg);

#endif
