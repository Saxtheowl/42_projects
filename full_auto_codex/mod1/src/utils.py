"""Utility functions shared across the mod1 project."""

from __future__ import annotations

import math
from typing import Iterable, List, Sequence, Tuple


Point3D = Tuple[float, float, float]


def clamp(value: float, min_value: float, max_value: float) -> float:
	"""Clamp *value* within [min_value, max_value]."""
	if value < min_value:
		return min_value
	if value > max_value:
		return max_value
	return value


def inverse_distance_weighting(
	x: float,
	y: float,
	points: Sequence[Point3D],
	power: float = 2.0,
	min_points: int = 3,
	max_radius: float | None = None,
) -> float:
	"""Interpolate the height at (*x*, *y*) using inverse-distance weighting.

	When no point is found within *max_radius* (if provided), the closest point
	is used as a fallback to avoid introducing NaNs in the height map.
	"""
	if not points:
		raise ValueError("at least one control point is required for interpolation")

	total_weight = 0.0
	accumulator = 0.0
	closest_distance = math.inf
	closest_height = 0.0

	for px, py, pz in points:
		dx = x - px
		dy = y - py
		distance = math.hypot(dx, dy)
		if distance < 1e-6:
			# Avoid division by zero: the grid point sits exactly on a control point.
			return pz
		if max_radius is not None and distance > max_radius:
			continue
		weight = distance ** (-power)
		accumulator += weight * pz
		total_weight += weight
		if distance < closest_distance:
			closest_distance = distance
			closest_height = pz

	if total_weight == 0.0:
		return closest_height
	return accumulator / total_weight


def allocate_grid(width: int, height: int, value: float = 0.0) -> List[List[float]]:
	"""Return a 2D grid initialised with *value*."""
	return [[value for _ in range(width)] for _ in range(height)]


def iter_neighbors(x: int, y: int, width: int, height: int) -> Iterable[Tuple[int, int]]:
	"""Yield 4-neighbours of (x, y) confined within the grid boundaries."""
	if x > 0:
		yield (x - 1, y)
	if x + 1 < width:
		yield (x + 1, y)
	if y > 0:
		yield (x, y - 1)
	if y + 1 < height:
		yield (x, y + 1)


def grid_stats(grid: Sequence[Sequence[float]]) -> Tuple[float, float]:
	"""Return (min, max) values observed in *grid*."""
	min_value = math.inf
	max_value = -math.inf
	for row in grid:
		for value in row:
			if value < min_value:
				min_value = value
			if value > max_value:
				max_value = value
	return (min_value, max_value)


def copy_grid(grid: Sequence[Sequence[float]]) -> List[List[float]]:
	"""Create a deep copy of a 2D grid."""
	return [list(row) for row in grid]
