#ifndef FT_STRACE_H
#define FT_STRACE_H

#include <sys/types.h>

#define STRACE_MAX_ARGS 6

typedef struct s_trace_config
{
    int is_64bit;
}   t_trace_config;

int     detect_target_binary(const char *path, t_trace_config *cfg);
int     run_strace(char *const argv[], char *const envp[], const t_trace_config *cfg);

#endif
