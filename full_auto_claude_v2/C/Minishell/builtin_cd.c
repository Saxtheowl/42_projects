/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtin_cd.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

int	builtin_cd(char **args, t_shell *shell)
{
	char	*path;
	char	cwd[1024];

	if (!args[1])
	{
		path = get_env_value(shell->env, "HOME");
		if (!path)
		{
			error_msg("cd: HOME not set");
			return (1);
		}
	}
	else
		path = args[1];
	if (chdir(path) == -1)
	{
		error_cmd("cd", strerror(errno));
		return (1);
	}
	if (getcwd(cwd, sizeof(cwd)))
		set_env_value(&shell->env, "PWD", cwd);
	return (0);
}
