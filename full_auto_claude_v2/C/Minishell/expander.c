/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expander.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static char	*ft_itoa(int n)
{
	char	*str;
	int		len;
	int		tmp;

	tmp = n;
	len = (n <= 0) ? 1 : 0;
	while (tmp)
	{
		tmp /= 10;
		len++;
	}
	str = malloc(sizeof(char) * (len + 1));
	if (!str)
		return (NULL);
	str[len] = '\0';
	if (n == 0)
		str[0] = '0';
	if (n < 0)
		str[0] = '-';
	while (n)
	{
		str[--len] = (n < 0 ? -(n % 10) : n % 10) + '0';
		n /= 10;
	}
	return (str);
}

static char	*get_var_name(char *str, int *i)
{
	int		start;
	int		len;
	char	*name;

	(*i)++;
	if (str[*i] == '?')
	{
		(*i)++;
		return (ft_strdup("?"));
	}
	start = *i;
	len = 0;
	while (str[*i] && (ft_strchr("ABCDEFGHIJKLMNOPQRSTUVWXYZ"
				"abcdefghijklmnopqrstuvwxyz0123456789_", str[*i])))
	{
		len++;
		(*i)++;
	}
	name = ft_substr(str, start, len);
	return (name);
}

static char	*expand_var(char *str, int *i, t_shell *shell)
{
	char	*var_name;
	char	*value;

	var_name = get_var_name(str, i);
	if (!var_name)
		return (ft_strdup(""));
	if (ft_strcmp(var_name, "?") == 0)
	{
		free(var_name);
		return (ft_itoa(shell->last_exit_status));
	}
	value = get_env_value(shell->env, var_name);
	free(var_name);
	if (!value)
		return (ft_strdup(""));
	return (ft_strdup(value));
}

static char	*process_expansion(char *str, t_shell *shell, int in_single_quote)
{
	char	*result;
	char	*temp;
	char	*var_value;
	int		i;

	result = ft_strdup("");
	i = 0;
	while (str[i])
	{
		if (str[i] == '\'')
		{
			in_single_quote = !in_single_quote;
			i++;
		}
		else if (str[i] == '$' && !in_single_quote)
		{
			var_value = expand_var(str, &i, shell);
			temp = ft_strjoin(result, var_value);
			free(result);
			free(var_value);
			result = temp;
		}
		else
		{
			temp = ft_substr(str, i, 1);
			var_value = ft_strjoin(result, temp);
			free(result);
			free(temp);
			result = var_value;
			i++;
		}
	}
	return (result);
}

char	*expand_vars(char *str, t_shell *shell)
{
	char	*expanded;

	if (!str)
		return (NULL);
	expanded = process_expansion(str, shell, 0);
	return (expanded);
}

void	expand_cmd(t_cmd *cmd, t_shell *shell)
{
	int		i;
	char	*expanded;
	t_redir	*redir;

	if (!cmd)
		return ;
	i = 0;
	while (cmd->args && cmd->args[i])
	{
		expanded = expand_vars(cmd->args[i], shell);
		free(cmd->args[i]);
		cmd->args[i] = expanded;
		i++;
	}
	redir = cmd->redirs;
	while (redir)
	{
		expanded = expand_vars(redir->file, shell);
		free(redir->file);
		redir->file = expanded;
		redir = redir->next;
	}
}
