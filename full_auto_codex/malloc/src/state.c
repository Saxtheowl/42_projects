#include "malloc_internal.h"

#include <sys/mman.h>
#include <unistd.h>

t_malloc_state	g_state = {
	.tiny = NULL,
	.small = NULL,
	.large = NULL,
	.lock = PTHREAD_MUTEX_INITIALIZER,
	.page_size = 0,
	.tiny_zone_size = 0,
	.small_zone_size = 0,
	.initialised = false
};

static size_t	zone_capacity_for(size_t max_alloc, size_t page_size)
{
	size_t	per_block;
	size_t	required;
	size_t	pages;

	per_block = align_size(max_alloc) + sizeof(t_block);
	required = sizeof(t_zone) + per_block * 100;
	pages = (required + page_size - 1) / page_size;
	return pages * page_size;
}

void	malloc_init(void)
{
	if (g_state.initialised)
		return ;
	g_state.page_size = (size_t)getpagesize();
	if (g_state.page_size == 0)
		g_state.page_size = 4096;
	g_state.tiny_zone_size = zone_capacity_for(TINY_MAX_ALLOC, g_state.page_size);
	g_state.small_zone_size = zone_capacity_for(SMALL_MAX_ALLOC, g_state.page_size);
	g_state.initialised = true;
}
