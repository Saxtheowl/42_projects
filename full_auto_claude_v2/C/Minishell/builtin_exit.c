/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtin_exit.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	is_numeric(char *str)
{
	int	i;

	i = 0;
	if (str[i] == '+' || str[i] == '-')
		i++;
	while (str[i])
	{
		if (str[i] < '0' || str[i] > '9')
			return (0);
		i++;
	}
	return (1);
}

int	builtin_exit(char **args, t_shell *shell)
{
	int	exit_code;

	ft_putendl_fd("exit", 2);
	if (args[1])
	{
		if (!is_numeric(args[1]))
		{
			error_msg("exit: numeric argument required");
			exit(255);
		}
		if (args[2])
		{
			error_msg("exit: too many arguments");
			return (1);
		}
		exit_code = ft_atoi(args[1]);
		free_env(shell->env);
		exit(exit_code);
	}
	free_env(shell->env);
	exit(shell->last_exit_status);
}
