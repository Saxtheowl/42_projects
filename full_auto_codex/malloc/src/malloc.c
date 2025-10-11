#include "malloc_internal.h"

#include <sys/mman.h>
#include <string.h>

static void	*allocate_large(size_t size)
{
	t_large	*block;
	size_t	aligned;
	size_t	request;

	aligned = align_size(size);
	request = aligned + sizeof(t_large);
	if (g_state.page_size)
	{
		size_t	page = g_state.page_size;
		request = ((request + page - 1) / page) * page;
	}
	block = mmap(
			NULL,
			request,
			PROT_READ | PROT_WRITE,
			MAP_PRIVATE | MAP_ANONYMOUS,
			-1,
			0
			);
	if (block == MAP_FAILED)
		return NULL;
	block->size = aligned;
	block->map_size = request;
	block->prev = NULL;
	block->next = g_state.large;
	if (g_state.large)
		g_state.large->prev = block;
	g_state.large = block;
	return (void *)(block + 1);
}

void	*malloc(size_t size)
{
	t_block	*block;
	t_zone	**zone_head;
	void	*result;

	if (size == 0)
		size = ALIGNMENT;
	pthread_mutex_lock(&g_state.lock);
	malloc_init();
	if (size > SMALL_MAX_ALLOC)
	{
		result = allocate_large(size);
		pthread_mutex_unlock(&g_state.lock);
		return result;
	}
	zone_head = get_zone_list_ref(size);
	block = reuse_block(zone_head, size);
	if (!block)
	{
		pthread_mutex_unlock(&g_state.lock);
		return NULL;
	}
	block->free = false;
	pthread_mutex_unlock(&g_state.lock);
	return (void *)(block + 1);
}
