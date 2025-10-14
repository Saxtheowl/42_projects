/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/13 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/13 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "philo.h"

static int	check_args(int argc, char **argv)
{
	int	i;
	int	j;

	if (argc < 5 || argc > 6)
	{
		printf("Usage: ./philo number_of_philosophers time_to_die ");
		printf("time_to_eat time_to_sleep ");
		printf("[number_of_times_each_philosopher_must_eat]\n");
		return (1);
	}
	i = 1;
	while (i < argc)
	{
		j = 0;
		while (argv[i][j])
		{
			if (argv[i][j] < '0' || argv[i][j] > '9')
				return (1);
			j++;
		}
		i++;
	}
	return (0);
}

static int	start_simulation(t_data *data)
{
	int			i;
	pthread_t	monitor;

	data->start_time = get_time();
	i = 0;
	while (i < data->nb_philos)
	{
		data->philos[i].last_meal_time = data->start_time;
		if (pthread_create(&data->philos[i].thread, NULL,
				philo_routine, &data->philos[i]) != 0)
			return (1);
		i++;
	}
	if (pthread_create(&monitor, NULL, monitor_routine, data) != 0)
		return (1);
	pthread_join(monitor, NULL);
	i = 0;
	while (i < data->nb_philos)
	{
		pthread_join(data->philos[i].thread, NULL);
		i++;
	}
	return (0);
}

int	main(int argc, char **argv)
{
	t_data	data;

	if (check_args(argc, argv))
	{
		printf("Error: Invalid arguments\n");
		return (1);
	}
	if (init_data(&data, argc, argv))
	{
		printf("Error: Invalid parameter values\n");
		return (1);
	}
	if (init_philos(&data))
	{
		printf("Error: Memory allocation failed\n");
		cleanup(&data);
		return (1);
	}
	if (start_simulation(&data))
	{
		printf("Error: Thread creation failed\n");
		cleanup(&data);
		return (1);
	}
	cleanup(&data);
	return (0);
}
