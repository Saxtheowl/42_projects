#include "philo.h"

#include <stdio.h>

static long	elapsed_ms(t_sim *sim)
{
	return (current_time_ms() - sim->start_ms);
}

void	sim_log(t_sim *sim, int id, const char *message, int check_state)
{
	int		active;
	long	timestamp;

	pthread_mutex_lock(&sim->state_mutex);
	active = sim->running;
	pthread_mutex_unlock(&sim->state_mutex);
	if (check_state && !active)
		return ;
	timestamp = elapsed_ms(sim);
	pthread_mutex_lock(&sim->log_mutex);
	printf("%ld %d %s\n", timestamp, id, message);
	pthread_mutex_unlock(&sim->log_mutex);
}
