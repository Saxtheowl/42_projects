#ifndef PHILO_H
# define PHILO_H

# include <pthread.h>
# include <sys/time.h>
# include <stddef.h>

typedef struct s_config
{
	int	philo_count;
	int	time_to_die;
	int	time_to_eat;
	int	time_to_sleep;
	int	must_eat_target;
	int	has_must_eat;
}	t_config;

typedef struct s_sim	t_sim;

typedef struct s_philo
{
	int					id;
	pthread_t			thread;
	pthread_mutex_t		*left_fork;
	pthread_mutex_t		*right_fork;
	pthread_mutex_t		meal_mutex;
	long				last_meal_ms;
	int					meals_eaten;
	t_sim				*sim;
}	t_philo;

struct s_sim
{
	t_config		config;
	pthread_mutex_t	*forks;
	pthread_mutex_t	log_mutex;
	pthread_mutex_t	state_mutex;
	int				running;
	long			start_ms;
	pthread_t		monitor_thread;
	t_philo			*philos;
};

/* parsing & utils */
int		parse_config(int argc, char **argv, t_config *config);
int		ft_isdigit(int c);
long	ft_atol(const char *str, int *ok);

/* simulation lifecycle */
int		init_simulation(t_sim *sim, const t_config *config);
void	destroy_simulation(t_sim *sim);
int		start_simulation(t_sim *sim);
int		sim_is_running(t_sim *sim);
void	set_sim_running(t_sim *sim, int value);

/* timing / logging */
long	current_time_ms(void);
void	sim_log(t_sim *sim, int id, const char *message, int check_state);
void	safe_sleep(t_sim *sim, int duration_ms);

/* worker routines */
void	*philo_routine(void *arg);
void	*monitor_routine(void *arg);

#endif
