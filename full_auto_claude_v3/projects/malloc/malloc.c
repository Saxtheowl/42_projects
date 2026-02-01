/* ************************************************************************** */
/*                                                                            */
/*   ft_malloc - Custom memory allocator                                      */
/*   Implements malloc, free, realloc using mmap                              */
/*                                                                            */
/* ************************************************************************** */

#define _GNU_SOURCE
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>
#include <stdio.h>

/* Size thresholds */
#define TINY_MAX    128
#define SMALL_MAX   1024
#define ZONE_SIZE   ((size_t)getpagesize() * 100)

/* Block header */
typedef struct s_block
{
	size_t			size;
	int				free;
	struct s_block	*next;
	struct s_block	*prev;
}	t_block;

/* Zone header */
typedef struct s_zone
{
	size_t			total_size;
	struct s_zone	*next;
	t_block			*blocks;
}	t_zone;

/* Global state */
typedef struct s_malloc
{
	t_zone			*tiny;
	t_zone			*small;
	t_zone			*large;
	pthread_mutex_t	mutex;
}	t_malloc;

static t_malloc	g_malloc = {NULL, NULL, NULL, PTHREAD_MUTEX_INITIALIZER};

/* Block alignment */
#define ALIGN(size) (((size) + 15) & ~15)
#define BLOCK_SIZE  ALIGN(sizeof(t_block))
#define ZONE_HEADER ALIGN(sizeof(t_zone))

/* ========== Zone Management ========== */

