/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   monitor.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

int	check_death(t_data *data)
{
	int			i;
	long long	time;

	i = 0;
	while (i < data->nb_philos)
	{
		pthread_mutex_lock(&data->meal_mutex);
		time = get_time() - data->philos[i].last_meal_time;
		if (time > data->time_to_die)
		{
			pthread_mutex_unlock(&data->meal_mutex);
			pthread_mutex_lock(&data->death_mutex);
			data->someone_died = 1;
			pthread_mutex_unlock(&data->death_mutex);
			pthread_mutex_lock(&data->print_mutex);
			printf("%lld %d died\n", get_time() - data->start_time,
				data->philos[i].id);
			pthread_mutex_unlock(&data->print_mutex);
			return (1);
		}
		pthread_mutex_unlock(&data->meal_mutex);
		i++;
	}
	return (0);
}

int	all_ate_enough(t_data *data)
{
	int	i;
	int	count;

	if (data->nb_meals == -1)
		return (0);
	count = 0;
	i = 0;
	while (i < data->nb_philos)
	{
		pthread_mutex_lock(&data->meal_mutex);
		if (data->philos[i].meals_eaten >= data->nb_meals)
			count++;
		pthread_mutex_unlock(&data->meal_mutex);
		i++;
	}
	if (count == data->nb_philos)
	{
		pthread_mutex_lock(&data->death_mutex);
		data->someone_died = 1;
		pthread_mutex_unlock(&data->death_mutex);
		return (1);
	}
	return (0);
}

void	*monitor_routine(void *arg)
{
	t_data	*data;

	data = (t_data *)arg;
	while (1)
	{
		if (check_death(data) || all_ate_enough(data))
			break ;
		usleep(1000);
	}
	return (NULL);
}
