/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   path.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	is_executable(char *path)
{
	struct stat	st;

	if (stat(path, &st) < 0)
		return (0);
	if (S_ISDIR(st.st_mode))
		return (0);
	if (access(path, X_OK) == 0)
		return (1);
	return (0);
}

static char	*search_in_path(char *cmd, char *path_env)
{
	char	**paths;
	char	*full_path;
	char	*tmp;
	int		i;

	paths = ft_split(path_env, ':');
	if (!paths)
		return (NULL);
	i = 0;
	while (paths[i])
	{
		tmp = ft_strjoin(paths[i], "/");
		full_path = ft_strjoin(tmp, cmd);
		free(tmp);
		if (is_executable(full_path))
		{
			ft_free_split(paths);
			return (full_path);
		}
		free(full_path);
		i++;
	}
	ft_free_split(paths);
	return (NULL);
}

char	*find_command(char *cmd, t_shell *shell)
{
	char	*path_env;

	if (!cmd || !*cmd)
		return (NULL);
	if (strchr(cmd, '/'))
	{
		if (is_executable(cmd))
			return (ft_strdup(cmd));
		return (NULL);
	}
	path_env = get_env_value(shell, "PATH");
	if (!path_env)
		return (NULL);
	return (search_in_path(cmd, path_env));
}
