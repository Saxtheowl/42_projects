/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtin_export.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	is_valid_identifier(char *str)
{
	int	i;

	if (!str || !*str)
		return (0);
	if (!((*str >= 'a' && *str <= 'z') || (*str >= 'A' && *str <= 'Z')
			|| *str == '_'))
		return (0);
	i = 1;
	while (str[i] && str[i] != '=')
	{
		if (!(ft_isalnum(str[i]) || str[i] == '_'))
			return (0);
		i++;
	}
	return (1);
}

static void	print_export(t_shell *shell)
{
	int	i;

	i = 0;
	while (shell->env && shell->env[i])
	{
		printf("declare -x %s\n", shell->env[i]);
		i++;
	}
}

static int	export_var(char *arg, t_shell *shell)
{
	char	*equals;
	char	*name;
	char	*value;

	if (!is_valid_identifier(arg))
	{
		fprintf(stderr, "minishell: export: `%s': not a valid identifier\n",
			arg);
		return (1);
	}
	equals = strchr(arg, '=');
	if (!equals)
		return (0);
	name = ft_substr(arg, 0, equals - arg);
	value = ft_strdup(equals + 1);
	set_env_value(shell, name, value);
	free(name);
	free(value);
	return (0);
}

int	builtin_export(t_cmd *cmd, t_shell *shell)
{
	int	i;
	int	ret;

	if (cmd->argc == 1)
	{
		print_export(shell);
		return (0);
	}
	ret = 0;
	i = 1;
	while (cmd->args[i])
	{
		if (export_var(cmd->args[i], shell) != 0)
			ret = 1;
		i++;
	}
	return (ret);
}
