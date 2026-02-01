/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtin_unset.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	is_valid_name(char *str)
{
	int	i;

	if (!str || !*str)
		return (0);
	if (!((*str >= 'a' && *str <= 'z') || (*str >= 'A' && *str <= 'Z')
			|| *str == '_'))
		return (0);
	i = 1;
	while (str[i])
	{
		if (!(ft_isalnum(str[i]) || str[i] == '_'))
			return (0);
		i++;
	}
	return (1);
}

int	builtin_unset(t_cmd *cmd, t_shell *shell)
{
	int	i;
	int	ret;

	ret = 0;
	i = 1;
	while (cmd->args[i])
	{
		if (!is_valid_name(cmd->args[i]))
		{
			fprintf(stderr, "minishell: unset: `%s': not a valid identifier\n",
				cmd->args[i]);
			ret = 1;
		}
		else
			unset_env(shell, cmd->args[i]);
		i++;
	}
	return (ret);
}
