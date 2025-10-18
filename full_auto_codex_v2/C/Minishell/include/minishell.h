#ifndef MINISHELL_H
# define MINISHELL_H

# include <stdbool.h>
# include "rl_wrapper.h"

typedef struct s_ms
{
	char	**envp;
	bool	interactive;
	bool	running;
	int		last_status;
}	t_ms;

int		ms_init(t_ms *ms, char **envp);
int		ms_run(t_ms *ms);
void	ms_cleanup(t_ms *ms);

/* prompt */
char	*ms_readline(t_ms *ms);

/* signals */
void	ms_configure_signals_interactive(void);
void	ms_configure_signals_child(void);

#endif
