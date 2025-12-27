#ifndef PIPEX_H
#define PIPEX_H

#include <stddef.h>

# define PX_SUCCESS 0
# define PX_FAILURE 1

typedef struct s_cmd
{
    char    **argv;
    char    *path;
}   t_cmd;

typedef struct s_pipex
{
    int     here_doc;
    char    *limiter;
    char    *infile;
    char    *outfile;
    t_cmd   *cmds;
    int     cmd_count;
    char    **envp;
}   t_pipex;

size_t  px_strlen(const char *s);
char    *px_strdup(const char *s);
char    *px_strjoin(const char *s1, const char *s2);
char    *px_substr(const char *s, size_t start, size_t len);
int     px_strncmp(const char *s1, const char *s2, size_t n);
char    **px_split_cmd(const char *cmd);
void    px_free_split(char **split);
char    *px_find_command(char **paths, const char *cmd);
char    **px_split_path(const char *path);

void    px_perror(const char *context);
void    px_cleanup(t_pipex *px);

#endif
