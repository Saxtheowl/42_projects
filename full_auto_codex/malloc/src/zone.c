#include "malloc_internal.h"

#include <sys/mman.h>
#include <unistd.h>
#include <string.h>

static t_block	*zone_first_block(t_zone *zone)
{
	return (t_block *)((char *)zone + sizeof(t_zone));
}

t_zone	*create_zone(size_t allocation_size)
{
	t_zone	*zone;
	size_t	capacity;

	capacity = allocation_size;
	zone = mmap(
			NULL,
			capacity,
			PROT_READ | PROT_WRITE,
			MAP_PRIVATE | MAP_ANONYMOUS,
			-1,
			0
			);
	if (zone == MAP_FAILED)
		return NULL;
	zone->capacity = capacity;
	zone->next = NULL;
	zone->blocks = zone_first_block(zone);
	memset(zone->blocks, 0, sizeof(t_block));
	zone->blocks->size = capacity - sizeof(t_zone) - sizeof(t_block);
	zone->blocks->free = true;
	zone->blocks->next = NULL;
	zone->blocks->prev = NULL;
	return zone;
}

void	add_zone(t_zone **head, t_zone *zone)
{
	if (!zone)
		return ;
	zone->next = *head;
	*head = zone;
}

void	split_block(t_block *block, size_t size)
{
	size_t	aligned;
	size_t	remaining;
	t_block	*new_block;
	char	*data;

	if (!block)
		return ;
	aligned = align_size(size);
	remaining = block->size;
	if (aligned > remaining)
		return ;
	if (remaining - aligned <= sizeof(t_block) + MIN_SPLIT_SIZE)
	{
		block->free = false;
		return ;
	}
	data = (char *)(block + 1);
	new_block = (t_block *)(data + aligned);
	memset(new_block, 0, sizeof(t_block));
	new_block->size = remaining - aligned - sizeof(t_block);
	new_block->free = true;
	new_block->next = block->next;
	new_block->prev = block;
	if (new_block->next)
		new_block->next->prev = new_block;
	block->size = aligned;
	block->free = false;
	block->next = new_block;
}

static void	merge_with_next(t_block *block)
{
	t_block	*next;

	while (block && block->next)
	{
		next = block->next;
		if (!next->free)
			break ;
		block->size += sizeof(t_block) + next->size;
		block->next = next->next;
		if (block->next)
			block->next->prev = block;
	}
}

void	coalesce(t_block *block)
{
	if (!block)
		return ;
	if (block->prev && block->prev->free)
	{
		block = block->prev;
		merge_with_next(block);
	}
	else
	{
		merge_with_next(block);
	}
}

bool	zone_is_empty(const t_zone *zone)
{
	t_block	*current;

	if (!zone)
		return false;
	current = zone->blocks;
	while (current)
	{
		if (!current->free)
			return false;
		current = current->next;
	}
	return true;
}

void	remove_empty_zone(t_zone **head, t_zone *zone)
{
	t_zone	*iter;
	t_zone	*prev;

	if (!head || !zone)
		return ;
	if (!zone_is_empty(zone))
		return ;
	iter = *head;
	prev = NULL;
	while (iter)
	{
		if (iter == zone)
		{
			if (prev)
				prev->next = iter->next;
			else
				*head = iter->next;
			munmap(iter, iter->capacity);
			return ;
		}
		prev = iter;
		iter = iter->next;
	}
}

t_block	*find_block(t_zone *zone, size_t size)
{
	t_block	*current;
	size_t	aligned;

	if (!zone)
		return NULL;
	aligned = align_size(size);
	current = zone->blocks;
	while (current)
	{
		if (current->free && current->size >= aligned)
		{
			split_block(current, aligned);
			current->free = false;
			return current;
		}
		current = current->next;
	}
	return NULL;
}

t_block	*reuse_block(t_zone **zone_head, size_t size)
{
	t_zone	*zone;
	t_block	*block;
	size_t	allocation_size;

	if (!zone_head)
		return NULL;
	zone = *zone_head;
	while (zone)
	{
		block = find_block(zone, size);
		if (block)
			return block;
		zone = zone->next;
	}
	allocation_size = get_zone_allocation_size(size);
	zone = create_zone(allocation_size);
	if (!zone)
		return NULL;
	add_zone(zone_head, zone);
	return find_block(zone, size);
}
