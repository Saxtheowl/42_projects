# Philosophers

## Description

Philosophers is an implementation of the classic Dining Philosophers Problem. It demonstrates concepts of threading, mutexes, and synchronization to avoid deadlocks and race conditions.

The problem: N philosophers sit around a table. Between each pair of adjacent philosophers is a fork. Philosophers alternate between thinking, eating, and sleeping. To eat, a philosopher needs both the fork on their left and right. After eating, they sleep, then think, and repeat.

## Concepts

- **Threads**: Each philosopher is a separate thread
- **Mutexes**: Forks are protected by mutexes to prevent race conditions
- **Deadlock Prevention**: Odd/even fork acquisition order prevents circular waiting
- **Race Conditions**: Careful locking around shared state (meal times, death flag)

## Compilation

```bash
make
```

## Usage

```bash
./philo number_of_philosophers time_to_die time_to_eat time_to_sleep [meals_required]
```

Parameters:
- `number_of_philosophers`: Number of philosophers (and forks)
- `time_to_die` (ms): Time a philosopher can go without eating before dying
- `time_to_eat` (ms): Time it takes to eat (holding both forks)
- `time_to_sleep` (ms): Time spent sleeping after eating
- `meals_required` (optional): Program stops when all philosophers have eaten this many times

## Examples

```bash
# 5 philosophers, 800ms to die, 200ms to eat, 200ms to sleep
./philo 5 800 200 200

# Same but stop after each philosopher eats 7 times
./philo 5 800 200 200 7

# One philosopher - will die (can't eat with only one fork)
./philo 1 800 200 200

# Test death: time_to_die is less than time_to_eat + time_to_sleep
./philo 4 310 200 100
# A philosopher should die
```

## Output Format

```
timestamp_ms philosopher_id action
```

Actions:
- `has taken a fork`
- `is eating`
- `is sleeping`
- `is thinking`
- `died`

## Testing

```bash
# Test 1: No one should die
./philo 5 800 200 200
# All philosophers should keep cycling

# Test 2: Everyone eats 7 times
./philo 5 800 200 200 7
# Should stop after all have eaten 7 times

# Test 3: One philosopher dies
./philo 4 310 200 100
# Someone should die around 310ms

# Test 4: Single philosopher
./philo 1 800 200 200
# Should die at 800ms (can't pick up two forks)
```

## Author

Implementation for 42 curriculum.
