/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   minishell.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef MINISHELL_H
# define MINISHELL_H

# include <stdio.h>
# include <stdlib.h>
# include <unistd.h>
# include <string.h>
# include <signal.h>
# include <sys/wait.h>
# include <sys/stat.h>
# include <fcntl.h>
# include <dirent.h>
# include <errno.h>
# include <readline/readline.h>
# include <readline/history.h>

# define PROMPT "minishell$ "

/* Token types */
typedef enum e_token_type
{
	TOKEN_WORD,
	TOKEN_PIPE,
	TOKEN_REDIR_IN,
	TOKEN_REDIR_OUT,
	TOKEN_REDIR_APPEND,
	TOKEN_REDIR_HEREDOC,
	TOKEN_END
}	t_token_type;

/* Token structure */
typedef struct s_token
{
	t_token_type	type;
	char			*value;
	struct s_token	*next;
}	t_token;

/* Redirection structure */
typedef struct s_redir
{
	t_token_type	type;
	char			*file;
	struct s_redir	*next;
}	t_redir;

/* Command structure */
typedef struct s_cmd
{
	char			**args;
	t_redir			*redirs;
	struct s_cmd	*next;
}	t_cmd;

/* Environment variable structure */
typedef struct s_env
{
	char			*key;
	char			*value;
	struct s_env	*next;
}	t_env;

/* Global structure for shell state */
typedef struct s_shell
{
	t_env	*env;
	int		last_exit_status;
	int		in_heredoc;
}	t_shell;

/* Global variable for signal handling */
extern int	g_signal_received;

/* Lexer */
t_token		*lexer(char *line);
void		free_tokens(t_token *tokens);
t_token		*create_token(t_token_type type, char *value);
void		add_token(t_token **tokens, t_token *new_token);

/* Parser */
t_cmd		*parser(t_token *tokens);
void		free_cmds(t_cmd *cmds);

/* Expander */
char		*expand_vars(char *str, t_shell *shell);
void		expand_cmd(t_cmd *cmd, t_shell *shell);

/* Executor */
void		executor(t_cmd *cmds, t_shell *shell);
int			is_builtin(char *cmd);
int			execute_builtin(char **args, t_shell *shell);

/* Redirections */
int			setup_redirections(t_redir *redirs);
int			handle_heredoc(char *delimiter);

/* Builtins */
int			builtin_echo(char **args);
int			builtin_cd(char **args, t_shell *shell);
int			builtin_pwd(void);
int			builtin_export(char **args, t_shell *shell);
int			builtin_unset(char **args, t_shell *shell);
int			builtin_env(t_shell *shell);
int			builtin_exit(char **args, t_shell *shell);

/* Environment */
t_env		*init_env(char **envp);
void		free_env(t_env *env);
char		*get_env_value(t_env *env, char *key);
void		set_env_value(t_env **env, char *key, char *value);
void		unset_env_value(t_env **env, char *key);
char		**env_to_array(t_env *env);

/* Signals */
void		setup_signals(void);
void		setup_signals_heredoc(void);
void		setup_signals_exec(void);

/* Utils */
char		*ft_strdup(const char *s);
char		*ft_strjoin(char const *s1, char const *s2);
char		*ft_substr(char const *s, unsigned int start, size_t len);
int			ft_strlen(const char *s);
int			ft_strcmp(const char *s1, const char *s2);
int			ft_strncmp(const char *s1, const char *s2, size_t n);
char		*ft_strchr(const char *s, int c);
char		**ft_split(char const *s, char c);
void		ft_free_split(char **split);
int			ft_isspace(char c);
char		*ft_strtrim(char const *s1, char const *set);
int			ft_atoi(const char *str);
void		ft_putstr_fd(char *s, int fd);
void		ft_putendl_fd(char *s, int fd);

/* Error handling */
void		error_msg(char *msg);
void		error_cmd(char *cmd, char *msg);

#endif
