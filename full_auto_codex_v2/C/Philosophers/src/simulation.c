#include "philo.h"

#include <stdlib.h>

static int	alloc_resources(t_sim *sim)
{
	sim->forks = malloc(sizeof(pthread_mutex_t) * sim->config.philo_count);
	if (sim->forks == NULL)
		return (0);
	sim->philos = malloc(sizeof(t_philo) * sim->config.philo_count);
	if (sim->philos == NULL)
	{
		free(sim->forks);
		sim->forks = NULL;
		return (0);
	}
	return (1);
}

static void	release_forks_partial(t_sim *sim, int count)
{
	while (count > 0)
	{
		count--;
		pthread_mutex_destroy(&sim->forks[count]);
	}
}

static int	init_forks(t_sim *sim)
{
	int	index;

	index = 0;
	while (index < sim->config.philo_count)
	{
		if (pthread_mutex_init(&sim->forks[index], NULL) != 0)
		{
			release_forks_partial(sim, index);
			return (0);
		}
		index++;
	}
	return (1);
}

static void	release_philos_partial(t_sim *sim, int count)
{
	while (count > 0)
	{
		count--;
		pthread_mutex_destroy(&sim->philos[count].meal_mutex);
	}
}

static int	setup_philo(t_sim *sim, int index)
{
	t_philo	*philo;

	philo = &sim->philos[index];
	philo->id = index + 1;
	philo->left_fork = &sim->forks[index];
	philo->right_fork = &sim->forks[(index + 1) % sim->config.philo_count];
	if (pthread_mutex_init(&philo->meal_mutex, NULL) != 0)
		return (0);
	philo->last_meal_ms = 0;
	philo->meals_eaten = 0;
	philo->sim = sim;
	return (1);
}

static int	init_philos(t_sim *sim)
{
	int	index;

	index = 0;
	while (index < sim->config.philo_count)
	{
		if (!setup_philo(sim, index))
		{
			release_philos_partial(sim, index);
			return (0);
		}
		index++;
	}
	return (1);
}

static void	destroy_philos(t_sim *sim)
{
	int	index;

	if (sim->philos == NULL)
		return ;
	index = 0;
	while (index < sim->config.philo_count)
	{
		pthread_mutex_destroy(&sim->philos[index].meal_mutex);
		index++;
	}
}

int	init_simulation(t_sim *sim, const t_config *config)
{
	sim->config = *config;
	sim->forks = NULL;
	sim->philos = NULL;
	if (!alloc_resources(sim))
		return (0);
	if (pthread_mutex_init(&sim->log_mutex, NULL) != 0)
	{
		free(sim->forks);
		free(sim->philos);
		return (0);
	}
	if (pthread_mutex_init(&sim->state_mutex, NULL) != 0)
	{
		pthread_mutex_destroy(&sim->log_mutex);
		free(sim->forks);
		free(sim->philos);
		return (0);
	}
	if (!init_forks(sim))
	{
		pthread_mutex_destroy(&sim->log_mutex);
		pthread_mutex_destroy(&sim->state_mutex);
		free(sim->philos);
		free(sim->forks);
		return (0);
	}
	if (!init_philos(sim))
	{
		release_forks_partial(sim, sim->config.philo_count);
		pthread_mutex_destroy(&sim->log_mutex);
		pthread_mutex_destroy(&sim->state_mutex);
		free(sim->philos);
		free(sim->forks);
		return (0);
	}
	sim->running = 0;
	sim->start_ms = 0;
	return (1);
}

void	destroy_simulation(t_sim *sim)
{
	int	index;

	destroy_philos(sim);
	if (sim->forks != NULL)
	{
		index = 0;
		while (index < sim->config.philo_count)
		{
			pthread_mutex_destroy(&sim->forks[index]);
			index++;
		}
		free(sim->forks);
	}
	if (sim->philos != NULL)
		free(sim->philos);
	pthread_mutex_destroy(&sim->log_mutex);
	pthread_mutex_destroy(&sim->state_mutex);
}

int	sim_is_running(t_sim *sim)
{
	int	value;

	pthread_mutex_lock(&sim->state_mutex);
	value = sim->running;
	pthread_mutex_unlock(&sim->state_mutex);
	return (value);
}

void	set_sim_running(t_sim *sim, int value)
{
	pthread_mutex_lock(&sim->state_mutex);
	sim->running = value;
	pthread_mutex_unlock(&sim->state_mutex);
}
