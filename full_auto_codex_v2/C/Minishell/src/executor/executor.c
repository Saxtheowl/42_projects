#include "executor.h"
#include "env.h"
#include "builtins.h"
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

#define EXIT_CMD_NOT_FOUND 127
#define EXIT_NO_PERMISSION 126

typedef struct s_buf
{
	char	*data;
	size_t	len;
	size_t	cap;
}t_buf;

static int	buf_reserve(t_buf *buf, size_t needed)
{
	char	*tmp;
	size_t	new_cap;

	if (buf->len + needed + 1 <= buf->cap)
		return (0);
	new_cap = buf->cap ? buf->cap * 2 : 64;
	while (new_cap < buf->len + needed + 1)
		new_cap *= 2;
	tmp = realloc(buf->data, new_cap);
	if (!tmp)
		return (1);
	buf->data = tmp;
	buf->cap = new_cap;
	return (0);
}

static int	buf_append_char(t_buf *buf, char c)
{
	if (buf_reserve(buf, 1))
		return (1);
	buf->data[buf->len++] = c;
	buf->data[buf->len] = '\0';
	return (0);
}

static int	buf_append_str(t_buf *buf, const char *s)
{
	size_t	len;

	if (!s)
		return (0);
	len = strlen(s);
	if (buf_reserve(buf, len))
		return (1);
	memcpy(buf->data + buf->len, s, len);
	buf->len += len;
	buf->data[buf->len] = '\0';
	return (0);
}

static char	*expand_heredoc_line(t_ms *ms, const char *line)
{
	t_buf	buf;
	size_t	i;

	memset(&buf, 0, sizeof(buf));
	i = 0;
	while (line[i])
	{
		if (line[i] == '$')
		{
			i++;
			if (line[i] == '?')
			{
				char tmp[16];

				snprintf(tmp, sizeof(tmp), "%d", ms->last_status);
				if (buf_append_str(&buf, tmp))
				return (free(buf.data), NULL);
				i++;
				continue ;
			}
			if (line[i] == '\0')
			{
				if (buf_append_char(&buf, '$'))
					return (free(buf.data), NULL);
				break ;
			}
			if (!(isalpha((unsigned char)line[i]) || line[i] == '_'))
			{
				if (buf_append_char(&buf, '$'))
					return (free(buf.data), NULL);
				continue ;
			}
			size_t start = i;
			while (isalnum((unsigned char)line[i]) || line[i] == '_')
				i++;
			size_t len = i - start;
			char *name = strndup(line + start, len);
			if (!name)
				return (free(buf.data), NULL);
			const char *value = ms_env_get(ms, name);
			free(name);
			if (value && buf_append_str(&buf, value))
				return (free(buf.data), NULL);
			continue ;
		}
		if (buf_append_char(&buf, line[i]))
			return (free(buf.data), NULL);
		i++;
	}
	if (!buf.data && buf_append_char(&buf, '\0'))
		return (NULL);
	return (buf.data);
}

static int	wait_status_to_exit(int status)
{
	if (WIFEXITED(status))
		return (WEXITSTATUS(status));
	if (WIFSIGNALED(status))
		return (128 + WTERMSIG(status));
	return (status);
}

static int	open_mode_from_redirect(t_redirect_type type)
{
	if (type == REDIR_OUTPUT)
		return (O_CREAT | O_WRONLY | O_TRUNC);
	if (type == REDIR_APPEND)
		return (O_CREAT | O_WRONLY | O_APPEND);
	return (O_RDONLY);
}

static int	target_fd_from_redirect(t_redirect_type type)
{
	if (type == REDIR_INPUT || type == REDIR_HEREDOC)
		return (STDIN_FILENO);
	return (STDOUT_FILENO);
}

static int	write_line_to_fd(int fd, const char *line)
{
	size_t	len;

	len = strlen(line);
	if (len > 0 && write(fd, line, len) < 0)
		return (perror("write"), 1);
	if (write(fd, "\n", 1) < 0)
		return (perror("write"), 1);
	return (0);
}

static int	process_heredoc(t_ms *ms, const t_redirect *redir, int apply_to_stdin)
{
	int	 pipefd[2];
	char	*line;
	int	 status;

	if (pipe(pipefd) < 0)
	{
		perror("pipe");
		return (1);
	}
	status = 0;
	while (1)
	{
		line = readline("heredoc> ");
		if (!line)
			break ;
		if (strcmp(line, redir->target) == 0)
		{
			free(line);
			break ;
		}
		char *expanded = NULL;
		const char *to_write = line;
		if (redir->heredoc_expand)
		{
			expanded = expand_heredoc_line(ms, line);
			if (!expanded)
			{
				free(line);
				status = 1;
				break ;
			}
			to_write = expanded;
		}
		if (write_line_to_fd(pipefd[1], to_write))
		{
			status = 1;
			free(expanded);
			free(line);
			break ;
		}
		free(expanded);
		free(line);
	}
	close(pipefd[1]);
	if (status == 0 && apply_to_stdin)
	{
		if (dup2(pipefd[0], STDIN_FILENO) < 0)
		{
			perror("dup2");
			status = 1;
		}
	}
	close(pipefd[0]);
	return (status);
}

