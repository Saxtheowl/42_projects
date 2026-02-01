/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtin_cd.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	update_pwd(t_shell *shell)
{
	char	*cwd;
	char	*oldpwd;

	oldpwd = get_env_value(shell, "PWD");
	if (oldpwd)
		set_env_value(shell, "OLDPWD", oldpwd);
	cwd = getcwd(NULL, 0);
	if (cwd)
	{
		set_env_value(shell, "PWD", cwd);
		free(cwd);
	}
	return (0);
}

int	builtin_cd(t_cmd *cmd, t_shell *shell)
{
	char	*path;

	if (cmd->argc == 1)
	{
		path = get_env_value(shell, "HOME");
		if (!path)
		{
			fprintf(stderr, "minishell: cd: HOME not set\n");
			return (1);
		}
	}
	else if (cmd->argc == 2 && ft_strcmp(cmd->args[1], "-") == 0)
	{
		path = get_env_value(shell, "OLDPWD");
		if (!path)
		{
			fprintf(stderr, "minishell: cd: OLDPWD not set\n");
			return (1);
		}
		printf("%s\n", path);
	}
	else
		path = cmd->args[1];
	if (chdir(path) < 0)
	{
		fprintf(stderr, "minishell: cd: %s: %s\n", path, strerror(errno));
		return (1);
	}
	return (update_pwd(shell));
}
