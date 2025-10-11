"""PPM renderer for terrain and water frames."""

from __future__ import annotations

from pathlib import Path
from typing import Sequence, Tuple

from .terrain import Terrain
from .water import WaterField
from .utils import clamp, grid_stats


Color = Tuple[int, int, int]


def _lerp_color(color_a: Color, color_b: Color, factor: float) -> Color:
	return tuple(
		int(round(a + (b - a) * factor)) for a, b in zip(color_a, color_b)
	)


def _land_color(normalized_height: float) -> Color:
	# Blend from rocky brown to lush green.
	low = (109, 82, 53)
	high = (34, 139, 34)
	return _lerp_color(low, high, clamp(normalized_height, 0.0, 1.0))


def _apply_water_overlay(land_color: Color, depth: float, max_depth: float) -> Color:
	if depth <= 0.0:
		return land_color
	water_color = (65, 105, 225)
	factor = clamp(depth / max_depth, 0.0, 1.0)
	return _lerp_color(land_color, water_color, factor)


def _normalise_height(height: float, min_height: float, max_height: float) -> float:
	if max_height - min_height < 1e-6:
		return 0.0
	return (height - min_height) / (max_height - min_height)


def render_frame(
	terrain: Terrain,
	water_field: WaterField,
	output_path: Path,
) -> None:
	"""Render a terrain/water combinaison to *output_path* in ASCII PPM."""
	water_depth = water_field.depth
	max_depth = max(0.01, grid_stats(water_depth)[1])

	output_path.parent.mkdir(parents=True, exist_ok=True)
	with output_path.open("w", encoding="ascii") as handle:
		handle.write(f"P3\n{terrain.width} {terrain.height}\n255\n")
		for y in range(terrain.height):
			row_components = []
			for x in range(terrain.width):
				height = terrain.heights[y][x]
				land_color = _land_color(
					_normalise_height(height, terrain.min_height, terrain.max_height)
				)
				color = _apply_water_overlay(
					land_color,
					water_depth[y][x],
					max_depth=max_depth,
				)
				row_components.append(f"{color[0]} {color[1]} {color[2]}")
			handle.write(" ".join(row_components) + "\n")
