/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   minishell.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef MINISHELL_H
# define MINISHELL_H

# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <string.h>
# include <fcntl.h>
# include <errno.h>
# include <signal.h>
# include <sys/wait.h>
# include <sys/stat.h>

# ifdef USE_READLINE
#  include <readline/readline.h>
#  include <readline/history.h>
# else
#  define add_history(x) (void)(x)
char	*readline(const char *prompt);
void	rl_on_new_line(void);
void	rl_replace_line(const char *text, int clear_undo);
void	rl_redisplay(void);
# endif

# define PROMPT "minishell> "

/* Token types */
typedef enum e_token_type
{
	TOKEN_WORD,
	TOKEN_PIPE,
	TOKEN_REDIR_IN,
	TOKEN_REDIR_OUT,
	TOKEN_APPEND,
	TOKEN_HEREDOC,
	TOKEN_EOF
}	t_token_type;

/* Token structure */
typedef struct s_token
{
	t_token_type		type;
	char				*value;
	struct s_token		*next;
}	t_token;

/* Redirection structure */
typedef struct s_redir
{
	t_token_type		type;
	char				*file;
	struct s_redir		*next;
}	t_redir;

/* Command structure */
typedef struct s_cmd
{
	char				**args;
	int					argc;
	t_redir				*redir;
	struct s_cmd		*next;
}	t_cmd;

/* Shell state */
typedef struct s_shell
{
	char				**env;
	int					env_count;
	int					exit_status;
	int					running;
}	t_shell;

/* Global signal flag */
extern volatile sig_atomic_t	g_signal;

/* main.c */
void	init_shell(t_shell *shell, char **envp);
void	cleanup_shell(t_shell *shell);

/* lexer.c */
t_token	*lexer(char *input, t_shell *shell);
void	free_tokens(t_token *tokens);

/* parser.c */
t_cmd	*parser(t_token *tokens);
void	free_cmds(t_cmd *cmds);

/* executor.c */
int		execute(t_cmd *cmd, t_shell *shell);

/* builtins.c */
int		is_builtin(char *cmd);
int		exec_builtin(t_cmd *cmd, t_shell *shell);

/* builtin_echo.c */
int		builtin_echo(t_cmd *cmd);

/* builtin_cd.c */
int		builtin_cd(t_cmd *cmd, t_shell *shell);

/* builtin_pwd.c */
int		builtin_pwd(void);

/* builtin_export.c */
int		builtin_export(t_cmd *cmd, t_shell *shell);

/* builtin_unset.c */
int		builtin_unset(t_cmd *cmd, t_shell *shell);

/* builtin_env.c */
int		builtin_env(t_shell *shell);

/* builtin_exit.c */
int		builtin_exit(t_cmd *cmd, t_shell *shell);

/* env.c */
char	*get_env_value(t_shell *shell, const char *name);
int		set_env_value(t_shell *shell, const char *name, const char *value);
int		unset_env(t_shell *shell, const char *name);
char	**copy_env(char **envp);
void	free_env(char **env);

/* expand.c */
char	*expand_vars(char *str, t_shell *shell);

/* redirect.c */
int		setup_redirections(t_redir *redir);
void	free_redir(t_redir *redir);

/* signals.c */
void	setup_signals(void);
void	setup_signals_child(void);
void	setup_signals_heredoc(void);

/* utils.c */
char	*ft_strdup(const char *s);
char	*ft_strjoin(const char *s1, const char *s2);
char	*ft_substr(const char *s, unsigned int start, size_t len);
int		ft_strcmp(const char *s1, const char *s2);
size_t	ft_strlen(const char *s);
char	**ft_split(const char *s, char c);
void	ft_free_split(char **split);
int		ft_isspace(int c);
int		ft_isalnum(int c);
char	*ft_itoa(int n);

/* path.c */
char	*find_command(char *cmd, t_shell *shell);

#endif
