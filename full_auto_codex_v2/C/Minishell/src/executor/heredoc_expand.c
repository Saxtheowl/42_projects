#include "env.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct s_builder
{
	char	*data;
	size_t	len;
	size_t	cap;
}	t_builder;

static int	builder_reserve(t_builder *b, size_t extra)
{
	size_t	cap;
	char	*tmp;

	if (b->len + extra + 1 <= b->cap)
		return (0);
	cap = b->cap ? b->cap * 2 : 32;
	while (cap < b->len + extra + 1)
		cap *= 2;
	tmp = realloc(b->data, cap);
	if (!tmp)
		return (1);
	b->data = tmp;
	b->cap = cap;
	return (0);
}

static int	builder_append_span(t_builder *b, const char *s, size_t len)
{
	if (len == 0)
		return (0);
	if (builder_reserve(b, len))
		return (1);
	memcpy(b->data + b->len, s, len);
	b->len += len;
	b->data[b->len] = '\0';
	return (0);
}

static int	builder_append_status(t_builder *b, int status)
{
	char	buf[16];
	int		written;

	written = snprintf(buf, sizeof(buf), "%d", status);
	if (written < 0)
		return (1);
	return (builder_append_span(b, buf, (size_t)written));
}

static size_t	var_length(const char *s)
{
	size_t	len;

	if (!s[0] || (!isalpha((unsigned char)s[0]) && s[0] != '_'))
		return (0);
	len = 1;
	while (isalnum((unsigned char)s[len]) || s[len] == '_')
		len++;
	return (len);
}

char	*ms_expand_heredoc_line(t_ms *ms, const char *line)
{
	t_builder	b;
	size_t		i;
	size_t		len;
	char		*name;
	const char	*value;

	memset(&b, 0, sizeof(b));
	i = 0;
	while (line[i])
	{
		if (line[i] != '$')
		{
			if (builder_append_span(&b, line + i, 1))
				return (free(b.data), NULL);
			i++;
			continue ;
		}
		i++;
		if (!line[i])
		{
			if (builder_append_span(&b, "$", 1))
				return (free(b.data), NULL);
			break ;
		}
		if (line[i] == '?')
		{
			if (builder_append_status(&b, ms->last_status))
				return (free(b.data), NULL);
			i++;
			continue ;
		}
		len = var_length(line + i);
		if (len == 0)
		{
			if (builder_append_span(&b, "$", 1))
				return (free(b.data), NULL);
			continue ;
		}
		name = strndup(line + i, len);
		if (!name)
			return (free(b.data), NULL);
		value = ms_env_get(ms, name);
		free(name);
		if (value
			&& builder_append_span(&b, value, strlen(value)))
			return (free(b.data), NULL);
		i += len;
	}
	if (!b.data)
		return (strdup(""));
	return (b.data);
}
