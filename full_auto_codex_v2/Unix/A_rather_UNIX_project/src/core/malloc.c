#include "malloc_internal.h"

#include <sys/mman.h>
#include <unistd.h>

static t_zone	**select_zone_list_ptr(size_t size)
{
	if (size <= TINY_MAX_SIZE)
		return (&g_malloc_state.tiny);
	if (size <= SMALL_MAX_SIZE)
		return (&g_malloc_state.small);
	return (&g_malloc_state.large);
}

static t_zone_type	zone_type_for_size(size_t size)
{
	if (size <= TINY_MAX_SIZE)
		return (ZONE_TINY);
	if (size <= SMALL_MAX_SIZE)
		return (ZONE_SMALL);
	return (ZONE_LARGE);
}

static void	*block_allocate(t_zone *zone, t_block *block, size_t size)
{
	if (block_can_split(block, size))
		split_block(zone, block, size);
	block->free = 0;
	zone->used += block->size;
	return (block + 1);
}

static t_block	*find_free_block(t_zone *zone, size_t size)
{
	t_block	*block;

	block = zone->first;
	while (block)
	{
		if (block->free && block->size >= size)
			return (block);
		block = block->next;
	}
	return (NULL);
}

static void	identify_zone_for_pointer(void *ptr, t_zone **out_zone, t_zone ***out_list)
{
	t_zone	*zone;

	zone = g_malloc_state.tiny;
	while (zone)
	{
		unsigned char	*start;
		unsigned char	*end;

		start = (unsigned char *)zone;
		end = start + zone->size;
		if ((unsigned char *)ptr > start && (unsigned char *)ptr < end)
		{
			*out_zone = zone;
			*out_list = &g_malloc_state.tiny;
			return ;
		}
		zone = zone->next;
	}
	zone = g_malloc_state.small;
	while (zone)
	{
		unsigned char	*start;
		unsigned char	*end;

		start = (unsigned char *)zone;
		end = start + zone->size;
		if ((unsigned char *)ptr > start && (unsigned char *)ptr < end)
		{
			*out_zone = zone;
			*out_list = &g_malloc_state.small;
			return ;
		}
		zone = zone->next;
	}
	zone = g_malloc_state.large;
	while (zone)
	{
		unsigned char	*start;
		unsigned char	*end;

		start = (unsigned char *)zone;
		end = start + zone->size;
		if ((unsigned char *)ptr > start && (unsigned char *)ptr < end)
		{
			*out_zone = zone;
			*out_list = &g_malloc_state.large;
			return ;
		}
		zone = zone->next;
	}
	*out_zone = NULL;
	*out_list = NULL;
}

static void	*allocate_from_zone_list(size_t size)
{
	t_zone	**list_ptr;
	t_zone	*zone;
	t_block	*block;
	t_zone_type	ztype;

	list_ptr = select_zone_list_ptr(size);
	zone = *list_ptr;
	while (zone)
	{
		block = find_free_block(zone, size);
		if (block)
			return (block_allocate(zone, block, size));
		zone = zone->next;
	}
	ztype = zone_type_for_size(size);
	zone = create_zone(ztype, size);
	if (zone == NULL)
		return (NULL);
	zone_add(list_ptr, zone);
	return (block_allocate(zone, zone->first, size));
}

void	*malloc(size_t size)
{
	void	*result;
	size_t	aligned;

	malloc_state_init();
	aligned = aligned_request(size);
	malloc_lock();
	result = allocate_from_zone_list(aligned);
	malloc_unlock();
	return (result);
}

static t_block	*block_from_ptr_checked(void *ptr, t_zone **zone, t_zone ***list_ptr)
{
	t_block	*block;

	if (ptr == NULL)
		return (NULL);
	block = (t_block *)((unsigned char *)ptr - sizeof(t_block));
	identify_zone_for_pointer(ptr, zone, list_ptr);
	if (*zone == NULL)
		return (NULL);
	if ((unsigned char *)block < (unsigned char *)(*zone + 1))
		return (NULL);
	return (block);
}

void	free(void *ptr)
{
	t_zone	*zone;
	t_zone	**list_ptr;
	t_block	*block;

	if (ptr == NULL)
		return ;
	malloc_lock();
	block = block_from_ptr_checked(ptr, &zone, &list_ptr);
	if (block == NULL || list_ptr == NULL)
	{
		malloc_unlock();
		return ;
	}
	if (!block->free)
	{
		zone->used -= block->size;
		block->free = 1;
		coalesce_block(zone, block);
		if (zone->type == ZONE_LARGE || zone_empty(zone))
			release_zone(list_ptr, zone);
	}
	malloc_unlock();
}

static void	copy_memory(unsigned char *dst, const unsigned char *src, size_t size)
{
	size_t	index;

	index = 0;
	while (index < size)
	{
		dst[index] = src[index];
		index++;
	}
}

void	*realloc(void *ptr, size_t size)
{
	t_block	*block;
	void	*new_ptr;
	size_t	new_size;
	size_t	copy_size;
	t_zone	*zone;
	t_zone	**list_ptr;

	if (ptr == NULL)
		return (malloc(size));
	if (size == 0)
	{
		free(ptr);
		return (NULL);
	}
	new_size = aligned_request(size);
	malloc_lock();
	block = block_from_ptr_checked(ptr, &zone, &list_ptr);
	if (block == NULL)
	{
		malloc_unlock();
		return (NULL);
	}
	if (block->size >= new_size)
	{
		if (block_can_split(block, new_size))
			split_block(zone, block, new_size);
		malloc_unlock();
		return (ptr);
	}
	new_ptr = allocate_from_zone_list(new_size);
	if (new_ptr == NULL)
	{
		malloc_unlock();
		return (NULL);
	}
	copy_size = block->size;
	copy_memory((unsigned char *)new_ptr, (const unsigned char *)ptr, copy_size);
	zone->used -= block->size;
	block->free = 1;
	coalesce_block(zone, block);
	if (zone->type == ZONE_LARGE)
		release_zone(list_ptr, zone);
	malloc_unlock();
	return (new_ptr);
}

void	show_alloc_mem(void)
{
	malloc_lock();
	show_alloc_zones();
	malloc_unlock();
}
