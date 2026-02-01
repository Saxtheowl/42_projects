#!/usr/bin/env python3
"""
ft_kalman - Kalman Filter implementation
State estimation for noisy measurements
"""

import sys
import math
import random
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class Matrix:
    """Simple matrix implementation."""
    rows: int
    cols: int
    data: List[List[float]]

    @staticmethod
    def zeros(rows: int, cols: int) -> 'Matrix':
        return Matrix(rows, cols, [[0.0] * cols for _ in range(rows)])

    @staticmethod
    def identity(n: int) -> 'Matrix':
        m = Matrix.zeros(n, n)
        for i in range(n):
            m.data[i][i] = 1.0
        return m

    @staticmethod
    def from_list(data: List[List[float]]) -> 'Matrix':
        return Matrix(len(data), len(data[0]) if data else 0, data)

    def __add__(self, other: 'Matrix') -> 'Matrix':
        result = Matrix.zeros(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[i][j] = self.data[i][j] + other.data[i][j]
        return result

    def __sub__(self, other: 'Matrix') -> 'Matrix':
        result = Matrix.zeros(self.rows, self.cols)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[i][j] = self.data[i][j] - other.data[i][j]
        return result

    def __mul__(self, other) -> 'Matrix':
        if isinstance(other, (int, float)):
            result = Matrix.zeros(self.rows, self.cols)
            for i in range(self.rows):
                for j in range(self.cols):
                    result.data[i][j] = self.data[i][j] * other
            return result

        # Matrix multiplication
        result = Matrix.zeros(self.rows, other.cols)
        for i in range(self.rows):
            for j in range(other.cols):
                for k in range(self.cols):
                    result.data[i][j] += self.data[i][k] * other.data[k][j]
        return result

    def transpose(self) -> 'Matrix':
        result = Matrix.zeros(self.cols, self.rows)
        for i in range(self.rows):
            for j in range(self.cols):
                result.data[j][i] = self.data[i][j]
        return result

    def inverse(self) -> 'Matrix':
        """Compute inverse using Gauss-Jordan elimination."""
        n = self.rows
        # Augmented matrix [A | I]
        aug = [[self.data[i][j] for j in range(n)] + [1.0 if i == k else 0.0 for k in range(n)]
               for i in range(n)]

        # Forward elimination
        for i in range(n):
            # Find pivot
            max_row = i
            for k in range(i + 1, n):
                if abs(aug[k][i]) > abs(aug[max_row][i]):
                    max_row = k
            aug[i], aug[max_row] = aug[max_row], aug[i]

            # Check for singular matrix
            if abs(aug[i][i]) < 1e-10:
                return Matrix.identity(n)  # Return identity as fallback

            # Scale pivot row
            scale = aug[i][i]
            for j in range(2 * n):
                aug[i][j] /= scale

            # Eliminate column
            for k in range(n):
                if k != i:
                    factor = aug[k][i]
                    for j in range(2 * n):
                        aug[k][j] -= factor * aug[i][j]

        # Extract inverse
        return Matrix.from_list([[aug[i][j + n] for j in range(n)] for i in range(n)])

    def __str__(self) -> str:
        return '\n'.join([' '.join(f'{x:8.3f}' for x in row) for row in self.data])


class KalmanFilter:
    """
    Kalman Filter for linear state estimation.

    State vector x, measurement vector z
    x_k = F * x_{k-1} + B * u_k + w_k  (process model)
    z_k = H * x_k + v_k                (measurement model)

    w_k ~ N(0, Q)  process noise
    v_k ~ N(0, R)  measurement noise
    """

    def __init__(self, state_dim: int, measurement_dim: int):
        self.n = state_dim
        self.m = measurement_dim

        # State estimate
        self.x = Matrix.zeros(state_dim, 1)

        # Estimate covariance
        self.P = Matrix.identity(state_dim)

        # State transition matrix
        self.F = Matrix.identity(state_dim)

        # Control input matrix
        self.B = Matrix.zeros(state_dim, 1)

        # Measurement matrix
        self.H = Matrix.zeros(measurement_dim, state_dim)

        # Process noise covariance
        self.Q = Matrix.identity(state_dim) * 0.01

        # Measurement noise covariance
        self.R = Matrix.identity(measurement_dim) * 0.1

    def predict(self, u: Optional[Matrix] = None):
        """
        Prediction step.
        x = F * x + B * u
        P = F * P * F' + Q
        """
        if u is None:
            u = Matrix.zeros(1, 1)

        self.x = self.F * self.x + self.B * u
        self.P = self.F * self.P * self.F.transpose() + self.Q

    def update(self, z: Matrix):
        """
        Update step with measurement z.
        y = z - H * x          (innovation)
        S = H * P * H' + R     (innovation covariance)
        K = P * H' * S^-1      (Kalman gain)
        x = x + K * y          (updated state)
        P = (I - K * H) * P    (updated covariance)
        """
        # Innovation
        y = z - self.H * self.x

        # Innovation covariance
        S = self.H * self.P * self.H.transpose() + self.R

        # Kalman gain
        K = self.P * self.H.transpose() * S.inverse()

        # Update state
        self.x = self.x + K * y

        # Update covariance
        I = Matrix.identity(self.n)
        self.P = (I - K * self.H) * self.P

    def get_state(self) -> List[float]:
        """Get current state estimate."""
        return [self.x.data[i][0] for i in range(self.n)]


def run_1d_tracking_demo():
    """Demo: 1D position tracking with velocity."""
    print("=" * 50)
    print("1D Position Tracking Demo")
    print("=" * 50)

    # State: [position, velocity]
    kf = KalmanFilter(state_dim=2, measurement_dim=1)

    # State transition (constant velocity model)
    dt = 1.0
    kf.F = Matrix.from_list([
        [1, dt],
        [0, 1]
    ])

    # Measurement matrix (we only measure position)
    kf.H = Matrix.from_list([[1, 0]])

    # Process noise
    kf.Q = Matrix.from_list([
        [0.1, 0],
        [0, 0.1]
    ])

    # Measurement noise
    kf.R = Matrix.from_list([[1.0]])

    # Initial state
    kf.x = Matrix.from_list([[0], [1]])  # position=0, velocity=1

    # Simulate true positions and noisy measurements
    true_positions = []
    measurements = []
    estimates = []

    true_pos = 0
    true_vel = 1

    print("\nTime | True Pos | Measured | Estimated | Est. Vel")
    print("-" * 55)

    for t in range(20):
        # True state
        true_pos += true_vel
        true_positions.append(true_pos)

        # Noisy measurement
        measurement = true_pos + random.gauss(0, 1)
        measurements.append(measurement)

        # Kalman filter
        kf.predict()
        kf.update(Matrix.from_list([[measurement]]))

        state = kf.get_state()
        estimates.append(state[0])

        print(f"{t:4d} | {true_pos:8.2f} | {measurement:8.2f} | {state[0]:9.2f} | {state[1]:8.2f}")

    # Calculate errors
    meas_error = sum((m - t) ** 2 for m, t in zip(measurements, true_positions)) / len(measurements)
    est_error = sum((e - t) ** 2 for e, t in zip(estimates, true_positions)) / len(estimates)

    print(f"\nMeasurement MSE: {meas_error:.4f}")
    print(f"Estimate MSE:    {est_error:.4f}")
    print(f"Improvement:     {(1 - est_error / meas_error) * 100:.1f}%")


def run_2d_tracking_demo():
    """Demo: 2D position tracking."""
    print("\n" + "=" * 50)
    print("2D Position Tracking Demo")
    print("=" * 50)

    # State: [x, y, vx, vy]
    kf = KalmanFilter(state_dim=4, measurement_dim=2)

    dt = 1.0
    kf.F = Matrix.from_list([
        [1, 0, dt, 0],
        [0, 1, 0, dt],
        [0, 0, 1, 0],
        [0, 0, 0, 1]
    ])

    kf.H = Matrix.from_list([
        [1, 0, 0, 0],
        [0, 1, 0, 0]
    ])

    kf.Q = Matrix.identity(4) * 0.1
    kf.R = Matrix.identity(2) * 2.0

    kf.x = Matrix.from_list([[0], [0], [1], [0.5]])

    print("\nTime |   True X,Y    |  Measured X,Y  | Estimated X,Y")
    print("-" * 60)

    true_x, true_y = 0, 0
    vx, vy = 1, 0.5

    for t in range(15):
        true_x += vx
        true_y += vy

        meas_x = true_x + random.gauss(0, 1.5)
        meas_y = true_y + random.gauss(0, 1.5)

        kf.predict()
        kf.update(Matrix.from_list([[meas_x], [meas_y]]))

        state = kf.get_state()

        print(f"{t:4d} | ({true_x:5.1f},{true_y:5.1f}) | ({meas_x:5.1f},{meas_y:5.1f}) | ({state[0]:5.1f},{state[1]:5.1f})")


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--help':
            print("ft_kalman - Kalman Filter Implementation")
            print("\nUsage:")
            print("  python kalman.py       - Run demos")
            print("  python kalman.py 1d    - 1D tracking demo")
            print("  python kalman.py 2d    - 2D tracking demo")
            return
        elif sys.argv[1] == '1d':
            run_1d_tracking_demo()
            return
        elif sys.argv[1] == '2d':
            run_2d_tracking_demo()
            return

    random.seed(42)
    run_1d_tracking_demo()
    run_2d_tracking_demo()

    print("\n" + "=" * 50)
    print("Kalman Filter successfully demonstrated!")
    print("=" * 50)


if __name__ == "__main__":
    main()
