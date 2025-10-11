"""Water simulation primitives."""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Iterable, List, Sequence, Tuple

from .terrain import Terrain
from .utils import allocate_grid, copy_grid, iter_neighbors


Grid = List[List[float]]


@dataclass
class WaterField:
	"""Encapsulates the water depth for each terrain cell."""

	depth: Grid

	@property
	def width(self) -> int:
		return len(self.depth[0])

	@property
	def height(self) -> int:
		return len(self.depth)


def create_water_field(terrain: Terrain, initial_level: float = 0.0) -> WaterField:
	"""Allocate a water field optionally filled using *initial_level*."""
	depth = allocate_grid(terrain.width, terrain.height, 0.0)
	if initial_level > 0.0:
		fill_uniform(terrain, depth, initial_level)
	return WaterField(depth)


def fill_uniform(terrain: Terrain, depth: Grid, surface_level: float) -> None:
	"""Fill *depth* so that water forms a flat surface at *surface_level*."""
	for y in range(terrain.height):
		for x in range(terrain.width):
			terrain_height = terrain.heights[y][x]
			depth[y][x] = max(0.0, surface_level - terrain_height)


def compute_surface_levels(terrain: Terrain, depth: Grid) -> Grid:
	"""Return the absolute water surface height for each cell."""
	surface = allocate_grid(terrain.width, terrain.height, 0.0)
	for y in range(terrain.height):
		for x in range(terrain.width):
			surface[y][x] = terrain.heights[y][x] + depth[y][x]
	return surface


def flow_step(
	terrain: Terrain,
	depth: Grid,
	rate: float = 0.25,
	minimum_drop: float = 0.05,
) -> None:
	"""Diffuse water towards adjacent lower cells."""
	width = terrain.width
	height = terrain.height
	delta = allocate_grid(width, height, 0.0)

	for y in range(height):
		for x in range(width):
			current_surface = terrain.heights[y][x] + depth[y][x]
			if depth[y][x] <= 0.0:
				continue
			for nx, ny in iter_neighbors(x, y, width, height):
				neighbor_surface = terrain.heights[ny][nx] + depth[ny][nx]
				difference = current_surface - neighbor_surface
				if difference <= minimum_drop:
					continue
				transfer = min(depth[y][x], difference * 0.5) * rate
				if transfer <= 0.0:
					continue
				delta[y][x] -= transfer
				delta[ny][nx] += transfer

	for y in range(height):
		for x in range(width):
			depth[y][x] = max(0.0, depth[y][x] + delta[y][x])


def add_rainfall(
	depth: Grid,
	positions: Iterable[Tuple[int, int]],
	amount: float,
) -> None:
	"""Add *amount* of water to each cell from *positions*."""
	for x, y in positions:
		depth[y][x] += amount


def wave_profile(
	x: float,
	front: float,
	amplitude: float,
	width: float,
) -> float:
	"""Return the water surface height contribution of a travelling wave."""
	distance = x - front
	if distance > 0.0:
		return 0.0
	# Exponential decay for the trailing wave.
	return amplitude * math.exp(distance / width)


def apply_wave(
	terrain: Terrain,
	depth: Grid,
	front: float,
	amplitude: float,
	width: float,
) -> None:
	"""Transform *depth* to follow a progressing wave front."""
	for y in range(terrain.height):
		for x in range(terrain.width):
			water_level = wave_profile(
				terrain.x_coords[x],
				front=front,
				amplitude=amplitude,
				width=width,
			)
			height = terrain.heights[y][x]
			depth[y][x] = max(0.0, water_level - height)


def total_volume(depth: Sequence[Sequence[float]]) -> float:
	"""Return the total amount of water."""
	return sum(sum(row) for row in depth)
