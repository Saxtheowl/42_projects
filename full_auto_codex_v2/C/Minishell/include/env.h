#ifndef ENV_H
# define ENV_H

# include "minishell.h"

const char	*ms_env_get(t_ms *ms, const char *name);
int			ms_env_set(t_ms *ms, const char *name, const char *value);
int			ms_env_unset(t_ms *ms, const char *name);
int			ms_env_is_valid_identifier(const char *name);
char		**ms_env_export_snapshot(t_ms *ms);

#endif