static t_zone	*create_zone(size_t size)
{
	t_zone	*zone;
	size_t	zone_size;

	zone_size = ZONE_HEADER + BLOCK_SIZE + ALIGN(size);
	if (zone_size < ZONE_SIZE)
		zone_size = ZONE_SIZE;

	zone = mmap(NULL, zone_size, PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	if (zone == MAP_FAILED)
		return (NULL);

	zone->total_size = zone_size;
	zone->next = NULL;

	/* Create initial free block */
	zone->blocks = (t_block *)((char *)zone + ZONE_HEADER);
	zone->blocks->size = zone_size - ZONE_HEADER - BLOCK_SIZE;
	zone->blocks->free = 1;
	zone->blocks->next = NULL;
	zone->blocks->prev = NULL;

	return (zone);
}

static t_zone	**get_zone_list(size_t size)
{
	if (size <= TINY_MAX)
		return (&g_malloc.tiny);
	else if (size <= SMALL_MAX)
		return (&g_malloc.small);
	return (&g_malloc.large);
}

/* ========== Block Management ========== */

static t_block	*find_free_block(t_zone *zone, size_t size)
{
	t_block	*block;

	while (zone)
	{
		block = zone->blocks;
		while (block)
		{
			if (block->free && block->size >= size)
				return (block);
			block = block->next;
		}
		zone = zone->next;
	}
	return (NULL);
}

static void	split_block(t_block *block, size_t size)
{
	t_block	*new_block;
	size_t	remaining;

	remaining = block->size - size - BLOCK_SIZE;
	if (remaining < 32)  /* Don't split if too small */
		return;

	new_block = (t_block *)((char *)block + BLOCK_SIZE + size);
	new_block->size = remaining;
	new_block->free = 1;
	new_block->next = block->next;
	new_block->prev = block;

	if (block->next)
		block->next->prev = new_block;
	block->next = new_block;
	block->size = size;
}

static void	coalesce_blocks(t_block *block)
{
	/* Merge with next block if free */
	while (block->next && block->next->free)
	{
		block->size += BLOCK_SIZE + block->next->size;
		block->next = block->next->next;
		if (block->next)
			block->next->prev = block;
	}

	/* Merge with previous block if free */
	while (block->prev && block->prev->free)
	{
		block = block->prev;
		block->size += BLOCK_SIZE + block->next->size;
		block->next = block->next->next;
		if (block->next)
			block->next->prev = block;
	}
}

/* ========== Public API ========== */

void	*ft_malloc(size_t size)
{
	t_zone		**zone_list;
	t_zone		*zone;
	t_block		*block;
	size_t		aligned_size;

	if (size == 0)
		return (NULL);

	pthread_mutex_lock(&g_malloc.mutex);

	aligned_size = ALIGN(size);
	zone_list = get_zone_list(aligned_size);

	/* Try to find existing free block */
	block = find_free_block(*zone_list, aligned_size);

	if (!block)
	{
		/* Create new zone */
		zone = create_zone(aligned_size);
		if (!zone)
		{
			pthread_mutex_unlock(&g_malloc.mutex);
			return (NULL);
		}
		zone->next = *zone_list;
		*zone_list = zone;
		block = zone->blocks;
	}

	/* Split block if too large */
	split_block(block, aligned_size);
	block->free = 0;

	pthread_mutex_unlock(&g_malloc.mutex);

	return ((char *)block + BLOCK_SIZE);
}

static t_block	*get_block(void *ptr)
{
	if (!ptr)
		return (NULL);
	return ((t_block *)((char *)ptr - BLOCK_SIZE));
}

static t_zone	*find_zone(t_zone *zones, t_block *block)
{
	t_zone	*zone;
	char	*start;
	char	*end;

	zone = zones;
	while (zone)
	{
		start = (char *)zone;
		end = start + zone->total_size;
		if ((char *)block >= start && (char *)block < end)
			return (zone);
		zone = zone->next;
	}
	return (NULL);
}

void	ft_free(void *ptr)
{
	t_block	*block;
	t_zone	*zone;
	t_zone	**zone_list;
	t_zone	**prev;

	if (!ptr)
		return;

	pthread_mutex_lock(&g_malloc.mutex);

	block = get_block(ptr);

	/* Find which zone list contains this block */
	zone = find_zone(g_malloc.tiny, block);
	if (zone)
		zone_list = &g_malloc.tiny;
	else
	{
		zone = find_zone(g_malloc.small, block);
		if (zone)
			zone_list = &g_malloc.small;
		else
		{
			zone = find_zone(g_malloc.large, block);
			zone_list = &g_malloc.large;
		}
	}

	if (!zone)
	{
		pthread_mutex_unlock(&g_malloc.mutex);
		return;
	}

	block->free = 1;
	coalesce_blocks(block);

	/* Check if entire zone is free (for large allocations) */
	if (zone_list == &g_malloc.large && zone->blocks->free &&
		!zone->blocks->next)
	{
		/* Remove zone from list and unmap */
		prev = zone_list;
		while (*prev && *prev != zone)
			prev = &(*prev)->next;
		if (*prev)
			*prev = zone->next;
		munmap(zone, zone->total_size);
	}

	pthread_mutex_unlock(&g_malloc.mutex);
}

void	*ft_realloc(void *ptr, size_t size)
{
	t_block	*block;
	void	*new_ptr;
	size_t	copy_size;

	if (!ptr)
		return (ft_malloc(size));

	if (size == 0)
	{
		ft_free(ptr);
		return (NULL);
	}

	block = get_block(ptr);

	/* If current block is large enough, keep it */
	if (block->size >= ALIGN(size))
		return (ptr);

	/* Allocate new block and copy */
	new_ptr = ft_malloc(size);
	if (!new_ptr)
		return (NULL);

	copy_size = block->size < size ? block->size : size;
	memcpy(new_ptr, ptr, copy_size);
	ft_free(ptr);

	return (new_ptr);
}

void	*ft_calloc(size_t count, size_t size)
{
	void	*ptr;
	size_t	total;

	total = count * size;
	if (count != 0 && total / count != size)
		return (NULL);  /* Overflow */

	ptr = ft_malloc(total);
	if (ptr)
		memset(ptr, 0, total);
	return (ptr);
}

/* ========== Debug Functions ========== */

static void	print_zone(const char *name, t_zone *zones)
{
	t_zone	*zone;
	t_block	*block;
	int		zone_num;

	zone_num = 0;
	zone = zones;
	while (zone)
	{
		printf("%s zone %d (size: %zu bytes):\n", name, zone_num++,
			   zone->total_size);

		block = zone->blocks;
		while (block)
		{
			printf("  %p - %p : %zu bytes [%s]\n",
				   (void *)((char *)block + BLOCK_SIZE),
				   (void *)((char *)block + BLOCK_SIZE + block->size),
				   block->size,
				   block->free ? "FREE" : "USED");
			block = block->next;
		}
		zone = zone->next;
	}
}

void	show_alloc_mem(void)
{
	size_t	total = 0;
	t_zone	*zone;
	t_block	*block;

	pthread_mutex_lock(&g_malloc.mutex);

	printf("=== MEMORY ALLOCATION MAP ===\n\n");

	print_zone("TINY", g_malloc.tiny);
	print_zone("SMALL", g_malloc.small);
	print_zone("LARGE", g_malloc.large);

	/* Calculate total used */
	for (zone = g_malloc.tiny; zone; zone = zone->next)
		for (block = zone->blocks; block; block = block->next)
			if (!block->free)
				total += block->size;
	for (zone = g_malloc.small; zone; zone = zone->next)
		for (block = zone->blocks; block; block = block->next)
			if (!block->free)
				total += block->size;
	for (zone = g_malloc.large; zone; zone = zone->next)
		for (block = zone->blocks; block; block = block->next)
			if (!block->free)
				total += block->size;

	printf("\nTotal allocated: %zu bytes\n", total);

	pthread_mutex_unlock(&g_malloc.mutex);
}

/* ========== Standard API Wrappers ========== */

void	*malloc(size_t size)
{
	return (ft_malloc(size));
}

void	free(void *ptr)
{
	ft_free(ptr);
}

void	*realloc(void *ptr, size_t size)
{
	return (ft_realloc(ptr, size));
}

void	*calloc(size_t count, size_t size)
{
	return (ft_calloc(count, size));
}

/* ========== Test Program ========== */

#ifdef TEST_MALLOC

int	main(void)
{
	void	*ptrs[100];
	int		i;

	printf("ft_malloc Test Suite\n");
	printf("====================\n\n");

	/* Test 1: Small allocations */
	printf("Test 1: Small allocations (TINY)\n");
	for (i = 0; i < 10; i++)
	{
		ptrs[i] = ft_malloc(32);
		printf("  Allocated %d: %p\n", i, ptrs[i]);
		if (ptrs[i])
			memset(ptrs[i], 'A' + i, 32);
	}
	show_alloc_mem();

	/* Test 2: Free some */
	printf("\nTest 2: Free half\n");
	for (i = 0; i < 10; i += 2)
	{
		ft_free(ptrs[i]);
		ptrs[i] = NULL;
	}
	show_alloc_mem();

	/* Test 3: Medium allocations */
	printf("\nTest 3: Medium allocations (SMALL)\n");
	for (i = 10; i < 15; i++)
	{
		ptrs[i] = ft_malloc(256);
		printf("  Allocated %d: %p\n", i, ptrs[i]);
	}
	show_alloc_mem();

	/* Test 4: Large allocation */
	printf("\nTest 4: Large allocation\n");
	ptrs[50] = ft_malloc(10000);
	printf("  Large allocation: %p\n", ptrs[50]);
	show_alloc_mem();

	/* Test 5: Realloc */
	printf("\nTest 5: Realloc\n");
	ptrs[1] = ft_realloc(ptrs[1], 64);
	printf("  Reallocated: %p\n", ptrs[1]);
	show_alloc_mem();

	/* Test 6: Calloc */
	printf("\nTest 6: Calloc\n");
	ptrs[60] = ft_calloc(10, sizeof(int));
	printf("  Calloc (10 ints): %p\n", ptrs[60]);
	int *arr = ptrs[60];
	int zero_check = 1;
	for (i = 0; i < 10; i++)
		if (arr[i] != 0)
			zero_check = 0;
	printf("  Zero initialized: %s\n", zero_check ? "YES" : "NO");

	/* Cleanup */
	printf("\nTest 7: Cleanup\n");
	for (i = 0; i < 100; i++)
		if (ptrs[i])
			ft_free(ptrs[i]);
	show_alloc_mem();

	printf("\nAll tests completed!\n");
	return (0);
}

#endif
