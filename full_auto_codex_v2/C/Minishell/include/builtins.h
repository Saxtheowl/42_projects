#ifndef BUILTINS_H
# define BUILTINS_H

# include "ast.h"
# include "minishell.h"

typedef int	(*t_builtin_fn)(t_ms *ms, t_command *cmd, int in_child);

t_builtin_fn	ms_builtin_get(const char *name);

/* Exposed for tests */
int				ms_builtin_echo(t_ms *ms, t_command *cmd, int in_child);
int				ms_builtin_pwd(t_ms *ms, t_command *cmd, int in_child);
int				ms_builtin_env(t_ms *ms, t_command *cmd, int in_child);
int				ms_builtin_exit(t_ms *ms, t_command *cmd, int in_child);
int				ms_builtin_export(t_ms *ms, t_command *cmd, int in_child);
int				ms_builtin_unset(t_ms *ms, t_command *cmd, int in_child);
int				ms_builtin_cd(t_ms *ms, t_command *cmd, int in_child);

#endif
