#include "malloc_internal.h"

t_zone	*get_zone_list(size_t size)
{
	if (size <= TINY_MAX_ALLOC)
		return g_state.tiny;
	if (size <= SMALL_MAX_ALLOC)
		return g_state.small;
	return NULL;
}

t_zone	**get_zone_list_ref(size_t size)
{
	if (size <= TINY_MAX_ALLOC)
		return &g_state.tiny;
	if (size <= SMALL_MAX_ALLOC)
		return &g_state.small;
	return NULL;
}

size_t	get_zone_allocation_size(size_t size)
{
	(void)size;
	if (size <= TINY_MAX_ALLOC)
		return g_state.tiny_zone_size;
	return g_state.small_zone_size;
}

t_zone	**zone_head_from_zone(t_zone *zone)
{
	if (!zone)
		return NULL;
	if (zone->capacity == g_state.tiny_zone_size)
		return &g_state.tiny;
	if (zone->capacity == g_state.small_zone_size)
		return &g_state.small;
	return NULL;
}
