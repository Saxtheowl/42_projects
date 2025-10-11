#ifndef MALLOC_INTERNAL_H
#define MALLOC_INTERNAL_H

#include <pthread.h>
#include <stddef.h>
#include <stdbool.h>

#include "malloc.h"

#define ALIGNMENT 16
#define MIN_SPLIT_SIZE 32

#define TINY_MAX_ALLOC 64
#define SMALL_MAX_ALLOC 1024

typedef struct s_block
{
	size_t				size;
	bool				free;
	struct s_block		*next;
	struct s_block		*prev;
}	t_block;

typedef struct s_zone
{
	size_t				capacity;
	struct s_zone		*next;
	t_block				*blocks;
}	t_zone;

typedef struct s_large
{
	size_t				size;
	size_t				map_size;
	struct s_large		*next;
	struct s_large		*prev;
}	t_large;

typedef struct s_malloc_state
{
	t_zone				*tiny;
	t_zone				*small;
	t_large				*large;
	pthread_mutex_t		lock;
	size_t				page_size;
	size_t				tiny_zone_size;
	size_t				small_zone_size;
	bool				initialised;
}	t_malloc_state;

extern t_malloc_state	g_state;

size_t		align_size(size_t size);
void		malloc_init(void);

t_zone		*get_zone_list(size_t size);
t_zone		**get_zone_list_ref(size_t size);
size_t		get_zone_allocation_size(size_t size);
t_zone		**zone_head_from_zone(t_zone *zone);

t_zone		*create_zone(size_t allocation_size);
void		add_zone(t_zone **head, t_zone *zone);
t_block	*find_block(t_zone *zone, size_t size);
t_block	*reuse_block(t_zone **zone_head, size_t size);
void		split_block(t_block *block, size_t size);
void		coalesce(t_block *block);
void		remove_empty_zone(t_zone **head, t_zone *zone);
bool		zone_is_empty(const t_zone *zone);

t_block	*ptr_to_block(void *ptr);
bool		is_pointer_in_zone(const t_zone *zone, void *ptr);
bool		find_block_in_zones(void *ptr, t_zone **zone_out, t_block **block_out);
t_large	*find_large_block(void *ptr);
void		remove_large_block(t_large *block);

void		show_print_str(const char *str);
void		show_print_hex(unsigned long value);
void		show_print_size(size_t value);

#endif
