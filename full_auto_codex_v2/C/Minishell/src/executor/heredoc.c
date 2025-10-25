#include "executor_internal.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct s_hd_buffer
{
	char	*data;
	size_t	len;
	size_t	cap;
}	t_hd_buffer;

static int	hd_reserve(t_hd_buffer *buf, size_t extra)
{
	size_t	cap;
	char	*tmp;

	if (buf->len + extra + 1 <= buf->cap)
		return (0);
	cap = buf->cap ? buf->cap * 2 : 64;
	while (cap < buf->len + extra + 1)
		cap *= 2;
	tmp = realloc(buf->data, cap);
	if (!tmp)
		return (1);
	buf->data = tmp;
	buf->cap = cap;
	return (0);
}

static int	hd_append_line(t_hd_buffer *buf, const char *line)
{
	size_t	len;

	len = line ? strlen(line) : 0;
	if (len && hd_reserve(buf, len))
		return (1);
	if (len)
	{
		memcpy(buf->data + buf->len, line, len);
		buf->len += len;
		buf->data[buf->len] = '\0';
	}
	if (hd_reserve(buf, 1))
		return (1);
	buf->data[buf->len++] = '\n';
	buf->data[buf->len] = '\0';
	return (0);
}

char	*ms_expand_heredoc_line(t_ms *ms, const char *line);

static int	hd_handle_line(t_ms *ms, t_redirect *redir,
			t_hd_buffer *buf, char *line)
{
	char	*expanded;

	if (strcmp(line, redir->target) == 0)
		return (free(line), 1);
	expanded = line;
	if (redir->heredoc_expand)
	{
		expanded = ms_expand_heredoc_line(ms, line);
		free(line);
		if (!expanded)
			return (-1);
	}
	if (hd_append_line(buf, expanded))
	{
		free(expanded);
		return (-1);
	}
	if (redir->heredoc_expand)
		free(expanded);
	else
		free(line);
	return (0);
}

static int	hd_read_loop(t_ms *ms, t_redirect *redir, t_hd_buffer *buf,
		const char *prompt)
{
	char	*line;
	int		status;

	while ((line = readline(prompt)))
	{
		status = hd_handle_line(ms, redir, buf, line);
		if (status < 0)
			return (1);
		if (status == 1)
			return (0);
	}
	if (ms_signals_consume_sigint())
		return (130);
	fprintf(stderr,
		"minishell: warning: here-document delimited by end-of-file "
		"(wanted `%s')\n", redir->target);
	return (0);
}

int	ms_collect_heredoc_input(t_ms *ms, t_redirect *redir)
{
	const char	*prompt;
	t_hd_buffer	buf;
	int		status;

	memset(&buf, 0, sizeof(buf));
	(void)ms_signals_consume_sigint();
	prompt = ms->interactive ? "heredoc> " : NULL;
	status = hd_read_loop(ms, redir, &buf, prompt);
	if (status != 0)
		return (free(buf.data), status);
	if (!buf.data)
	{
		buf.data = strdup("");
		if (!buf.data)
			return (1);
	}
	free(redir->heredoc_data);
	redir->heredoc_data = buf.data;
	return (0);
}
