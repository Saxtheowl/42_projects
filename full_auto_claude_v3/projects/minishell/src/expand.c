/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static char	*get_var_name(char **str)
{
	char	*start;
	char	*name;
	int		len;

	start = *str;
	len = 0;
	if (**str == '?')
	{
		(*str)++;
		return (ft_strdup("?"));
	}
	while (**str && (ft_isalnum(**str) || **str == '_'))
	{
		(*str)++;
		len++;
	}
	name = ft_substr(start, 0, len);
	return (name);
}

static char	*expand_single_var(char **str, t_shell *shell)
{
	char	*name;
	char	*value;
	char	*result;

	(*str)++;
	if (!**str || (!ft_isalnum(**str) && **str != '_' && **str != '?'))
		return (ft_strdup("$"));
	name = get_var_name(str);
	if (!name)
		return (ft_strdup(""));
	if (ft_strcmp(name, "?") == 0)
	{
		free(name);
		return (ft_itoa(shell->exit_status));
	}
	value = get_env_value(shell, name);
	free(name);
	if (value)
		result = ft_strdup(value);
	else
		result = ft_strdup("");
	return (result);
}

char	*expand_vars(char *str, t_shell *shell)
{
	char	*result;
	char	*tmp;
	char	*part;
	char	*plain_start;

	result = ft_strdup("");
	while (*str)
	{
		if (*str == '$')
		{
			part = expand_single_var(&str, shell);
			tmp = ft_strjoin(result, part);
			free(result);
			free(part);
			result = tmp;
		}
		else
		{
			plain_start = str;
			while (*str && *str != '$')
				str++;
			part = ft_substr(plain_start, 0, str - plain_start);
			tmp = ft_strjoin(result, part);
			free(result);
			free(part);
			result = tmp;
		}
	}
	return (result);
}
