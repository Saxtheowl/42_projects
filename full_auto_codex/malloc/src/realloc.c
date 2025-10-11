#include "malloc_internal.h"

#include <string.h>

static void shrink_block(t_block *block, size_t aligned)
{
	t_block	*new_block;
	char	*data;
	size_t	extra;

	if (!block)
		return ;
	if (block->size <= aligned)
		return ;
	extra = block->size - aligned;
	if (extra <= sizeof(t_block) + MIN_SPLIT_SIZE)
	{
		block->size = aligned + extra;
		return ;
	}
	data = (char *)(block + 1);
	new_block = (t_block *)(data + aligned);
	new_block->size = extra - sizeof(t_block);
	new_block->free = true;
	new_block->next = block->next;
	new_block->prev = block;
	if (new_block->next)
		new_block->next->prev = new_block;
	block->size = aligned;
	block->next = new_block;
	coalesce(new_block);
}

static bool try_extend_block(t_block *block, size_t aligned)
{
	size_t	total;
	t_block	*next;

	if (block->size >= aligned)
	{
		shrink_block(block, aligned);
		return true;
	}
	total = block->size;
	while (block->next && block->next->free && total < aligned)
	{
		next = block->next;
		total += sizeof(t_block) + next->size;
		block->next = next->next;
		if (block->next)
			block->next->prev = block;
	}
	if (total >= aligned)
	{
		block->size = total;
		shrink_block(block, aligned);
		return true;
	}
	return false;
}

static void *realloc_zone_block(void *ptr, t_zone *zone, t_block *block, size_t size)
{
	size_t	aligned;
	size_t	copy_size;
	void	*new_ptr;

	(void)zone;
	aligned = align_size(size);
	if (try_extend_block(block, aligned))
	{
		block->free = false;
		pthread_mutex_unlock(&g_state.lock);
		return ptr;
	}
	copy_size = block->size < aligned ? block->size : aligned;
	pthread_mutex_unlock(&g_state.lock);
	new_ptr = malloc(size);
	if (!new_ptr)
		return NULL;
	memcpy(new_ptr, ptr, copy_size);
	free(ptr);
	return new_ptr;
}

static void *realloc_large_block(void *ptr, t_large *large, size_t size)
{
	size_t	aligned;
	size_t	copy_size;
	void	*new_ptr;

	aligned = align_size(size);
	if (aligned <= large->size)
	{
		large->size = aligned;
		pthread_mutex_unlock(&g_state.lock);
		return ptr;
	}
	copy_size = large->size < aligned ? large->size : aligned;
	pthread_mutex_unlock(&g_state.lock);
	new_ptr = malloc(size);
	if (!new_ptr)
		return NULL;
	memcpy(new_ptr, ptr, copy_size);
	free(ptr);
	return new_ptr;
}

void *realloc(void *ptr, size_t size)
{
	t_zone	*zone;
	t_block	*block;
	t_large	*large;

	if (!ptr)
		return malloc(size);
	if (size == 0)
	{
		free(ptr);
		return NULL;
	}
	pthread_mutex_lock(&g_state.lock);
	malloc_init();
	if (find_block_in_zones(ptr, &zone, &block))
		return realloc_zone_block(ptr, zone, block, size);
	large = find_large_block(ptr);
	if (large)
		return realloc_large_block(ptr, large, size);
	pthread_mutex_unlock(&g_state.lock);
	return NULL;
}