static int	apply_redirects(t_ms *ms, const t_redirect *redir, int apply_heredoc)
{
	int	fd;
	int	target;
	int	flags;

	while (redir)
	{
		if (redir->type == REDIR_HEREDOC)
		{
			if (process_heredoc(ms, redir, apply_heredoc))
				return (1);
			redir = redir->next;
			continue ;
		}
		flags = open_mode_from_redirect(redir->type);
		fd = open(redir->target, flags, 0644);
		if (fd < 0)
		{
			perror(redir->target);
			return (1);
		}
		target = target_fd_from_redirect(redir->type);
		if (dup2(fd, target) < 0)
		{
			perror("dup2");
			close(fd);
			return (1);
		}
		close(fd);
		redir = redir->next;
	}
	return (0);
}

static char	*resolve_command_path(t_ms *ms, const char *cmd)
{
	const char	*path_env;
	char		*dup;
	char		*token;
	char		*saveptr;
	size_t		len;
	char		*candidate;

	if (!cmd || *cmd == '\0')
		return (NULL);
	if (strchr(cmd, '/'))
		return (strdup(cmd));
	path_env = ms_env_get(ms, "PATH");
	if (!path_env || *path_env == '\0')
		return (NULL);
	dup = strdup(path_env);
	if (!dup)
		return (NULL);
	token = strtok_r(dup, ":", &saveptr);
	while (token)
	{
		len = strlen(token) + strlen(cmd) + 2;
		candidate = malloc(len);
		if (!candidate)
		{
			free(dup);
			return (NULL);
		}
		snprintf(candidate, len, "%s/%s", token, cmd);
		if (access(candidate, X_OK) == 0)
		{
			free(dup);
			return (candidate);
		}
		free(candidate);
		token = strtok_r(NULL, ":", &saveptr);
	}
	free(dup);
	return (NULL);
}

static void	execve_with_error(t_ms *ms, t_command *cmd)
{
	char	*path;
	int		err;

	if (!cmd->argv || !cmd->argv[0])
		_exit(0);
	path = resolve_command_path(ms, cmd->argv[0]);
	if (!path)
	{
		if (strchr(cmd->argv[0], '/'))
			perror(cmd->argv[0]);
		else
			fprintf(stderr, "minishell: %s: command not found\n", cmd->argv[0]);
		_exit(EXIT_CMD_NOT_FOUND);
	}
	execve(path, cmd->argv, ms->envp);
	err = errno;
	perror(path);
	free(path);
	if (err == ENOENT)
		_exit(EXIT_CMD_NOT_FOUND);
	if (err == EACCES)
		_exit(EXIT_NO_PERMISSION);
	_exit(EXIT_NO_PERMISSION);
}

static int	save_stdio(int saved[2], const t_redirect *redir)
{
	int	in_saved;
	int	out_saved;

	in_saved = -1;
	out_saved = -1;
	while (redir)
	{
		if ((redir->type == REDIR_INPUT || redir->type == REDIR_HEREDOC)
			&& in_saved == -1)
		{
			in_saved = dup(STDIN_FILENO);
			if (in_saved < 0)
			{
				perror("dup");
				return (1);
			}
		}
		if ((redir->type == REDIR_OUTPUT || redir->type == REDIR_APPEND)
			&& out_saved == -1)
		{
			out_saved = dup(STDOUT_FILENO);
			if (out_saved < 0)
			{
				perror("dup");
				if (in_saved >= 0)
					close(in_saved);
				return (1);
			}
		}
		redir = redir->next;
	}
	saved[0] = in_saved;
	saved[1] = out_saved;
	return (0);
}

static void	restore_stdio(const int saved[2])
{
	if (saved[0] >= 0)
	{
		if (dup2(saved[0], STDIN_FILENO) < 0)
			perror("dup2");
		close(saved[0]);
	}
	if (saved[1] >= 0)
	{
		if (dup2(saved[1], STDOUT_FILENO) < 0)
			perror("dup2");
		close(saved[1]);
	}
}

