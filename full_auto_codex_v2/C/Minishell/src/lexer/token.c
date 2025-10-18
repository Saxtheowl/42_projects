#include "token.h"
#include <stdlib.h>
#include <string.h>

t_token	*token_new(t_token_type type, const char *value, int quoted)
{
	t_token	*node;

	node = malloc(sizeof(*node));
	if (!node)
		return (NULL);
	node->type = type;
	if (value)
	{
		node->value = strdup(value);
		if (!node->value)
		{
			free(node);
			return (NULL);
		}
	}
	else
		node->value = NULL;
	node->quoted = quoted;
	node->next = NULL;
	return (node);
}

void	token_append(t_token **list, t_token *node)
{
	t_token	*iter;

	if (!node)
		return ;
	if (!list || !*list)
	{
		if (list)
			*list = node;
		return ;
	}
	iter = *list;
	while (iter->next)
		iter = iter->next;
	iter->next = node;
}

void	token_clear(t_token **list)
{
	t_token	*tmp;

	if (!list)
		return ;
	while (*list)
	{
		tmp = (*list)->next;
		free((*list)->value);
		free(*list);
		*list = tmp;
	}
}

size_t	token_count(const t_token *list)
{
	size_t	count;

	count = 0;
	while (list)
	{
		count++;
		list = list->next;
	}
	return (count);
}
