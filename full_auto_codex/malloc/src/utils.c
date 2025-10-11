#include "malloc_internal.h"

#include <stdint.h>

size_t	align_size(size_t size)
{
	if (size == 0)
		return ALIGNMENT;
	if (size % ALIGNMENT == 0)
		return size;
	return size + (ALIGNMENT - (size % ALIGNMENT));
}

t_block	*ptr_to_block(void *ptr)
{
	if (!ptr)
		return NULL;
	return (t_block *)((char *)ptr - sizeof(t_block));
}

bool	is_pointer_in_zone(const t_zone *zone, void *ptr)
{
	char	*base;
	char	*end;

	if (!zone || !ptr)
		return false;
	base = (char *)zone;
	end = base + zone->capacity;
	return (char *)ptr > base && (char *)ptr < end;
}
