#include "philo.h"

#include <unistd.h>

static int	check_death(t_sim *sim, t_philo *philo)
{
	long	last_meal;
	long	now;

	pthread_mutex_lock(&philo->meal_mutex);
	last_meal = philo->last_meal_ms;
	pthread_mutex_unlock(&philo->meal_mutex);
	now = current_time_ms();
	if ((now - last_meal) > sim->config.time_to_die)
	{
		set_sim_running(sim, 0);
		sim_log(sim, philo->id, "died", 0);
		return (1);
	}
	return (0);
}

static int	all_philos_ate(t_sim *sim)
{
	int	index;
	int	target;
	int	completed;

	if (!sim->config.has_must_eat)
		return (0);
	index = 0;
	target = sim->config.must_eat_target;
	while (index < sim->config.philo_count)
	{
		pthread_mutex_lock(&sim->philos[index].meal_mutex);
		completed = (sim->philos[index].meals_eaten >= target);
		pthread_mutex_unlock(&sim->philos[index].meal_mutex);
		if (!completed)
			return (0);
		index++;
	}
	return (1);
}

void	*monitor_routine(void *arg)
{
	t_sim	*sim;
	int		index;

	sim = (t_sim *)arg;
	while (sim_is_running(sim))
	{
		index = 0;
		while (index < sim->config.philo_count)
		{
			if (check_death(sim, &sim->philos[index]))
				return (NULL);
			index++;
		}
		if (all_philos_ate(sim))
		{
			set_sim_running(sim, 0);
			return (NULL);
		}
		usleep(1000);
	}
	return (NULL);
}
