/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PIPEX_H
# define PIPEX_H

# include <unistd.h>
# include <stdlib.h>
# include <fcntl.h>
# include <sys/wait.h>
# include <stdio.h>
# include <string.h>

/* Error messages */
# define ERR_ARGS "Usage: ./pipex file1 cmd1 cmd2 file2\n"
# define ERR_ARGS_BONUS "Usage: ./pipex file1 cmd1 cmd2 ... cmdn file2\n"
# define ERR_ARGS_HEREDOC "Usage: ./pipex here_doc LIMITER cmd cmd1 file\n"
# define ERR_PIPE "Pipe creation failed\n"
# define ERR_FORK "Fork failed\n"
# define ERR_CMD "Command not found: "

/* Structure for pipex data */
typedef struct s_pipex
{
	int		infile;
	int		outfile;
	char	**paths;
	char	**envp;
	int		here_doc;
	char	*limiter;
}	t_pipex;

/* Main functions */
void	execute_pipex(char **argv, char **envp, int argc);
void	execute_pipex_bonus(char **argv, char **envp, int argc);
void	execute_here_doc(char **argv, char **envp);
void	execute_command(char *cmd, char **envp);

/* Utilities */
char	*find_path(char *cmd, char **envp);
char	**get_paths(char **envp);
char	**ft_split(char const *s, char c);
void	free_split(char **split);
void	error_exit(char *msg);
void	ft_putstr_fd(char *s, int fd);

/* String utilities from libft */
size_t	ft_strlen(const char *s);
char	*ft_strjoin(char const *s1, char const *s2);
char	*ft_strdup(const char *s1);
int		ft_strncmp(const char *s1, const char *s2, size_t n);

#endif
