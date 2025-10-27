#include "philo.h"

#include <unistd.h>

long	current_time_ms(void)
{
	struct timeval	tv;

	gettimeofday(&tv, NULL);
	return ((tv.tv_sec * 1000) + (tv.tv_usec / 1000));
}

void	safe_sleep(t_sim *sim, int duration_ms)
{
	long	start;

	if (duration_ms <= 0)
		return ;
	start = current_time_ms();
	while (sim_is_running(sim))
	{
		if ((current_time_ms() - start) >= duration_ms)
			break ;
		usleep(1000);
	}
}
