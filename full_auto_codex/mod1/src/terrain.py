"""Terrain generation utilities."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence

from .utils import (
	Point3D,
	allocate_grid,
	grid_stats,
	inverse_distance_weighting,
)


@dataclass
class Terrain:
	"""Terrain height map generated from sparse control points."""

	heights: list[list[float]]
	x_coords: list[float]
	y_coords: list[float]
	min_height: float
	max_height: float

	@property
	def width(self) -> int:
		return len(self.heights[0])

	@property
	def height(self) -> int:
		return len(self.heights)

	@property
	def height_range(self) -> float:
		return self.max_height - self.min_height


def _compute_padding(points: Sequence[Point3D]) -> tuple[float, float, float, float]:
	min_x = min(p[0] for p in points)
	max_x = max(p[0] for p in points)
	min_y = min(p[1] for p in points)
	max_y = max(p[1] for p in points)
	span_x = max(max_x - min_x, 1.0)
	span_y = max(max_y - min_y, 1.0)
	padding = max(span_x, span_y) * 0.1
	return (min_x - padding, max_x + padding, min_y - padding, max_y + padding)


def generate_terrain(
	points: Sequence[Point3D],
	resolution: int = 64,
	max_radius: float | None = None,
	power: float = 2.2,
) -> Terrain:
	"""Return a :class:`Terrain` interpolated from *points*."""
	if resolution < 4:
		raise ValueError("resolution must be at least 4 to build a meaningful grid")

	min_x, max_x, min_y, max_y = _compute_padding(points)
	width = height = resolution

	x_coords = [
		min_x + (max_x - min_x) * (ix / (width - 1)) for ix in range(width)
	]
	y_coords = [
		min_y + (max_y - min_y) * (iy / (height - 1)) for iy in range(height)
	]

	heights = allocate_grid(width, height, 0.0)
	for iy, y in enumerate(y_coords):
		for ix, x in enumerate(x_coords):
			heights[iy][ix] = inverse_distance_weighting(
				x, y, points, power=power, max_radius=max_radius
			)

	min_height, max_height = grid_stats(heights)
	return Terrain(
		heights=heights,
		x_coords=x_coords,
		y_coords=y_coords,
		min_height=min_height,
		max_height=max_height,
	)
