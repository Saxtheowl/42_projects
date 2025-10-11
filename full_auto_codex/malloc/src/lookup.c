#include "malloc_internal.h"

#include <stdbool.h>
#include <sys/mman.h>

bool	find_block_in_zone_list(t_zone *zone, void *ptr, t_zone **zone_out, t_block **block_out)
{
	t_block	*block;

	while (zone)
	{
		block = zone->blocks;
		while (block)
		{
			if ((void *)(block + 1) == ptr)
			{
				if (zone_out)
					*zone_out = zone;
				if (block_out)
					*block_out = block;
				return true;
			}
			block = block->next;
		}
		zone = zone->next;
	}
	return false;
}

bool	find_block_in_zones(void *ptr, t_zone **zone_out, t_block **block_out)
{
	if (find_block_in_zone_list(g_state.tiny, ptr, zone_out, block_out))
		return true;
	if (find_block_in_zone_list(g_state.small, ptr, zone_out, block_out))
		return true;
	return false;
}

t_large	*find_large_block(void *ptr)
{
	t_large	*current;

	current = g_state.large;
	while (current)
	{
		if ((void *)(current + 1) == ptr)
			return current;
		current = current->next;
	}
	return NULL;
}

void	remove_large_block(t_large *block)
{
	if (!block)
		return ;
	if (block->prev)
		block->prev->next = block->next;
	else
		g_state.large = block->next;
	if (block->next)
		block->next->prev = block->prev;
	munmap(block, block->map_size);
}
