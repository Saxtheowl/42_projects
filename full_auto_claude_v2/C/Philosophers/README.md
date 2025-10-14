# Philosophers

A 42 school project implementing the classic Dining Philosophers Problem using threads and mutexes.

## Description

The Philosophers project simulates the dining philosophers problem, a classic synchronization challenge in concurrent programming. Philosophers sit at a round table, alternating between eating, sleeping, and thinking. They need two forks to eat, but there's only one fork between each pair of philosophers.

## Problem Statement

- N philosophers sit at a round table with N forks
- Each philosopher needs 2 forks (left and right) to eat
- After eating, they sleep, then think, then repeat
- Philosophers must not starve
- The simulation stops when a philosopher dies or all have eaten enough times

## Compilation

```bash
cd philo
make
```

## Usage

```bash
./philo number_of_philosophers time_to_die time_to_eat time_to_sleep [number_of_times_each_philosopher_must_eat]
```

### Arguments

- **number_of_philosophers**: Number of philosophers (and forks)
- **time_to_die**: Time in ms before a philosopher dies if they haven't eaten
- **time_to_eat**: Time in ms it takes to eat
- **time_to_sleep**: Time in ms spent sleeping
- **[optional] number_of_times_each_philosopher_must_eat**: Simulation stops after all philosophers eat this many times

### Examples

Basic simulation (no one should die):
```bash
./philo 5 800 200 200
```

Tight timing (philosophers will eventually die):
```bash
./philo 4 310 200 200
```

Limited meals (stops after all eat 7 times):
```bash
./philo 5 800 200 200 7
```

Edge case - single philosopher (will die):
```bash
./philo 1 800 200 200
```

## Output Format

```
timestamp_in_ms philosopher_id action
```

Actions:
- `has taken a fork`
- `is eating`
- `is sleeping`
- `is thinking`
- `died`

## Implementation Details

### Threading Model
- Each philosopher is a separate thread (`pthread`)
- One fork per philosopher (protected by mutex)
- Monitor thread checks for deaths every 1ms

### Deadlock Prevention
- Even-numbered philosophers pick right fork first
- Odd-numbered philosophers pick left fork first
- This prevents circular wait conditions

### Data Structures

```c
typedef struct s_philo
{
    int             id;
    int             meals_eaten;
    long long       last_meal_time;
    pthread_t       thread;
    pthread_mutex_t *left_fork;
    pthread_mutex_t *right_fork;
    t_data          *data;
} t_philo;

typedef struct s_data
{
    int             nb_philos;
    int             time_to_die;
    int             time_to_eat;
    int             time_to_sleep;
    int             nb_meals;
    int             someone_died;
    long long       start_time;
    pthread_mutex_t *forks;
    pthread_mutex_t print_mutex;
    pthread_mutex_t death_mutex;
    pthread_mutex_t meal_mutex;
    t_philo         *philos;
} t_data;
```

### Synchronization

Three main mutexes protect shared resources:
1. **Fork mutexes**: One per fork, prevents simultaneous access
2. **Print mutex**: Ensures log messages don't interleave
3. **Death mutex**: Protects the death flag
4. **Meal mutex**: Protects meal timing and counts

### Death Detection

A dedicated monitor thread:
- Checks each philosopher's last meal time every 1ms
- Detects death within 10ms requirement
- Sets death flag to stop all philosophers

### Edge Cases

- **Single philosopher**: Special handling - can only grab one fork, will die
- **Even/odd philosopher count**: Handled by alternating fork-grabbing order
- **Zero meals**: Returns immediately
- **Meal count completion**: All philosophers eating enough times stops simulation

## Key Challenges Solved

1. **Deadlock prevention**: Different fork-grabbing order for even/odd philosophers
2. **Race conditions**: Proper mutex usage for all shared resources
3. **Death detection accuracy**: Monitor thread checks every 1ms
4. **Thread-safe logging**: Print mutex prevents message interleaving
5. **Memory management**: All resources properly freed on exit

## Files

- `philo.h` - Header with structures and function declarations
- `main.c` - Argument parsing and simulation startup
- `init.c` - Data structure initialization and cleanup
- `utils.c` - Utility functions (time, printing, atoi)
- `routine.c` - Philosopher thread routine (eat/sleep/think cycle)
- `monitor.c` - Death detection and meal count checking
- `Makefile` - Build system

## Performance

- Death detection: < 10ms from actual death
- Minimal busy-waiting with usleep optimizations
- Efficient mutex usage prevents unnecessary blocking

## Allowed Functions

- `memset`, `printf`, `malloc`, `free`, `write`
- `usleep`, `gettimeofday`
- `pthread_create`, `pthread_detach`, `pthread_join`
- `pthread_mutex_init`, `pthread_mutex_destroy`
- `pthread_mutex_lock`, `pthread_mutex_unlock`

## Author

Generated for 42 School project
