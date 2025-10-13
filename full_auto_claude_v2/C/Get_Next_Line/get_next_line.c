/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_next_line.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: auto-generated <noreply@anthropic.com>     +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by auto-gen          #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by auto-gen         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "get_next_line.h"

static char	*extract_line(char *buffer)
{
	char	*line;
	int		i;

	i = 0;
	if (!buffer[i])
		return (NULL);
	while (buffer[i] && buffer[i] != '\n')
		i++;
	line = (char *)malloc(sizeof(char) * (i + 2));
	if (!line)
		return (NULL);
	i = 0;
	while (buffer[i] && buffer[i] != '\n')
	{
		line[i] = buffer[i];
		i++;
	}
	if (buffer[i] == '\n')
	{
		line[i] = buffer[i];
		i++;
	}
	line[i] = '\0';
	return (line);
}

static char	*update_buffer(char *buffer)
{
	char	*new_buffer;
	int		i;
	int		j;

	i = 0;
	while (buffer[i] && buffer[i] != '\n')
		i++;
	if (!buffer[i])
	{
		free(buffer);
		return (NULL);
	}
	new_buffer = (char *)malloc(sizeof(char) * (ft_strlen(buffer) - i + 1));
	if (!new_buffer)
		return (NULL);
	i++;
	j = 0;
	while (buffer[i])
		new_buffer[j++] = buffer[i++];
	new_buffer[j] = '\0';
	free(buffer);
	return (new_buffer);
}

static char	*read_and_store(int fd, char *buffer)
{
	char	*temp_buffer;
	int		bytes_read;

	temp_buffer = malloc(sizeof(char) * (BUFFER_SIZE + 1));
	if (!temp_buffer)
		return (NULL);
	bytes_read = 1;
	while (!ft_strchr(buffer, '\n') && bytes_read != 0)
	{
		bytes_read = read(fd, temp_buffer, BUFFER_SIZE);
		if (bytes_read == -1)
		{
			free(temp_buffer);
			return (NULL);
		}
		temp_buffer[bytes_read] = '\0';
		buffer = ft_strjoin(buffer, temp_buffer);
	}
	free(temp_buffer);
	return (buffer);
}

char	*get_next_line(int fd)
{
	static char	*buffer;
	char		*line;

	if (fd < 0 || BUFFER_SIZE <= 0)
		return (NULL);
	buffer = read_and_store(fd, buffer);
	if (!buffer)
		return (NULL);
	line = extract_line(buffer);
	buffer = update_buffer(buffer);
	return (line);
}
