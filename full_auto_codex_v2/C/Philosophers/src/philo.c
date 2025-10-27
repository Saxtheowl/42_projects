#include "philo.h"

#include <unistd.h>

static void	handle_single_philo(t_philo *philo)
{
	pthread_mutex_lock(philo->left_fork);
	sim_log(philo->sim, philo->id, "has taken a fork", 1);
	while (sim_is_running(philo->sim))
		usleep(1000);
	pthread_mutex_unlock(philo->left_fork);
}

static void	lock_fork(pthread_mutex_t *fork, t_philo *philo)
{
	pthread_mutex_lock(fork);
	sim_log(philo->sim, philo->id, "has taken a fork", 1);
}

static void	update_meal(t_philo *philo)
{
	pthread_mutex_lock(&philo->meal_mutex);
	philo->last_meal_ms = current_time_ms();
	philo->meals_eaten++;
	pthread_mutex_unlock(&philo->meal_mutex);
}

static void	select_forks(t_philo *philo, pthread_mutex_t **first,
		pthread_mutex_t **second)
{
	if (philo->id % 2 == 0)
	{
		*first = philo->right_fork;
		*second = philo->left_fork;
	}
	else
	{
		*first = philo->left_fork;
		*second = philo->right_fork;
	}
}

static int	start_eating(t_philo *philo)
{
	pthread_mutex_t	*first;
	pthread_mutex_t	*second;

	if (philo->sim->config.philo_count == 1)
	{
		handle_single_philo(philo);
		return (0);
	}
	select_forks(philo, &first, &second);
	lock_fork(first, philo);
	lock_fork(second, philo);
	update_meal(philo);
	sim_log(philo->sim, philo->id, "is eating", 1);
	safe_sleep(philo->sim, philo->sim->config.time_to_eat);
	pthread_mutex_unlock(second);
	pthread_mutex_unlock(first);
	return (1);
}

static void	sleep_and_think(t_philo *philo)
{
	sim_log(philo->sim, philo->id, "is sleeping", 1);
	safe_sleep(philo->sim, philo->sim->config.time_to_sleep);
	sim_log(philo->sim, philo->id, "is thinking", 1);
}

void	*philo_routine(void *arg)
{
	t_philo	*philo;

	philo = (t_philo *)arg;
	if (philo->id % 2 == 0)
		usleep(1000);
	while (sim_is_running(philo->sim))
	{
		if (!start_eating(philo))
			break ;
		sleep_and_think(philo);
	}
	return (NULL);
}
