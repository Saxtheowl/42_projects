/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtin_export.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static void	print_export(t_env *env)
{
	while (env)
	{
		ft_putstr_fd("declare -x ", 1);
		ft_putstr_fd(env->key, 1);
		ft_putstr_fd("=\"", 1);
		ft_putstr_fd(env->value, 1);
		ft_putendl_fd("\"", 1);
		env = env->next;
	}
}

int	builtin_export(char **args, t_shell *shell)
{
	char	*equal;
	int		i;

	if (!args[1])
	{
		print_export(shell->env);
		return (0);
	}
	i = 1;
	while (args[i])
	{
		equal = ft_strchr(args[i], '=');
		if (equal)
		{
			*equal = '\0';
			set_env_value(&shell->env, args[i], equal + 1);
			*equal = '=';
		}
		else
			set_env_value(&shell->env, args[i], "");
		i++;
	}
	return (0);
}
