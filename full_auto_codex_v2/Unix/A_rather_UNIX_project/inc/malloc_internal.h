#ifndef MALLOC_INTERNAL_H
#define MALLOC_INTERNAL_H

#include <stddef.h>
#include <pthread.h>

#include "libft.h"

#define ALIGNMENT 16UL
#define MIN_BLOCKS_PER_ZONE 100UL
#define TINY_MAX_SIZE 128UL
#define SMALL_MAX_SIZE 1024UL

typedef enum e_zone_type
{
	ZONE_TINY = 0,
	ZONE_SMALL = 1,
	ZONE_LARGE = 2
}	t_zone_type;

typedef struct s_block
{
	size_t			size;
	int				free;
	struct s_block	*prev;
	struct s_block	*next;
}	t_block;

typedef struct s_zone
{
	struct s_zone	*prev;
	struct s_zone	*next;
	size_t			size;
	size_t			used;
	t_zone_type		type;
	t_block			*first;
}	t_zone;

typedef struct s_malloc_state
{
	t_zone			*tiny;
	t_zone			*small;
	t_zone			*large;
	size_t			page_size;
	pthread_mutex_t	mutex;
	int				mutex_ready;
}	t_malloc_state;

extern t_malloc_state	g_malloc_state;

void	malloc_state_init(void);
void	malloc_lock(void);
void	malloc_unlock(void);

size_t	aligned_request(size_t size);
t_zone	*create_zone(t_zone_type type, size_t size);
void	zone_add(t_zone **list, t_zone *zone);
void	release_zone(t_zone **list, t_zone *zone);
int		zone_empty(const t_zone *zone);
void	split_block(t_zone *zone, t_block *block, size_t size);
void	coalesce_block(t_zone *zone, t_block *block);
int		block_can_split(t_block *block, size_t size);

void	*malloc_find_block(size_t size);
void	free_block(void *ptr);
void	*realloc_block(void *ptr, size_t size);

void	show_alloc_zones(void);

#endif
