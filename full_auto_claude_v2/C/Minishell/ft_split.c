/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_split.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	count_words(char const *s, char c)
{
	int	count;
	int	in_word;

	count = 0;
	in_word = 0;
	while (*s)
	{
		if (*s != c && !in_word)
		{
			in_word = 1;
			count++;
		}
		else if (*s == c)
			in_word = 0;
		s++;
	}
	return (count);
}

static char	*get_next_word(char const *s, char c, int *index)
{
	int		start;
	int		len;
	char	*word;

	while (s[*index] && s[*index] == c)
		(*index)++;
	start = *index;
	len = 0;
	while (s[*index] && s[*index] != c)
	{
		len++;
		(*index)++;
	}
	word = ft_substr(s, start, len);
	return (word);
}

char	**ft_split(char const *s, char c)
{
	char	**result;
	int		words;
	int		i;
	int		index;

	if (!s)
		return (NULL);
	words = count_words(s, c);
	result = malloc(sizeof(char *) * (words + 1));
	if (!result)
		return (NULL);
	i = 0;
	index = 0;
	while (i < words)
	{
		result[i] = get_next_word(s, c, &index);
		if (!result[i])
		{
			ft_free_split(result);
			return (NULL);
		}
		i++;
	}
	result[i] = NULL;
	return (result);
}
