/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   env.c                                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

char	**copy_env(char **envp)
{
	char	**env;
	int		count;
	int		i;

	count = 0;
	while (envp && envp[count])
		count++;
	env = malloc((count + 1) * sizeof(char *));
	if (!env)
		return (NULL);
	i = 0;
	while (i < count)
	{
		env[i] = ft_strdup(envp[i]);
		if (!env[i])
		{
			while (--i >= 0)
				free(env[i]);
			free(env);
			return (NULL);
		}
		i++;
	}
	env[i] = NULL;
	return (env);
}

void	free_env(char **env)
{
	int	i;

	if (!env)
		return ;
	i = 0;
	while (env[i])
	{
		free(env[i]);
		i++;
	}
	free(env);
}

char	*get_env_value(t_shell *shell, const char *name)
{
	int		i;
	size_t	len;
	char	*equals;

	if (!name || !shell->env)
		return (NULL);
	len = ft_strlen(name);
	i = 0;
	while (shell->env[i])
	{
		if (strncmp(shell->env[i], name, len) == 0)
		{
			equals = strchr(shell->env[i], '=');
			if (equals && (size_t)(equals - shell->env[i]) == len)
				return (equals + 1);
		}
		i++;
	}
	return (NULL);
}

int	set_env_value(t_shell *shell, const char *name, const char *value)
{
	int		i;
	size_t	len;
	char	*new_entry;
	char	**new_env;

	len = ft_strlen(name);
	new_entry = malloc(len + ft_strlen(value) + 2);
	if (!new_entry)
		return (-1);
	sprintf(new_entry, "%s=%s", name, value);
	i = 0;
	while (shell->env && shell->env[i])
	{
		if (strncmp(shell->env[i], name, len) == 0 && shell->env[i][len] == '=')
		{
			free(shell->env[i]);
			shell->env[i] = new_entry;
			return (0);
		}
		i++;
	}
	new_env = malloc((shell->env_count + 2) * sizeof(char *));
	if (!new_env)
	{
		free(new_entry);
		return (-1);
	}
	i = 0;
	while (i < shell->env_count)
	{
		new_env[i] = shell->env[i];
		i++;
	}
	new_env[i++] = new_entry;
	new_env[i] = NULL;
	free(shell->env);
	shell->env = new_env;
	shell->env_count++;
	return (0);
}

int	unset_env(t_shell *shell, const char *name)
{
	int		i;
	int		j;
	size_t	len;

	if (!name || !shell->env)
		return (0);
	len = ft_strlen(name);
	i = 0;
	while (shell->env[i])
	{
		if (strncmp(shell->env[i], name, len) == 0
			&& (shell->env[i][len] == '=' || shell->env[i][len] == '\0'))
		{
			free(shell->env[i]);
			j = i;
			while (shell->env[j + 1])
			{
				shell->env[j] = shell->env[j + 1];
				j++;
			}
			shell->env[j] = NULL;
			shell->env_count--;
			return (0);
		}
		i++;
	}
	return (0);
}
