#include "libunit.h"

#include <stdlib.h>
#include <string.h>

static t_unit_test	*create_node(const char *name, int (*fn)(void))
{
	t_unit_test	*node;

	node = (t_unit_test *)malloc(sizeof(t_unit_test));
	if (!node)
		return (NULL);
	node->name = NULL;
	node->fn = fn;
	node->next = NULL;
	if (name != NULL)
	{
		node->name = strdup(name);
		if (node->name == NULL)
		{
			free(node);
			return (NULL);
		}
	}
	return (node);
}

int	load_test(t_unit_test **list, const char *name, int (*fn)(void))
{
	t_unit_test	*node;
	t_unit_test	*cursor;

	if (list == NULL || fn == NULL)
		return (-1);
	node = create_node(name, fn);
	if (node == NULL)
		return (-1);
	if (*list == NULL)
	{
		*list = node;
		return (0);
	}
	cursor = *list;
	while (cursor->next != NULL)
		cursor = cursor->next;
	cursor->next = node;
	return (0);
}

void	clear_tests(t_unit_test **list)
{
	t_unit_test	*cursor;
	t_unit_test	*next;

	if (list == NULL)
		return ;
	cursor = *list;
	while (cursor != NULL)
	{
		next = cursor->next;
		free(cursor->name);
		free(cursor);
		cursor = next;
	}
	*list = NULL;
}
