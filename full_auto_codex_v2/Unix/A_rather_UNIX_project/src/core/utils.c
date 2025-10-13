#include "malloc_internal.h"

#include <sys/mman.h>

#ifndef MAP_ANON
# define MAP_ANON MAP_ANONYMOUS
#endif

static size_t	align_up(size_t size)
{
	return ((size + (ALIGNMENT - 1)) & ~(ALIGNMENT - 1));
}

static size_t	zone_allocation_size(t_zone_type type, size_t requested, size_t page_size)
{
	size_t	limit;
	size_t	overhead;
	size_t	blocks;
	size_t	total;

	overhead = sizeof(t_zone) + sizeof(t_block);
	if (type == ZONE_LARGE)
	{
		total = overhead + align_up(requested);
		return (align_up(total + page_size - 1) / page_size * page_size);
	}
	limit = (type == ZONE_TINY) ? TINY_MAX_SIZE : SMALL_MAX_SIZE;
	blocks = MIN_BLOCKS_PER_ZONE;
	total = overhead + (limit + sizeof(t_block)) * blocks;
	total = align_up(total);
	if (total % page_size != 0)
		total += page_size - (total % page_size);
	return (total);
}

void	zone_add(t_zone **list, t_zone *zone)
{
	zone->prev = NULL;
	zone->next = *list;
	if (*list != NULL)
		(*list)->prev = zone;
	*list = zone;
}

void	zone_remove(t_zone **list, t_zone *zone)
{
	if (zone->prev != NULL)
		zone->prev->next = zone->next;
	else
		*list = zone->next;
	if (zone->next != NULL)
		zone->next->prev = zone->prev;
}

static t_block	*init_first_block(t_zone *zone)
{
	t_block	*block;
	size_t	available;

	block = (t_block *)((unsigned char *)zone + sizeof(t_zone));
	available = zone->size - sizeof(t_zone) - sizeof(t_block);
	block->size = available;
	block->free = 1;
	block->prev = NULL;
	block->next = NULL;
	zone->first = block;
	zone->used = 0;
	return (block);
}

t_zone	*create_zone(t_zone_type type, size_t size)
{
	size_t	total;
	t_zone	*zone;

	total = zone_allocation_size(type, size, g_malloc_state.page_size);
	zone = mmap(NULL, total, PROT_READ | PROT_WRITE, MAP_ANON | MAP_PRIVATE, -1, 0);
	if (zone == MAP_FAILED)
		return (NULL);
	zone->size = total;
	zone->type = type;
	zone->prev = NULL;
	zone->next = NULL;
	zone->used = 0;
	zone->first = NULL;
	init_first_block(zone);
	return (zone);
}

size_t	aligned_request(size_t size)
{
	if (size == 0)
		size = ALIGNMENT;
	return (align_up(size));
}

int	block_can_split(t_block *block, size_t size)
{
	return (block->size >= size + sizeof(t_block) + ALIGNMENT);
}

void	split_block(t_zone *zone, t_block *block, size_t size)
{
	t_block	*new_block;

	if (!block_can_split(block, size))
		return ;
	new_block = (t_block *)((unsigned char *)(block + 1) + size);
	new_block->size = block->size - size - sizeof(t_block);
	new_block->free = 1;
	new_block->prev = block;
	new_block->next = block->next;
	if (new_block->next)
		new_block->next->prev = new_block;
	block->next = new_block;
	block->size = size;
	(void)zone;
}

void	coalesce_block(t_zone *zone, t_block *block)
{
	if (block->next && block->next->free)
	{
		block->size += sizeof(t_block) + block->next->size;
		block->next = block->next->next;
		if (block->next)
			block->next->prev = block;
	}
	if (block->prev && block->prev->free)
	{
		block->prev->size += sizeof(t_block) + block->size;
		block->prev->next = block->next;
		if (block->next)
			block->next->prev = block->prev;
		block = block->prev;
	}
	(void)zone;
}

int	zone_empty(const t_zone *zone)
{
	t_block	*block;

	block = zone->first;
	while (block != NULL)
	{
		if (!block->free)
			return (0);
		block = block->next;
	}
	return (1);
}

void	release_zone(t_zone **list, t_zone *zone)
{
	zone_remove(list, zone);
	munmap(zone, zone->size);
}
