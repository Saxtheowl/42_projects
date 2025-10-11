#include "malloc_internal.h"

#include <sys/mman.h>

static void	free_block(t_zone **zone_head, t_zone *zone, t_block *block)
{
	block->free = true;
	coalesce(block);
	remove_empty_zone(zone_head, zone);
}

void	free(void *ptr)
{
	t_zone	*zone;
	t_block	*block;
	t_zone	**zone_head;
	t_large	*large;

	if (!ptr)
		return ;
	pthread_mutex_lock(&g_state.lock);
	if (find_block_in_zones(ptr, &zone, &block))
	{
		zone_head = zone_head_from_zone(zone);
		free_block(zone_head, zone, block);
		pthread_mutex_unlock(&g_state.lock);
		return ;
	}
	large = find_large_block(ptr);
	if (large)
	{
		remove_large_block(large);
		pthread_mutex_unlock(&g_state.lock);
		return ;
	}
	pthread_mutex_unlock(&g_state.lock);
}
