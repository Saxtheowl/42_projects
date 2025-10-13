#include "malloc_internal.h"

#include <sys/mman.h>
#include <sys/resource.h>
#include <unistd.h>

static void	init_mutex(t_malloc_state *state)
{
	if (state->mutex_ready)
		return ;
	pthread_mutex_init(&state->mutex, NULL);
	state->mutex_ready = 1;
}

t_malloc_state	g_malloc_state = {
	.tiny = NULL,
	.small = NULL,
	.large = NULL,
	.page_size = 0,
	.mutex_ready = 0
};

void	malloc_state_init(void)
{
	if (g_malloc_state.page_size == 0)
	{
		g_malloc_state.page_size = (size_t)getpagesize();
		init_mutex(&g_malloc_state);
	}
}

void	malloc_lock(void)
{
	if (!g_malloc_state.mutex_ready)
		malloc_state_init();
	pthread_mutex_lock(&g_malloc_state.mutex);
}

void	malloc_unlock(void)
{
	pthread_mutex_unlock(&g_malloc_state.mutex);
}
