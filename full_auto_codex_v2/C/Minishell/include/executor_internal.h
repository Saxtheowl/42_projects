#ifndef EXECUTOR_INTERNAL_H
# define EXECUTOR_INTERNAL_H

# include <sys/types.h>
# include "executor.h"
# include "builtins.h"

int	ms_wait_status_to_exit(int status);
int	ms_wait_for_pid(pid_t pid);
int	ms_apply_redirects(const t_redirect *redirects);
int	ms_collect_heredoc_input(t_ms *ms, t_redirect *redir);
int	ms_execute_pipeline(t_ms *ms, t_ast *left, t_ast *right);
int	ms_execute_ast_node(t_ms *ms, t_ast *node, int in_child);
int	ms_execute_command(t_ms *ms, t_command *cmd, int in_child);
int	ms_execute_external(t_ms *ms, t_command *cmd, int in_child);
int	ms_execute_builtin(t_ms *ms, t_command *cmd,
			 t_builtin_fn builtin, int in_child);

#endif
