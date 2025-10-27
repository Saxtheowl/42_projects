#include "philo.h"

#include <unistd.h>

static void	init_philo_state(t_sim *sim, long start_ms)
{
	int	index;

	index = 0;
	while (index < sim->config.philo_count)
	{
		pthread_mutex_lock(&sim->philos[index].meal_mutex);
		sim->philos[index].last_meal_ms = start_ms;
		sim->philos[index].meals_eaten = 0;
		pthread_mutex_unlock(&sim->philos[index].meal_mutex);
		index++;
	}
}

static int	launch_philosophers(t_sim *sim)
{
	int	index;

	index = 0;
	while (index < sim->config.philo_count)
	{
		if (pthread_create(&sim->philos[index].thread, NULL,
				philo_routine, &sim->philos[index]) != 0)
		{
			while (index > 0)
			{
				index--;
				pthread_join(sim->philos[index].thread, NULL);
			}
			return (0);
		}
		usleep(100);
		index++;
	}
	return (1);
}

static void	join_philosophers(t_sim *sim)
{
	int	index;

	index = 0;
	while (index < sim->config.philo_count)
	{
		pthread_join(sim->philos[index].thread, NULL);
		index++;
	}
}

int	start_simulation(t_sim *sim)
{
	sim->start_ms = current_time_ms();
	init_philo_state(sim, sim->start_ms);
	set_sim_running(sim, 1);
	if (!launch_philosophers(sim))
	{
		set_sim_running(sim, 0);
		return (0);
	}
	if (pthread_create(&sim->monitor_thread, NULL, monitor_routine, sim) != 0)
	{
		set_sim_running(sim, 0);
		join_philosophers(sim);
		return (0);
	}
	pthread_join(sim->monitor_thread, NULL);
	join_philosophers(sim);
	return (1);
}
