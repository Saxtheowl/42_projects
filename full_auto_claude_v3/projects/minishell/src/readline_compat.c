/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   readline_compat.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef USE_READLINE

#include "minishell.h"

#define READLINE_BUFSIZE 4096

char	*readline(const char *prompt)
{
	char	*line;
	char	*newline;
	size_t	len;

	if (prompt)
		printf("%s", prompt);
	fflush(stdout);
	line = malloc(READLINE_BUFSIZE);
	if (!line)
		return (NULL);
	if (fgets(line, READLINE_BUFSIZE, stdin) == NULL)
	{
		free(line);
		return (NULL);
	}
	len = strlen(line);
	if (len > 0 && line[len - 1] == '\n')
		line[len - 1] = '\0';
	newline = ft_strdup(line);
	free(line);
	return (newline);
}

void	rl_on_new_line(void)
{
}

void	rl_replace_line(const char *text, int clear_undo)
{
	(void)text;
	(void)clear_undo;
}

void	rl_redisplay(void)
{
}

#endif
