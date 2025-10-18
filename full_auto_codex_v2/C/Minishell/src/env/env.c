#include "env.h"
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static size_t	env_count(char **envp)
{
	size_t	count;

	count = 0;
	while (envp && envp[count])
		count++;
	return (count);
}

static int	env_key_match(const char *entry, const char *name)
{
	size_t	len;

	len = strlen(name);
	return (strncmp(entry, name, len) == 0 && entry[len] == '=');
}

const char	*ms_env_get(t_ms *ms, const char *name)
{
	size_t	i;

	if (!ms || !name)
		return (NULL);
	i = 0;
	while (ms->envp && ms->envp[i])
	{
		if (env_key_match(ms->envp[i], name))
			return (ms->envp[i] + strlen(name) + 1);
		i++;
	}
	return (NULL);
}

static char	*env_join(const char *name, const char *value)
{
	size_t	len_name;
	size_t	len_value;
	char	*entry;

	len_name = strlen(name);
	len_value = value ? strlen(value) : 0;
	entry = malloc(len_name + len_value + 2);
	if (!entry)
		return (NULL);
	memcpy(entry, name, len_name);
	entry[len_name] = '=';
	if (value)
		memcpy(entry + len_name + 1, value, len_value);
	entry[len_name + 1 + len_value] = '\0';
	return (entry);
}

int	ms_env_set(t_ms *ms, const char *name, const char *value)
{
	size_t	i;
	char	*entry;
	char	**new_envp;
	size_t	count;

	if (!ms || !name)
		return (1);
	entry = env_join(name, value ? value : "");
	if (!entry)
		return (1);
	i = 0;
	while (ms->envp && ms->envp[i])
	{
		if (env_key_match(ms->envp[i], name))
		{
			free(ms->envp[i]);
			ms->envp[i] = entry;
			return (0);
		}
		i++;
	}
	count = env_count(ms->envp);
	new_envp = realloc(ms->envp, sizeof(char *) * (count + 2));
	if (!new_envp)
	{
		free(entry);
		return (1);
	}
	ms->envp = new_envp;
	ms->envp[i] = entry;
	ms->envp[i + 1] = NULL;
	return (0);
}

int	ms_env_unset(t_ms *ms, const char *name)
{
	size_t	i;
	size_t	j;
	size_t	count;
	char	**new_envp;

	if (!ms || !ms->envp || !name)
		return (1);
	i = 0;
	while (ms->envp[i] && !env_key_match(ms->envp[i], name))
		i++;
	if (!ms->envp[i])
		return (0);
	free(ms->envp[i]);
	j = i;
	while (ms->envp[j])
	{
		ms->envp[j] = ms->envp[j + 1];
		j++;
	}
	count = env_count(ms->envp);
	new_envp = realloc(ms->envp, sizeof(char *) * (count + 1));
	if (new_envp)
		ms->envp = new_envp;
	return (0);
}

int	ms_env_is_valid_identifier(const char *name)
{
	size_t	i;

	if (!name || !name[0])
		return (0);
	if (!(isalpha((unsigned char)name[0]) || name[0] == '_'))
		return (0);
	i = 1;
	while (name[i] && name[i] != '=')
	{
		if (!(isalnum((unsigned char)name[i]) || name[i] == '_'))
			return (0);
		i++;
	}
	return (1);
}

char	**ms_env_export_snapshot(t_ms *ms)
{
	size_t	count;
	size_t	i;
	char	**snapshot;

	if (!ms)
		return (NULL);
	count = env_count(ms->envp);
	snapshot = calloc(count + 1, sizeof(char *));
	if (!snapshot)
		return (NULL);
	i = 0;
	while (i < count)
	{
		snapshot[i] = strdup(ms->envp[i]);
		if (!snapshot[i])
		{
			while (i > 0)
				free(snapshot[--i]);
			free(snapshot);
			return (NULL);
		}
		i++;
	}
	return (snapshot);
}