static int	execute_builtin(t_ms *ms, t_command *cmd,
		t_builtin_fn builtin, int in_child)
{
	int	saved[2];
	int	status;

	saved[0] = -1;
	saved[1] = -1;
	if (!in_child)
	{
		if (save_stdio(saved, cmd->redirects))
			return (1);
	}
    if (apply_redirects(ms, cmd->redirects, 1))
	{
		if (!in_child)
			restore_stdio(saved);
		return (1);
	}
	status = builtin(ms, cmd, in_child);
	if (!in_child)
		restore_stdio(saved);
	return (status);
}

static int	execute_external_child(t_ms *ms, t_command *cmd)
{
	if (apply_redirects(ms, cmd->redirects, 1))
		_exit(1);
	execve_with_error(ms, cmd);
	_exit(1);
}

static int	execute_redirection_only(t_ms *ms, t_command *cmd)
{
	const t_redirect	*redir;
	int					fd;
	int					flags;

	redir = cmd->redirects;
	while (redir)
	{
		if (redir->type == REDIR_HEREDOC)
		{
			if (process_heredoc(ms, redir, 0))
				return (1);
			redir = redir->next;
			continue ;
		}
		flags = open_mode_from_redirect(redir->type);
		fd = open(redir->target, flags, 0644);
		if (fd < 0)
		{
			perror(redir->target);
			return (1);
		}
		close(fd);
		redir = redir->next;
	}
	return (0);
}

static int	execute_external_parent(t_ms *ms, t_command *cmd)
{
	pid_t	pid;
	int		status;

	pid = fork();
	if (pid < 0)
	{
		perror("fork");
		return (1);
	}
	if (pid == 0)
		execute_external_child(ms, cmd);
	if (waitpid(pid, &status, 0) < 0)
	{
		perror("waitpid");
		return (1);
	}
	return (wait_status_to_exit(status));
}

static int	execute_command(t_ms *ms, t_command *cmd, int in_child)
{
	t_builtin_fn	builtin;

	if (!cmd->argv || !cmd->argv[0])
		return (execute_redirection_only(cmd));
	builtin = ms_builtin_get(cmd->argv[0]);
	if (builtin)
		return (execute_builtin(ms, cmd, builtin, in_child));
	if (in_child)
		return (execute_external_child(ms, cmd));
	return (execute_external_parent(ms, cmd));
}

static int	execute_ast_node(t_ms *ms, t_ast *node, int in_child);

static int	execute_pipeline(t_ms *ms, t_ast *left, t_ast *right)
{
	int		pipefd[2];
	pid_t	left_pid;
	pid_t	right_pid;
	int		status_left;
	int		status_right;

	if (pipe(pipefd) < 0)
	{
		perror("pipe");
		return (1);
	}
	left_pid = fork();
	if (left_pid < 0)
	{
		perror("fork");
		close(pipefd[0]);
		close(pipefd[1]);
		return (1);
	}
	if (left_pid == 0)
	{
		if (dup2(pipefd[1], STDOUT_FILENO) < 0)
		{
			perror("dup2");
			_exit(1);
		}
		close(pipefd[0]);
		close(pipefd[1]);
		status_left = execute_ast_node(ms, left, 1);
		if (status_left < 0)
			status_left = 1;
		_exit(status_left);
	}
	right_pid = fork();
	if (right_pid < 0)
	{
		perror("fork");
		close(pipefd[0]);
		close(pipefd[1]);
		return (1);
	}
	if (right_pid == 0)
	{
		if (dup2(pipefd[0], STDIN_FILENO) < 0)
		{
			perror("dup2");
			_exit(1);
		}
		close(pipefd[0]);
		close(pipefd[1]);
		status_right = execute_ast_node(ms, right, 1);
		if (status_right < 0)
			status_right = 1;
		_exit(status_right);
	}
	close(pipefd[0]);
	close(pipefd[1]);
	if (waitpid(left_pid, &status_left, 0) < 0)
		perror("waitpid");
	if (waitpid(right_pid, &status_right, 0) < 0)
	{
		perror("waitpid");
		return (1);
	}
	return (wait_status_to_exit(status_right));
}

static int	execute_ast_node(t_ms *ms, t_ast *node, int in_child)
{
	int	status;

	if (!node)
		return (-1);
	if (node->type == AST_PIPELINE)
		status = execute_pipeline(ms, node->as.pipeline.left,
				node->as.pipeline.right);
	else
		status = execute_command(ms, &node->as.command, in_child);
	ms->last_status = status >= 0 ? status : ms->last_status;
	return (status);
}

int	ms_execute(t_ms *ms, t_ast *ast)
{
	int	status;

	status = execute_ast_node(ms, ast, 0);
	if (status < 0)
		status = 1;
	ms->last_status = status;
	return (status);
}
