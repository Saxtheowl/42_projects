# ft_kalman - Kalman Filter

State estimation using Kalman filtering.

## Features

- Matrix operations (add, multiply, inverse, transpose)
- Linear Kalman Filter implementation
- 1D position tracking demo
- 2D position tracking demo
- Noise reduction demonstration

## Usage

```bash
python kalman.py       # Run all demos
python kalman.py 1d    # 1D tracking demo
python kalman.py 2d    # 2D tracking demo
```

## Kalman Filter Equations

**Prediction:**
- x = F * x + B * u
- P = F * P * F' + Q

**Update:**
- y = z - H * x (innovation)
- S = H * P * H' + R (innovation covariance)
- K = P * H' * S^-1 (Kalman gain)
- x = x + K * y (updated state)
- P = (I - K * H) * P (updated covariance)

## Matrices

| Symbol | Description |
|--------|-------------|
| x | State vector |
| P | State covariance |
| F | State transition |
| H | Measurement |
| Q | Process noise |
| R | Measurement noise |
| K | Kalman gain |

## Author

Implementation for 42 curriculum.
